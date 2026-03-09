import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:hype_grid/model/event_model.dart';

class SupabaseService {
  static final SupabaseService _instance = SupabaseService._internal();
  factory SupabaseService() => _instance;
  SupabaseService._internal();

  Future<void> initialize() async {
    await Supabase.initialize(
      url: dotenv.env['SUPABASE_URL'] ?? '',
      anonKey: dotenv.env['SUPABASE_ANON_KEY'] ?? '',
    );
  }

  SupabaseClient get client => Supabase.instance.client;

  Future<List<EventModel>> fetchEvents() async {
    final response = await client
        .from('hype_grid_events')
        .select()
        .order('start_time', ascending: true);

    return (response as List).map((json) => EventModel.fromJson(json)).toList();
  }
}
