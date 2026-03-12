import 'package:equatable/equatable.dart';
import 'package:hype_grid/model/hype_event.dart';
import 'package:hype_grid/pages/home/widget/sport_filter_chips.dart';

// --- EVENTS ---
abstract class HomeEvent extends Equatable {
  const HomeEvent();

  @override
  List<Object?> get props => [];
}

class LoadHomeEvents extends HomeEvent {}

class FilterBySport extends HomeEvent {
  final SportFilter sport;
  const FilterBySport(this.sport);

  @override
  List<Object?> get props => [sport];
}

class ToggleHypeFilter extends HomeEvent {
  final bool showOnlyHype;
  const ToggleHypeFilter(this.showOnlyHype);

  @override
  List<Object?> get props => [showOnlyHype];
}

class UpdateCommunityHype extends HomeEvent {
  final String eventId;
  final int newCommunityHype;
  const UpdateCommunityHype(this.eventId, this.newCommunityHype);

  @override
  List<Object?> get props => [eventId, newCommunityHype];
}

// --- STATES ---
abstract class HomeState extends Equatable {
  final SportFilter selectedSport;
  final bool showOnlyHype;

  const HomeState({
    this.selectedSport = SportFilter.all,
    this.showOnlyHype = true,
  });

  @override
  List<Object?> get props => [selectedSport, showOnlyHype];
}

class HomeInitial extends HomeState {}

class HomeLoading extends HomeState {
  const HomeLoading({super.selectedSport, super.showOnlyHype});
}

class HomeLoaded extends HomeState {
  final List<HypeEvent> allEvents;
  final List<HypeEvent> filteredEvents;

  const HomeLoaded({
    required this.allEvents,
    required this.filteredEvents,
    super.selectedSport,
    super.showOnlyHype,
  });

  @override
  List<Object?> get props =>
      [allEvents, filteredEvents, selectedSport, showOnlyHype];
}

class HomeError extends HomeState {
  final String message;

  const HomeError(this.message, {super.selectedSport, super.showOnlyHype});

  @override
  List<Object?> get props => [message, selectedSport, showOnlyHype];
}

HomeState? homeStateFromJson(Map<String, dynamic> json) {
  try {
    if (json['type'] == 'HomeLoaded') {
      final allEvents = (json['allEvents'] as List)
          .map((e) => HypeEvent.fromJson(e))
          .toList();
      final filteredEvents = (json['filteredEvents'] as List)
          .map((e) => HypeEvent.fromJson(e))
          .toList();
      final selectedSportStr = json['selectedSport'] as String?;
      final selectedSport = SportFilter.values.firstWhere(
        (e) => e.name == selectedSportStr,
        orElse: () => SportFilter.all,
      );
      final showOnlyHype = json['showOnlyHype'] as bool? ?? true;

      return HomeLoaded(
        allEvents: allEvents,
        filteredEvents: filteredEvents,
        selectedSport: selectedSport,
        showOnlyHype: showOnlyHype,
      );
    }
  } catch (_) {}
  return null;
}

Map<String, dynamic>? homeStateToJson(HomeState state) {
  if (state is HomeLoaded) {
    return {
      'type': 'HomeLoaded',
      'allEvents': state.allEvents.map((e) => e.toJson()).toList(),
      'filteredEvents': state.filteredEvents.map((e) => e.toJson()).toList(),
      'selectedSport': state.selectedSport.name,
      'showOnlyHype': state.showOnlyHype,
    };
  }
  return null;
}
