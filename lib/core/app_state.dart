import 'package:flutter/foundation.dart';

import '../data/assessment_repository.dart';
import '../data/billing_service.dart';
import '../data/legal_acceptance_repository.dart';
import '../data/saved_data_repository.dart';
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
  List<SavedGiftResult> savedResults = const [];
  List<GiftScore> savedResult = const [];
  bool hasActiveSubscription = false;
  String? latestAssessmentId;
  String? assessmentSaveError;
  String? savedDataError;
  bool assessmentConsentAccepted = false;

  bool get isComplete => responses.length == assessmentQuestions.length;
  bool get hasResults => giftScores.isNotEmpty;
  bool get hasCompletedAssessment =>
      hasResults || savedResults.isNotEmpty || savedResult.isNotEmpty;
  List<GiftScore> get topThree => giftScores.take(3).toList();

  void loadDemoAssessment() {
    responses
      ..clear()
      ..addEntries(assessmentQuestions.map((question) {
        final teachingWeight = question.weights
            .where((weight) => weight.gift == GiftKey.teaching)
            .fold<double>(0, (sum, weight) => sum + weight.weight);
        final encouragementWeight = question.weights
            .where((weight) => weight.gift == GiftKey.encouragement)
            .fold<double>(0, (sum, weight) => sum + weight.weight);
        final servingWeight = question.weights
            .where((weight) => weight.gift == GiftKey.serving)
            .fold<double>(0, (sum, weight) => sum + weight.weight);
        final response =
            teachingWeight + encouragementWeight + servingWeight > 0 ? 5 : 3;
        return MapEntry(question.id, response);
      }));
    giftScores = scoreAssessment(assessmentQuestions, responses);
    careerMatches = matchCareers(
        careers: careers, giftScores: giftScores, preference: preference);
    savedResult = List.unmodifiable(giftScores);
    assessmentSaveError = null;
    savedDataError = null;
    notifyListeners();
  }

  void answer(String questionId, int value) {
    responses[questionId] = value;
    notifyListeners();
  }

  void acceptAssessmentConsent() {
    assessmentConsentAccepted = true;
    notifyListeners();
  }

  void startRetake() {
    responses.clear();
    giftScores = const [];
    careerMatches = const [];
    savedResult = const [];
    latestAssessmentId = null;
    assessmentSaveError = null;
    assessmentConsentAccepted = false;
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
      if (assessmentConsentAccepted && latestAssessmentId != null) {
        await LegalAcceptanceRepository()
            .logAssessmentConsent(assessmentId: latestAssessmentId!);
      }
      await refreshSavedData();
    } catch (error) {
      assessmentSaveError = error.toString();
    }
    notifyListeners();
  }

  Future<void> updatePreference(UserPreference next) async {
    preference = next;
    if (giftScores.isNotEmpty) {
      careerMatches = matchCareers(
          careers: careers, giftScores: giftScores, preference: preference);
    }
    notifyListeners();
    try {
      await SavedDataRepository().savePreference(next);
    } catch (error) {
      savedDataError = error.toString();
      notifyListeners();
    }
  }

  void saveCurrentResult() {
    if (giftScores.isEmpty) return;
    savedResult = List.unmodifiable(giftScores);
    notifyListeners();
  }

  Future<void> toggleSavedCareer(CareerMatch match) async {
    final index =
        savedCareers.indexWhere((item) => item.career.id == match.career.id);
    if (index >= 0) {
      savedCareers.removeAt(index);
      notifyListeners();
      try {
        await SavedDataRepository().removeCareer(match.career);
      } catch (error) {
        savedDataError = error.toString();
        notifyListeners();
      }
    } else {
      savedCareers.add(match);
      notifyListeners();
      try {
        await SavedDataRepository().saveCareer(match);
      } catch (error) {
        savedDataError = error.toString();
        notifyListeners();
      }
    }
  }

  Future<void> toggleSavedJob(JobListing job) async {
    final index = savedJobs.indexWhere(
        (item) => item.id == job.id && item.provider == job.provider);
    if (index >= 0) {
      savedJobs.removeAt(index);
      notifyListeners();
      try {
        await SavedDataRepository().removeJob(job);
      } catch (error) {
        savedDataError = error.toString();
        notifyListeners();
      }
    } else {
      savedJobs.add(job);
      notifyListeners();
      try {
        await SavedDataRepository().saveJob(job);
      } catch (error) {
        savedDataError = error.toString();
        notifyListeners();
      }
    }
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

  Future<void> refreshSavedData() async {
    try {
      final snapshot = await SavedDataRepository().fetchSnapshot();
      savedResults = snapshot.results;
      savedCareers
        ..clear()
        ..addAll(snapshot.careers);
      savedJobs
        ..clear()
        ..addAll(snapshot.jobs);
      preference = snapshot.preference;
      if (snapshot.results.isNotEmpty) {
        savedResult = List.unmodifiable(snapshot.results.first.scores);
        if (giftScores.isEmpty) {
          giftScores = List.unmodifiable(snapshot.results.first.scores);
          careerMatches = matchCareers(
            careers: careers,
            giftScores: giftScores,
            preference: preference,
          );
          latestAssessmentId = snapshot.results.first.assessmentId;
        }
      }
      savedDataError = null;
    } catch (error) {
      savedDataError = error.toString();
    }
    notifyListeners();
  }
}
