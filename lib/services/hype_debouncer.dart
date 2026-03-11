import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hype_grid/services/hype_repository.dart';

class HypeDebouncer {
  static final HypeDebouncer _instance = HypeDebouncer._internal();
  factory HypeDebouncer() => _instance;
  HypeDebouncer._internal();

  final HypeRepository _repository = HypeRepository();
  final Map<String, Timer> _timers = {};
  final Map<String, int> _pendingTaps = {};

  static const int _maxDailyHypePerEvent = 5;
  static const Duration _debounceDuration = Duration(seconds: 2);

  /// Increment a hype locally and queue it for network batching.
  /// Returns the actual number of hypes accepted (could be 0 if limit reached).
  Future<int> increment(String eventId) async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now().toIso8601String().split('T')[0];
    final key = 'hype_${eventId}_$today';

    int currentHypes = prefs.getInt(key) ?? 0;

    if (currentHypes >= _maxDailyHypePerEvent) {
      return 0; // limit reached
    }

    // Increment local tracker
    await prefs.setInt(key, currentHypes + 1);

    // Track pending tap
    _pendingTaps[eventId] = (_pendingTaps[eventId] ?? 0) + 1;

    // Restart timer
    _timers[eventId]?.cancel();
    _timers[eventId] = Timer(_debounceDuration, () {
      _commitHype(eventId);
    });

    return 1;
  }

  void _commitHype(String eventId) {
    if (!_pendingTaps.containsKey(eventId)) return;

    final amount = _pendingTaps[eventId]!;
    if (amount > 0) {
      _repository.incrementCommunityHype(eventId, amount);
      _pendingTaps.remove(eventId);
    }
  }

  /// Cancels any pending timers and immediately sends remaining amounts.
  /// Useful for lifecycle events (app closing).
  void flushAll() {
    for (var eventId in _pendingTaps.keys.toList()) {
      _timers[eventId]?.cancel();
      _commitHype(eventId);
    }
  }
}
