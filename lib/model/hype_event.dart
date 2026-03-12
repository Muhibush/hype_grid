class HypeEvent {
  final String eventId;
  final String title;
  final String sport;
  final DateTime startTime;
  final int durationMinutes;
  final int hypeScore;
  final int communityHype;
  final String broadcastChannel;
  final String? dataSource;
  final Map<String, dynamic>? metadata;

  const HypeEvent({
    required this.eventId,
    required this.title,
    required this.sport,
    required this.startTime,
    required this.durationMinutes,
    required this.hypeScore,
    this.communityHype = 0,
    required this.broadcastChannel,
    this.dataSource,
    this.metadata,
  });

  int get totalHypeScore {
    // Community contribution:
    // 1 point per 10 taps, capped at a maximum of 5 points.
    int addition = (communityHype / 10).floor();
    if (addition > 5) addition = 5;
    int total = hypeScore + addition;
    return total > 100 ? 100 : total;
  }

  HypeEvent copyWith({
    String? eventId,
    String? title,
    String? sport,
    DateTime? startTime,
    int? durationMinutes,
    int? hypeScore,
    int? communityHype,
    String? broadcastChannel,
    String? dataSource,
    Map<String, dynamic>? metadata,
  }) {
    return HypeEvent(
      eventId: eventId ?? this.eventId,
      title: title ?? this.title,
      sport: sport ?? this.sport,
      startTime: startTime ?? this.startTime,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      hypeScore: hypeScore ?? this.hypeScore,
      communityHype: communityHype ?? this.communityHype,
      broadcastChannel: broadcastChannel ?? this.broadcastChannel,
      dataSource: dataSource ?? this.dataSource,
      metadata: metadata ?? this.metadata,
    );
  }

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
      communityHype: json['community_hype'] as int? ?? 0,
      broadcastChannel: json['broadcast_channel'] as String,
      dataSource: json['data_source'] as String?,
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
      'community_hype': communityHype,
      'broadcast_channel': broadcastChannel,
      'data_source': dataSource,
      'metadata': metadata,
    };
  }
}
