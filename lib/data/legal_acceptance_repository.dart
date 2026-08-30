import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/env.dart';
import '../core/legal_versions.dart';

class LegalAcceptanceRepository {
  LegalAcceptanceRepository({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;

  Future<void> logAssessmentConsent({required String assessmentId}) async {
    if (!Env.hasSupabase || assessmentId.isEmpty) return;

    final user = _client.auth.currentUser;
    if (user == null) return;

    await _client.from('legal_acceptances').insert({
      'user_id': user.id,
      'assessment_id': assessmentId,
      'age_confirmed': true,
      'terms_version': termsVersion,
      'privacy_version': privacyVersion,
      'assessment_notice_version': assessmentNoticeVersion,
    });
  }
}
