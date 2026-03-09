import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hype_grid/model/hype_event.dart';
import 'package:hype_grid/pages/home/widget/mind_refresh_pills.dart';
import 'package:hype_grid/pages/home/widget/sport_filter_chips.dart';
import 'package:hype_grid/services/hype_repository.dart';
import 'home_event_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final HypeRepository _repository;

  HomeBloc({HypeRepository? repository})
    : _repository = repository ?? HypeRepository(),
      super(HomeInitial()) {
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
      final events = await _repository.fetchEvents();

      _emitLoadedWithFilters(
        emit,
        events,
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
