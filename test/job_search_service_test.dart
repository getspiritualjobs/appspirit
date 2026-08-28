import 'package:flutter_test/flutter_test.dart';
import 'package:spiritual_gifts_career_discovery/core/models.dart';
import 'package:spiritual_gifts_career_discovery/data/job_search_service.dart';
import 'package:spiritual_gifts_career_discovery/data/seed_data.dart';

void main() {
  test('estimateJobMatchScore favors jobs related to matched careers', () {
    final learningCareer = careers.firstWhere(
      (career) => career.title == 'Learning and Development Specialist',
    );
    final unrelatedCareer = careers.firstWhere(
      (career) => career.title == 'Bookkeeper',
    );
    final matches = [
      CareerMatch(
        career: learningCareer,
        score: 93,
        strongestGifts: const [GiftKey.teaching, GiftKey.encouragement],
        reason: 'Teaching and encouragement alignment.',
      ),
      CareerMatch(
        career: unrelatedCareer,
        score: 72,
        strongestGifts: const [GiftKey.giving],
        reason: 'Giving alignment.',
      ),
    ];

    final relevant = estimateJobMatchScore(
      title: 'Learning and Development Specialist',
      company: 'Acme Health',
      description:
          'Design training programs, coach adult learners, and build practical curriculum.',
      matchedQuery: 'Learning and Development',
      careerMatches: matches,
    );
    final unrelated = estimateJobMatchScore(
      title: 'Payroll Analyst',
      company: 'Acme Health',
      description:
          'Review payroll files, reconcile reports, and support finance operations.',
      matchedQuery: 'Learning and Development',
      careerMatches: matches,
    );

    expect(relevant, greaterThan(unrelated));
    expect(relevant, greaterThanOrEqualTo(90));
  });

  test('estimateJobMatchScore does not over-rank loosely related jobs', () {
    final learningCareer = careers.firstWhere(
      (career) => career.title == 'Learning and Development Specialist',
    );
    final careerCoach = careers.firstWhere(
      (career) => career.title == 'Career Coach',
    );
    final matches = [
      CareerMatch(
        career: learningCareer,
        score: 96,
        strongestGifts: const [GiftKey.teaching, GiftKey.encouragement],
        reason: 'Teaching and encouragement alignment.',
      ),
      CareerMatch(
        career: careerCoach,
        score: 92,
        strongestGifts: const [GiftKey.encouragement, GiftKey.teaching],
        reason: 'Encouragement and teaching alignment.',
      ),
    ];

    final strongFit = estimateJobMatchScore(
      title: 'Senior Learning and Development Trainer',
      company: 'Acme',
      description:
          'Facilitate employee training, build curriculum, and coach adult learners.',
      matchedQuery: 'Learning and Development',
      careerMatches: matches,
    );
    final looseFit = estimateJobMatchScore(
      title: 'Personal Trainer',
      company: 'Live Fit Gym',
      description:
          'Coach clients through fitness programs, accountability, and healthy habits.',
      matchedQuery: 'Career Coach',
      careerMatches: matches,
    );

    expect(strongFit, greaterThanOrEqualTo(90));
    expect(looseFit, lessThan(strongFit));
    expect(looseFit, lessThanOrEqualTo(84));
  });
}
