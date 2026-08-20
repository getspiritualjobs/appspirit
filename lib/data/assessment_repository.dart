import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import '../core/env.dart';
import '../core/models.dart';

class AssessmentRepository {
  AssessmentRepository({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;
  final _uuid = const Uuid();

  Future<String?> saveCompletedAssessment({
    required Map<String, int> responses,
    required List<GiftScore> giftScores,
  }) async {
    if (!Env.hasSupabase || responses.isEmpty || giftScores.isEmpty) {
      return null;
    }

    final assessmentId = _uuid.v4();
    final user = _client.auth.currentUser ??
        (await _client.auth.signInAnonymously()).user;
    final assessment = <String, dynamic>{
      'id': assessmentId,
      'completed_at': DateTime.now().toUtc().toIso8601String(),
    };

    if (user == null) {
      assessment['anonymous_session_id'] = _uuid.v4();
    } else {
      assessment['user_id'] = user.id;
    }

    await _client.from('assessments').insert(assessment);

    await _client.from('assessment_responses').insert([
      for (final entry in responses.entries)
        {
          'assessment_id': assessmentId,
          'question_id': entry.key,
          'response': entry.value,
        }
    ]);

    await _client.from('gift_scores').insert([
      for (final score in giftScores)
        {
          'assessment_id': assessmentId,
          'gift_id': score.gift.name,
          'raw_score': score.rawScore,
          'normalized_score': score.normalizedScore,
        }
    ]);

    if (user != null) {
      await _client.from('saved_results').insert({
        'user_id': user.id,
        'assessment_id': assessmentId,
        'title': 'My Spiritual Gifts',
      });
    }

    return assessmentId;
  }
}
