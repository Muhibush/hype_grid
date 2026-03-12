import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hype_grid/model/hype_event.dart';
import 'package:hype_grid/pages/home/bloc/home_bloc.dart';
import 'package:hype_grid/pages/home/bloc/home_event_state.dart';
import 'package:hype_grid/pages/home/widget/date_section_header.dart';
import 'package:hype_grid/pages/home/widget/hype_event_card.dart';
import 'package:hype_grid/pages/home/widget/sport_filter_chips.dart';
import 'package:hype_grid/pages/home/widget/hype_filter_fab.dart';
import 'package:hype_grid/pages/home/widget/hype_empty_state.dart';
import 'package:hype_grid/services/calendar_service.dart';
import 'package:hype_grid/utils/app_colors.dart';
import 'package:hype_grid/widget/hype_app_bar.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => HomeBloc()..add(LoadHomeEvents()),
      child: const _HomeScreenContent(),
    );
  }
}

class _HomeScreenContent extends StatefulWidget {
  const _HomeScreenContent();

  @override
  State<_HomeScreenContent> createState() => _HomeScreenContentState();
}

class _HomeScreenContentState extends State<_HomeScreenContent> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToTop() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeOutCubic,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<HomeBloc, HomeState>(
      listener: (context, state) {
        if (state is HomeLoaded) {
          _scrollToTop();
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: const HypeAppBar(),
          floatingActionButton: HypeFilterFAB(
            isActive: state.showOnlyHype,
            onTap: () {
              context.read<HomeBloc>().add(
                    ToggleHypeFilter(!state.showOnlyHype),
                  );
            },
          ),
          body: ScrollConfiguration(
            behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
            child: _buildBody(context, state),
          ),
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, HomeState state) {
    final List<Widget> slivers = [];

    // 1. Sticky Sport Filter
    slivers.add(
      SliverAppBar(
        pinned: true,
        floating: false,
        backgroundColor: AppColors.background,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        toolbarHeight: 0,
        collapsedHeight: 70,
        expandedHeight: 70,
        flexibleSpace: FlexibleSpaceBar(
          background: Container(
            alignment: Alignment.center,
            child: SportFilterChips(
              selectedFilter: state.selectedSport,
              onSelected: (sport) {
                context.read<HomeBloc>().add(FilterBySport(sport));
              },
            ),
          ),
        ),
      ),
    );

    // 2. Content
    if (state is HomeLoading || state is HomeInitial) {
      slivers.add(
        const SliverFillRemaining(
          hasScrollBody: false,
          child: Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          ),
        ),
      );
    } else if (state is HomeError) {
      slivers.add(
        SliverFillRemaining(
          hasScrollBody: false,
          child: Center(
            child: Text(
              'Error: ${state.message}',
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ),
      );
    } else if (state is HomeLoaded) {
      if (state.filteredEvents.isEmpty) {
        slivers.add(
          SliverFillRemaining(
            hasScrollBody: false,
            child: HypeEmptyState(
              onReset: () {
                context.read<HomeBloc>()
                  ..add(const FilterBySport(SportFilter.all))
                  ..add(const ToggleHypeFilter(false));
              },
            ),
          ),
        );
      } else {
        slivers.add(_buildEventList(context, state));
      }
    } else {
      slivers.add(const SliverToBoxAdapter(child: SizedBox.shrink()));
    }

    return CustomScrollView(
      controller: _scrollController,
      slivers: slivers,
    );
  }

  Widget _buildEventList(BuildContext context, HomeLoaded state) {
    final events = state.filteredEvents;
    // Grouping events by date
    final groupedEvents = <DateTime, List<HypeEvent>>{};
    for (var event in events) {
      final date = DateTime(
        event.startTime.year,
        event.startTime.month,
        event.startTime.day,
      );
      groupedEvents.putIfAbsent(date, () => []).add(event);
    }

    final sortedDates = groupedEvents.keys.toList()..sort();

    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 100), // Space for FAB
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            int currentCount = 0;
            for (var date in sortedDates) {
              final eventsForDate = groupedEvents[date]!;

              // Header
              if (index == currentCount) {
                return DateSectionHeader(date: date);
              }
              currentCount++;

              // Events in this date
              if (index < currentCount + eventsForDate.length) {
                final eventIndex = index - currentCount;
                final event = eventsForDate[eventIndex];

                return HypeEventCard(
                  event: event,
                  onTap: () {},
                  onCalendarAdd: () {
                    CalendarService.addEventToCalendar(event);
                  },
                );
              }
              currentCount += eventsForDate.length;
            }
            return null;
          },
          childCount: sortedDates.length + events.length,
        ),
      ),
    );
  }
}
