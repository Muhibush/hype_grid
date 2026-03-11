import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hype_grid/model/hype_event.dart';
import 'package:hype_grid/pages/home/bloc/home_bloc.dart';
import 'package:hype_grid/pages/home/bloc/home_event_state.dart';
import 'package:hype_grid/pages/home/widget/date_section_header.dart';
import 'package:hype_grid/pages/home/widget/hype_event_card.dart';
import 'package:hype_grid/pages/home/widget/sport_filter_chips.dart';
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

class _HomeScreenContent extends StatelessWidget {
  const _HomeScreenContent();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const HypeAppBar(),
      body: ScrollConfiguration(
        behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
        child: BlocBuilder<HomeBloc, HomeState>(
          builder: (context, state) {
            final List<Widget> slivers = [];

            // 1. Sticky Filters (using SliverAppBar for stability)
            slivers.add(
              SliverAppBar(
                pinned: true,
                floating: false,
                backgroundColor: AppColors.background,
                elevation: 0,
                // Removed scrolledUnderElevation: 0 to allow the color to change when scrolling
                toolbarHeight: 0,
                collapsedHeight: 80,
                expandedHeight: 80,
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
              slivers.add(_buildEventList(state.filteredEvents));
            } else {
              slivers.add(const SliverToBoxAdapter(child: SizedBox.shrink()));
            }

            return CustomScrollView(slivers: slivers);
          },
        ),
      ),
    );
  }

  Widget _buildEventList(List<HypeEvent> events) {
    if (events.isEmpty) {
      return const SliverFillRemaining(
        hasScrollBody: false,
        child: Center(
          child: Text(
            'No events found for the selected filters.',
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ),
      );
    }

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
      padding: const EdgeInsets.symmetric(horizontal: 16),
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
                return HypeEventCard(
                  event: eventsForDate[eventIndex],
                  onTap: () {}, // TODO
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
