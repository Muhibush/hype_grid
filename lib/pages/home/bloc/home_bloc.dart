import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:hype_grid/model/hype_event.dart';
import 'package:hype_grid/pages/home/widget/sport_filter_chips.dart';
import 'package:hype_grid/services/hype_repository.dart';
import 'home_event_state.dart';

class HomeBloc extends HydratedBloc<HomeEvent, HomeState> {
  final HypeRepository _repository;

  HomeBloc({HypeRepository? repository})
    : _repository = repository ?? HypeRepository(),
      super(HomeInitial()) {
    on<LoadHomeEvents>(_onLoadEvents);
    on<FilterBySport>(_onFilterSport);
    on<ToggleHypeFilter>(_onToggleHypeFilter);
    on<UpdateCommunityHype>(_onUpdateCommunityHype);
  }

  @override
  HomeState? fromJson(Map<String, dynamic> json) => homeStateFromJson(json);

  @override
  Map<String, dynamic>? toJson(HomeState state) => homeStateToJson(state);

  void _onLoadEvents(LoadHomeEvents event, Emitter<HomeState> emit) async {
    // Determine the loading state
    if (state is HomeLoaded) {
      // If we already have a loaded state, keep it while we fetch
      // But we can optionally emit a refreshing state or just continue relying on the previous data
      // For now, let's just fetch silently or you could show an indicator.
    } else {
      emit(
        HomeLoading(
          selectedSport: state.selectedSport,
          showOnlyHype: state.showOnlyHype,
        ),
      );
    }

    try {
      final events = await _repository.fetchEvents();

      _emitLoadedWithFilters(
        emit,
        events,
        state.selectedSport,
        state.showOnlyHype,
      );
    } catch (e) {
      // Offline: if we have cache, we keep the HomeLoaded state from hydrated storage.
      // If we don't have it, and we are in Initial/Loading, emit Error.
      if (state is! HomeLoaded) {
        emit(
          HomeError(
            e.toString(),
            selectedSport: state.selectedSport,
            showOnlyHype: state.showOnlyHype,
          ),
        );
      }
    }
  }

  void _onFilterSport(FilterBySport event, Emitter<HomeState> emit) {
    if (state is HomeLoaded) {
      final currentState = state as HomeLoaded;
      _emitLoadedWithFilters(
        emit,
        currentState.allEvents,
        event.sport,
        currentState.showOnlyHype,
      );
    }
  }

  void _onToggleHypeFilter(ToggleHypeFilter event, Emitter<HomeState> emit) {
    if (state is HomeLoaded) {
      final currentState = state as HomeLoaded;
      _emitLoadedWithFilters(
        emit,
        currentState.allEvents,
        currentState.selectedSport,
        event.showOnlyHype,
      );
    }
  }

  void _onUpdateCommunityHype(
    UpdateCommunityHype event,
    Emitter<HomeState> emit,
  ) {
    if (state is HomeLoaded) {
      final currentState = state as HomeLoaded;
      final updatedAllEvents = currentState.allEvents.map((hypeEvent) {
        if (hypeEvent.eventId == event.eventId) {
          return hypeEvent.copyWith(communityHype: event.newCommunityHype);
        }
        return hypeEvent;
      }).toList();

      _emitLoadedWithFilters(
        emit,
        updatedAllEvents,
        currentState.selectedSport,
        currentState.showOnlyHype,
      );
    }
  }

  void _emitLoadedWithFilters(
    Emitter<HomeState> emit,
    List<HypeEvent> allEvents,
    SportFilter sport,
    bool showOnlyHype,
  ) {
    final now = DateTime.now();
    var filtered = allEvents.where((event) {
      // Incoming events only
      final isUpcoming = event.startTime.isAfter(now);
      if (!isUpcoming) return false;

      // Hype Filter
      if (showOnlyHype && event.hypeScore < 90) {
        return false;
      }

      // Sport Filter
      bool sportMatches = true;
      if (sport != SportFilter.all) {
        sportMatches =
            event.sport.toLowerCase() == sport.searchKey.toLowerCase();
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
        showOnlyHype: showOnlyHype,
      ),
    );
  }
}
