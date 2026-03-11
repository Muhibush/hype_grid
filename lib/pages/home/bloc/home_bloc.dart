import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hype_grid/model/hype_event.dart';
import 'package:hype_grid/pages/home/widget/sport_filter_chips.dart';
import 'package:hype_grid/services/hype_repository.dart';
import 'home_event_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final HypeRepository _repository;

  HomeBloc({HypeRepository? repository})
    : _repository = repository ?? HypeRepository(),
      super(HomeInitial()) {
    on<LoadHomeEvents>(_onLoadEvents);
    on<FilterBySport>(_onFilterSport);
  }

  void _onLoadEvents(LoadHomeEvents event, Emitter<HomeState> emit) async {
    emit(HomeLoading(selectedSport: state.selectedSport));

    try {
      final events = await _repository.fetchEvents();

      _emitLoadedWithFilters(emit, events, state.selectedSport);
    } catch (e) {
      emit(HomeError(e.toString(), selectedSport: state.selectedSport));
    }
  }

  void _onFilterSport(FilterBySport event, Emitter<HomeState> emit) {
    if (state is HomeLoaded) {
      final currentState = state as HomeLoaded;
      _emitLoadedWithFilters(emit, currentState.allEvents, event.sport);
    }
  }

  void _emitLoadedWithFilters(
    Emitter<HomeState> emit,
    List<HypeEvent> allEvents,
    SportFilter sport,
  ) {
    final now = DateTime.now();
    var filtered = allEvents.where((event) {
      // Incoming events only
      final isUpcoming = event.startTime.isAfter(now);
      if (!isUpcoming) return false;

      // Sport Filter
      bool sportMatches = true;
      if (sport != SportFilter.all) {
        sportMatches = event.sport.toLowerCase() == sport.searchKey.toLowerCase();
      }

      return sportMatches;
    }).toList();

    // Ensure sorted by time
    filtered.sort((a, b) => a.startTime.compareTo(b.startTime));

    emit(
      HomeLoaded(
        allEvents: allEvents,
        filteredEvents: filtered,
        selectedSport: sport,
      ),
    );
  }
}
