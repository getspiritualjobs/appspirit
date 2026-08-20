import 'models.dart';

List<GiftScore> scoreAssessment(
  List<AssessmentQuestion> questions,
  Map<String, int> responses,
) {
  final raw = {for (final gift in GiftKey.values) gift: 0.0};
  final minPossible = {for (final gift in GiftKey.values) gift: 0.0};
  final maxPossible = {for (final gift in GiftKey.values) gift: 0.0};

  for (final question in questions) {
    final response = responses[question.id];
    if (response == null) continue;

    for (final weight in question.weights) {
      final value = weight.reverseScored ? 6 - response : response;
      final weighted = value * weight.weight;
      raw[weight.gift] = raw[weight.gift]! + weighted;
      minPossible[weight.gift] = minPossible[weight.gift]! + weight.weight;
      maxPossible[weight.gift] =
          maxPossible[weight.gift]! + (5 * weight.weight);
    }
  }

  return GiftKey.values.map((gift) {
    final min = minPossible[gift]!;
    final max = maxPossible[gift]!;
    final score = raw[gift]!;
    final normalized =
        max == min ? 0 : (((score - min) / (max - min)) * 100).round();
    return GiftScore(
      gift: gift,
      rawScore: score,
      normalizedScore: normalized.clamp(0, 100),
    );
  }).toList()
    ..sort((a, b) => b.normalizedScore.compareTo(a.normalizedScore));
}

List<CareerMatch> matchCareers({
  required List<Career> careers,
  required List<GiftScore> giftScores,
  UserPreference preference = const UserPreference(),
  int limit = 20,
}) {
  final scoreMap = {
    for (final score in giftScores) score.gift: score.normalizedScore
  };

  final matches = careers.map((career) {
    var weightedScore = 0.0;
    var totalWeight = 0.0;
    for (final entry in career.giftWeights.entries) {
      weightedScore += (scoreMap[entry.key] ?? 0) * entry.value;
      totalWeight += entry.value;
    }
    var finalScore = totalWeight == 0 ? 0.0 : weightedScore / totalWeight;

    final interestOverlap =
        career.interests.where(preference.interests.contains).length;
    final valueOverlap = career.values.where(preference.values.contains).length;
    finalScore += interestOverlap * 2.5;
    finalScore += valueOverlap * 2.0;
    if (preference.salaryMin != null &&
        career.salaryHigh >= preference.salaryMin!) {
      finalScore += 2.0;
    }

    final strongest = career.giftWeights.entries.toList()
      ..sort((a, b) {
        final aImpact = (scoreMap[a.key] ?? 0) * a.value;
        final bImpact = (scoreMap[b.key] ?? 0) * b.value;
        return bImpact.compareTo(aImpact);
      });

    final top = strongest.take(3).map((entry) => entry.key).toList();
    final reason =
        'Your ${giftLabel(top.first)} and ${giftLabel(top.length > 1 ? top[1] : top.first)} scores align with work centered on ${career.description.toLowerCase()}';

    return CareerMatch(
      career: career,
      score: finalScore.round().clamp(0, 100),
      strongestGifts: top,
      reason: reason,
    );
  }).toList()
    ..sort((a, b) => b.score.compareTo(a.score));

  return matches.take(limit).toList();
}

String giftLabel(GiftKey key) {
  return switch (key) {
    GiftKey.prophecy => 'Prophecy',
    GiftKey.serving => 'Serving',
    GiftKey.teaching => 'Teaching',
    GiftKey.encouragement => 'Encouragement',
    GiftKey.giving => 'Giving',
    GiftKey.leadership => 'Leadership',
    GiftKey.mercy => 'Mercy',
  };
}
