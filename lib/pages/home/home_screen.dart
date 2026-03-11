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
      body: BlocBuilder<HomeBloc, HomeState>(
        builder: (context, state) {
          return CustomScrollView(
            slivers: [
              // Filters Section (Sticky ish visually)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 0, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SportFilterChips(
                        selectedFilter: state.selectedSport,
                        onSelected: (sport) {
                          context.read<HomeBloc>().add(FilterBySport(sport));
                        },
                      ),
                    ],
                  ),
                ),
              ),

              // Content Area
              if (state is HomeLoading)
                const SliverFillRemaining(
                  child: Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  ),
                )
              else if (state is HomeError)
                SliverFillRemaining(
                  child: Center(
                    child: Text(
                      'Error: ${state.message}',
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                )
              else if (state is HomeLoaded)
                _buildEventList(state.filteredEvents),
            ],
          );
        },
      ),
    );
  }

  Widget _buildEventList(List<HypeEvent> events) {
    if (events.isEmpty) {
      return const SliverFillRemaining(
        child: Center(
          child: Text(
            'No events found for the selected filters.',
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ),
      );
    }

    // Grouping logic
    final groupedEvents = <DateTime, List<HypeEvent>>{};
    for (var event in events) {
      final date = DateTime(
        event.startTime.year,
        event.startTime.month,
        event.startTime.day,
      );
      if (!groupedEvents.containsKey(date)) {
        groupedEvents[date] = [];
      }
      groupedEvents[date]!.add(event);
    }

    final sortedDates = groupedEvents.keys.toList()..sort();

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            // Calculate which group and item this index maps to
            int currentCount = 0;
            for (var date in sortedDates) {
              final eventsForDate = groupedEvents[date]!;

              // Is this index the header?
              if (index == currentCount) {
                return DateSectionHeader(date: date);
              }

              currentCount++;

              // Is this index an event in this group?
              if (index < currentCount + eventsForDate.length) {
                final eventIndex = index - currentCount;
                final event = eventsForDate[eventIndex];
                return HypeEventCard(
                  event: event,
                  onTap: () {
                    // TODO: Open Bottom Sheet
                  },
                );
              }

              currentCount += eventsForDate.length;
            }
            return null;
          },
          // Total items = number of headers + number of all events
          childCount: sortedDates.length + events.length,
        ),
      ),
    );
  }
}
