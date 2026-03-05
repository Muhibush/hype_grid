import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hype_grid/model/hype_event.dart';
import 'package:hype_grid/pages/home/widget/mind_refresh_pills.dart';
import 'package:hype_grid/pages/home/widget/sport_filter_chips.dart';
import 'home_event_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  HomeBloc() : super(HomeInitial()) {
    on<LoadHomeEvents>(_onLoadEvents);
    on<FilterByDuration>(_onFilterDuration);
    on<FilterBySport>(_onFilterSport);
  }

  void _onLoadEvents(LoadHomeEvents event, Emitter<HomeState> emit) async {
    emit(
      HomeLoading(
        selectedDuration: state.selectedDuration,
        selectedSport: state.selectedSport,
      ),
    );

    try {
      // Simulate network fetch with dummy data matching the UI mockup
      await Future.delayed(const Duration(seconds: 1));

      final dummyEvents = [
        HypeEvent(
          eventId: '1',
          title: 'Liverpool vs Arsenal',
          sport: 'Football',
          startTime: DateTime.now().add(const Duration(hours: 2)),
          durationMinutes: 110,
          hypeScore: 92,
          broadcastChannel: 'Vidio',
          metadata: {
            'league': 'Premier League',
            'home': 'Liverpool',
            'away': 'Arsenal',
          },
        ),
        HypeEvent(
          eventId: '2',
          title: 'Australian GP - Race',
          sport: 'F1',
          startTime: DateTime.now().add(const Duration(hours: 5)),
          durationMinutes: 120,
          hypeScore: 75,
          broadcastChannel: 'Trans7',
          metadata: {'league': 'Formula 1', 'session': 'Race'},
        ),
        HypeEvent(
          eventId: '3',
          title: 'Qatar GP - Qualifying',
          sport: 'MotoGP',
          startTime: DateTime.now().add(const Duration(days: 1, hours: 2)),
          durationMinutes: 60,
          hypeScore: 55,
          broadcastChannel: 'Trans7',
          metadata: {'league': 'MotoGP', 'session': 'Qualifying'},
        ),
      ];

      _emitLoadedWithFilters(
        emit,
        dummyEvents,
        state.selectedDuration,
        state.selectedSport,
      );
    } catch (e) {
      emit(
        HomeError(
          e.toString(),
          selectedDuration: state.selectedDuration,
          selectedSport: state.selectedSport,
        ),
      );
    }
  }

  void _onFilterDuration(FilterByDuration event, Emitter<HomeState> emit) {
    if (state is HomeLoaded) {
      final currentState = state as HomeLoaded;
      _emitLoadedWithFilters(
        emit,
        currentState.allEvents,
        event.duration,
        currentState.selectedSport,
      );
    }
  }

  void _onFilterSport(FilterBySport event, Emitter<HomeState> emit) {
    if (state is HomeLoaded) {
      final currentState = state as HomeLoaded;
      _emitLoadedWithFilters(
        emit,
        currentState.allEvents,
        currentState.selectedDuration,
        event.sport,
      );
    }
  }

  void _emitLoadedWithFilters(
    Emitter<HomeState> emit,
    List<HypeEvent> allEvents,
    MindRefreshDuration duration,
    SportFilter sport,
  ) {
    var filtered = allEvents.where((event) {
      // Sport Filter
      bool sportMatches = true;
      if (sport != SportFilter.all) {
        sportMatches = event.sport.toLowerCase() == sport.name.toLowerCase();
      }

      // Duration Filter
      bool durationMatches = true;
      if (duration != MindRefreshDuration.all) {
        durationMatches = event.durationMinutes <= duration.minutes;
      }

      return sportMatches && durationMatches;
    }).toList();

    // Ensure sorted by time
    filtered.sort((a, b) => a.startTime.compareTo(b.startTime));

    emit(
      HomeLoaded(
        allEvents: allEvents,
        filteredEvents: filtered,
        selectedDuration: duration,
        selectedSport: sport,
      ),
    );
  }
}
