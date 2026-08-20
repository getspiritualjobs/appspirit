import 'package:flutter/foundation.dart';

import '../data/assessment_repository.dart';
import '../data/billing_service.dart';
import '../data/seed_data.dart';
import 'models.dart';
import 'scoring.dart';

final appState = GiftPathState();

class GiftPathState extends ChangeNotifier {
  final Map<String, int> responses = {};
  List<GiftScore> giftScores = const [];
  List<CareerMatch> careerMatches = const [];
  UserPreference preference = const UserPreference();
  final List<CareerMatch> savedCareers = [];
  final List<JobListing> savedJobs = [];
  List<GiftScore> savedResult = const [];
  bool hasActiveSubscription = false;
  String? latestAssessmentId;
  String? assessmentSaveError;

  bool get isComplete => responses.length == assessmentQuestions.length;
  bool get hasResults => giftScores.isNotEmpty;
  List<GiftScore> get topThree => giftScores.take(3).toList();

  void answer(String questionId, int value) {
    responses[questionId] = value;
    notifyListeners();
  }

  Future<void> completeAssessment() async {
    giftScores = scoreAssessment(assessmentQuestions, responses);
    careerMatches = matchCareers(
        careers: careers, giftScores: giftScores, preference: preference);
    savedResult = List.unmodifiable(giftScores);
    assessmentSaveError = null;
    notifyListeners();

    try {
      latestAssessmentId = await AssessmentRepository().saveCompletedAssessment(
        responses: responses,
        giftScores: giftScores,
      );
    } catch (error) {
      assessmentSaveError = error.toString();
    }
    notifyListeners();
  }

  void updatePreference(UserPreference next) {
    preference = next;
    if (giftScores.isNotEmpty) {
      careerMatches = matchCareers(
          careers: careers, giftScores: giftScores, preference: preference);
    }
    notifyListeners();
  }

  void saveCurrentResult() {
    if (giftScores.isEmpty) return;
    savedResult = List.unmodifiable(giftScores);
    notifyListeners();
  }

  void toggleSavedCareer(CareerMatch match) {
    final index =
        savedCareers.indexWhere((item) => item.career.id == match.career.id);
    if (index >= 0) {
      savedCareers.removeAt(index);
    } else {
      savedCareers.add(match);
    }
    notifyListeners();
  }

  void toggleSavedJob(JobListing job) {
    final index = savedJobs.indexWhere(
        (item) => item.id == job.id && item.provider == job.provider);
    if (index >= 0) {
      savedJobs.removeAt(index);
    } else {
      savedJobs.add(job);
    }
    notifyListeners();
  }

  bool isCareerSaved(Career career) =>
      savedCareers.any((item) => item.career.id == career.id);

  bool isJobSaved(JobListing job) => savedJobs
      .any((item) => item.id == job.id && item.provider == job.provider);

  void activateSubscription() {
    hasActiveSubscription = true;
    notifyListeners();
  }

  Future<void> refreshSubscription() async {
    final active = await BillingService().hasActiveSubscription();
    if (active != hasActiveSubscription) {
      hasActiveSubscription = active;
      notifyListeners();
    }
  }
}
