import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/env.dart';
import '../core/legal_versions.dart';

class LegalAcceptanceRepository {
  LegalAcceptanceRepository({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;

  Future<void> logAccountConsent() async {
    await _logAcceptance(assessmentId: null);
  }

  Future<void> logAssessmentConsent({required String assessmentId}) async {
    if (assessmentId.isEmpty) return;
    await _logAcceptance(assessmentId: assessmentId);
  }

  Future<void> _logAcceptance({required String? assessmentId}) async {
    if (!Env.hasSupabase) return;

    final user = _client.auth.currentUser;
    if (user == null) return;

    await _client.from('legal_acceptances').insert({
      'user_id': user.id,
      if (assessmentId != null) 'assessment_id': assessmentId,
      'age_confirmed': true,
      'terms_version': termsVersion,
      'privacy_version': privacyVersion,
      'assessment_notice_version': assessmentNoticeVersion,
    });
  }
}
