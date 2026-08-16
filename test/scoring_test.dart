import 'package:flutter_test/flutter_test.dart';
import 'package:spiritual_gifts_career_discovery/core/models.dart';
import 'package:spiritual_gifts_career_discovery/core/scoring.dart';

void main() {
  test('scoreAssessment normalizes gift scores to 0-100', () {
    const questions = [
      AssessmentQuestion(
        id: 'q1',
        text: 'I enjoy teaching.',
        weights: [QuestionGiftWeight(gift: GiftKey.teaching, weight: 1)],
      ),
      AssessmentQuestion(
        id: 'q2',
        text: 'I enjoy serving.',
        weights: [QuestionGiftWeight(gift: GiftKey.serving, weight: 1)],
      ),
    ];

    final scores = scoreAssessment(questions, {'q1': 5, 'q2': 1});

    expect(scores.first.gift, GiftKey.teaching);
    expect(scores.first.normalizedScore, 100);
    expect(scores.last.normalizedScore, 0);
  });

  test('scoreAssessment supports reverse scoring', () {
    const questions = [
      AssessmentQuestion(
        id: 'q1',
        text: 'I avoid leading.',
        weights: [QuestionGiftWeight(gift: GiftKey.leadership, weight: 1, reverseScored: true)],
      ),
    ];

    final scores = scoreAssessment(questions, {'q1': 1});
    final leadership = scores.firstWhere((score) => score.gift == GiftKey.leadership);

    expect(leadership.normalizedScore, 100);
  });

  test('matchCareers uses the full gift profile and ranks best fit first', () {
    const giftScores = [
      GiftScore(gift: GiftKey.teaching, rawScore: 5, normalizedScore: 95),
      GiftScore(gift: GiftKey.encouragement, rawScore: 5, normalizedScore: 88),
      GiftScore(gift: GiftKey.leadership, rawScore: 5, normalizedScore: 75),
    ];
    const careers = [
      Career(
        id: 'trainer',
        title: 'Corporate Trainer',
        category: 'Education',
        description: 'helping adults learn.',
        salaryLow: 50000,
        salaryHigh: 90000,
        educationRequirement: 'Bachelor degree',
        responsibilities: [],
        environment: 'Hybrid',
        interests: ['Teaching'],
        values: ['Helping others'],
        giftWeights: {
          GiftKey.teaching: 95,
          GiftKey.encouragement: 85,
          GiftKey.leadership: 60,
        },
      ),
      Career(
        id: 'analyst',
        title: 'Compliance Analyst',
        category: 'Government',
        description: 'reviewing policies.',
        salaryLow: 50000,
        salaryHigh: 90000,
        educationRequirement: 'Bachelor degree',
        responsibilities: [],
        environment: 'Office',
        interests: ['Government'],
        values: ['Stability'],
        giftWeights: {
          GiftKey.prophecy: 95,
          GiftKey.serving: 70,
          GiftKey.teaching: 40,
        },
      ),
    ];

    final matches = matchCareers(careers: careers, giftScores: giftScores);

    expect(matches.first.career.id, 'trainer');
    expect(matches.first.score, greaterThan(matches.last.score));
  });
}
