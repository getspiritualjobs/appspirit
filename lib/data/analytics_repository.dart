import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/env.dart';

class AnalyticsRepository {
  AnalyticsRepository({SupabaseClient? client}) : _client = client;

  final SupabaseClient? _client;

  Future<void> logEvent(
    String name, {
    String? assessmentId,
    Map<String, Object?> properties = const {},
  }) async {
    if (!Env.hasSupabase) return;
    final client = _client ?? Supabase.instance.client;
    final user = client.auth.currentUser;
    try {
      await client.from('app_events').insert({
        'event_name': name,
        if (user != null) 'user_id': user.id,
        if (user?.isAnonymous ?? false) 'anonymous_session_id': user!.id,
        if (assessmentId != null) 'assessment_id': assessmentId,
        'properties': properties,
      });
    } catch (_) {
      // Analytics should never block assessment, auth, or payment flows.
    }
  }
}
