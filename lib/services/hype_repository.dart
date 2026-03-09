import 'package:hype_grid/model/hype_event.dart';
import 'package:hype_grid/services/supabase_service.dart';

class HypeRepository {
  final SupabaseService _supabaseService;

  HypeRepository({SupabaseService? supabaseService})
    : _supabaseService = supabaseService ?? SupabaseService();

  Future<List<HypeEvent>> fetchEvents() async {
    try {
      final response = await _supabaseService.client
          .from('hype_events')
          .select()
          .order('start_time', ascending: true);

      return (response as List)
          .map((data) => HypeEvent.fromJson(data))
          .toList();
    } catch (e) {
      // For now, let's rethrow to handle in BLoC
      rethrow;
    }
  }

  // Example for updating hype score if needed by the app
  Future<void> updateHypeScore(String eventId, int newScore) async {
    await _supabaseService.client
        .from('hype_events')
        .update({'hype_score': newScore})
        .eq('event_id', eventId);
  }
}
