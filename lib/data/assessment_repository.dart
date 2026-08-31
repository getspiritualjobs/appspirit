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

    final user = _client.auth.currentUser;
    if (user == null || user.isAnonymous) return null;

    final assessmentId = _uuid.v4();
    final assessment = <String, dynamic>{
      'id': assessmentId,
      'completed_at': DateTime.now().toUtc().toIso8601String(),
      'user_id': user.id,
    };

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

    await _client.from('saved_results').insert({
      'user_id': user.id,
      'assessment_id': assessmentId,
      'title': 'My Spiritual Gifts',
    });

    return assessmentId;
  }
}
