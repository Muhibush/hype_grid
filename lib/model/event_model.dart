import 'package:equatable/equatable.dart';

class EventModel extends Equatable {
  final String eventId;
  final String title;
  final String sport;
  final DateTime startTime;
  final int durationMinutes;
  final int hypeScore;
  final String? broadcastChannel;
  final String? dataSource;
  final Map<String, dynamic> metadata;

  const EventModel({
    required this.eventId,
    required this.title,
    required this.sport,
    required this.startTime,
    required this.durationMinutes,
    required this.hypeScore,
    this.broadcastChannel,
    this.dataSource,
    required this.metadata,
  });

  factory EventModel.fromJson(Map<String, dynamic> json) {
    return EventModel(
      eventId: json['event_id'] as String,
      title: json['title'] as String,
      sport: json['sport'] as String,
      startTime: DateTime.parse(json['start_time'] as String),
      durationMinutes: json['duration_minutes'] as int,
      hypeScore: json['hype_score'] as int,
      broadcastChannel: json['broadcast_channel'] as String?,
      dataSource: json['data_source'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>? ?? {},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'event_id': eventId,
      'title': title,
      'sport': sport,
      'start_time': startTime.toIso8601String(),
      'duration_minutes': durationMinutes,
      'hype_score': hypeScore,
      'broadcast_channel': broadcastChannel,
      'data_source': dataSource,
      'metadata': metadata,
    };
  }

  @override
  List<Object?> get props => [
    eventId,
    title,
    sport,
    startTime,
    durationMinutes,
    hypeScore,
    broadcastChannel,
    dataSource,
    metadata,
  ];
}
