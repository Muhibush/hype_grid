import 'package:hype_grid/model/hype_event.dart';
import 'package:hype_grid/services/supabase_service.dart';

class HypeRepository {
  final SupabaseService _supabaseService;

  HypeRepository({SupabaseService? supabaseService})
    : _supabaseService = supabaseService ?? SupabaseService();

  Future<List<HypeEvent>> fetchEvents() async {
    try {
      final response = await _supabaseService.client
          .from('hype_grid_events')
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

  Future<HypeEvent?> fetchEventById(String eventId) async {
    try {
      final response = await _supabaseService.client
          .from('hype_grid_events')
          .select()
          .eq('event_id', eventId)
          .maybeSingle();

      if (response == null) return null;
      return HypeEvent.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }

  // Example for updating hype score if needed by the app
  Future<void> updateHypeScore(String eventId, int newScore) async {
    await _supabaseService.client
        .from('hype_grid_events')
        .update({'hype_score': newScore})
        .eq('event_id', eventId);
  }

  Future<void> incrementCommunityHype(String eventId, int amount) async {
    try {
      await _supabaseService.client.rpc(
        'increment_community_hype',
        params: {'event_id_input': eventId, 'amount': amount},
      );
    } catch (e) {
      // Ignored for now. Can add proper error logging here.
    }
  }
}
