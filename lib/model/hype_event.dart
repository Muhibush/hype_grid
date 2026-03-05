class HypeEvent {
  final String eventId;
  final String title;
  final String sport;
  final DateTime startTime;
  final int durationMinutes;
  final int hypeScore;
  final String broadcastChannel;
  final Map<String, dynamic>? metadata;

  const HypeEvent({
    required this.eventId,
    required this.title,
    required this.sport,
    required this.startTime,
    required this.durationMinutes,
    required this.hypeScore,
    required this.broadcastChannel,
    this.metadata,
  });

  factory HypeEvent.fromJson(Map<String, dynamic> json) {
    return HypeEvent(
      eventId: json['event_id'] as String,
      title: json['title'] as String,
      sport: json['sport'] as String,
      startTime: DateTime.parse(
        json['start_time'] as String,
      ).toLocal(), // Always convert to local time
      durationMinutes: json['duration_minutes'] as int,
      hypeScore: json['hype_score'] as int,
      broadcastChannel: json['broadcast_channel'] as String,
      metadata: json['metadata'] as Map<String, dynamic>?,
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
      'metadata': metadata,
    };
  }
}
