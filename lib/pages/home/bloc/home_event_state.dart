import 'package:equatable/equatable.dart';
import 'package:hype_grid/model/hype_event.dart';
import 'package:hype_grid/pages/home/widget/mind_refresh_pills.dart';
import 'package:hype_grid/pages/home/widget/sport_filter_chips.dart';

// --- EVENTS ---
abstract class HomeEvent extends Equatable {
  const HomeEvent();

  @override
  List<Object?> get props => [];
}

class LoadHomeEvents extends HomeEvent {}

class FilterByDuration extends HomeEvent {
  final MindRefreshDuration duration;
  const FilterByDuration(this.duration);

  @override
  List<Object?> get props => [duration];
}

class FilterBySport extends HomeEvent {
  final SportFilter sport;
  const FilterBySport(this.sport);

  @override
  List<Object?> get props => [sport];
}

// --- STATES ---
abstract class HomeState extends Equatable {
  final MindRefreshDuration selectedDuration;
  final SportFilter selectedSport;

  const HomeState({
    this.selectedDuration = MindRefreshDuration.all,
    this.selectedSport = SportFilter.all,
  });

  @override
  List<Object?> get props => [selectedDuration, selectedSport];
}

class HomeInitial extends HomeState {}

class HomeLoading extends HomeState {
  const HomeLoading({super.selectedDuration, super.selectedSport});
}

class HomeLoaded extends HomeState {
  final List<HypeEvent> allEvents;
  final List<HypeEvent> filteredEvents;

  const HomeLoaded({
    required this.allEvents,
    required this.filteredEvents,
    super.selectedDuration,
    super.selectedSport,
  });

  @override
  List<Object?> get props => [
    allEvents,
    filteredEvents,
    selectedDuration,
    selectedSport,
  ];
}

class HomeError extends HomeState {
  final String message;

  const HomeError(this.message, {super.selectedDuration, super.selectedSport});

  @override
  List<Object?> get props => [message, selectedDuration, selectedSport];
}
