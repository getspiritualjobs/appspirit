import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../data/assessment_repository.dart';
import '../data/analytics_repository.dart';
import '../data/billing_service.dart';
import '../data/legal_acceptance_repository.dart';
import '../data/pending_assessment_storage.dart';
import '../data/saved_data_repository.dart';
import '../data/seed_data.dart';
import '../data/whop_pixel.dart';
import 'env.dart';
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
  int _lastProgressBucket = 0;

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
    _logAssessmentProgress();
    notifyListeners();
  }

  void acceptAssessmentConsent() {
    assessmentConsentAccepted = true;
    AnalyticsRepository().logEvent('assessment_consent_accepted');
    trackWhopEvent('quiz_started');
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
    _lastProgressBucket = 0;
    notifyListeners();
  }

  Future<void> persistPendingAssessmentForAuth() async {
    if (responses.isEmpty) return;
    await PendingAssessmentStorage().save(
      PendingAssessmentSnapshot(
        responses: Map<String, int>.from(responses),
        consentAccepted: assessmentConsentAccepted,
      ),
    );
  }

  Future<bool> restorePendingAssessmentFromDevice() async {
    if (hasResults) return false;

    final snapshot = await PendingAssessmentStorage().load();
    if (snapshot == null || snapshot.responses.isEmpty) return false;

    responses
      ..clear()
      ..addAll(snapshot.responses);
    assessmentConsentAccepted = snapshot.consentAccepted;
    if (responses.length == assessmentQuestions.length) {
      giftScores = scoreAssessment(assessmentQuestions, responses);
      careerMatches = matchCareers(
        careers: careers,
        giftScores: giftScores,
        preference: preference,
      );
      savedResult = List.unmodifiable(giftScores);
    }
    assessmentSaveError = null;
    notifyListeners();
    return true;
  }

  Future<bool> restorePendingAssessmentForSignedInUser() async {
    if (!Env.hasSupabase) return false;
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null || user.isAnonymous) return false;

    final storage = PendingAssessmentStorage();
    final snapshot = await storage.load();
    if (snapshot == null || snapshot.responses.isEmpty) return false;

    responses
      ..clear()
      ..addAll(snapshot.responses);
    assessmentConsentAccepted = snapshot.consentAccepted;
    giftScores = scoreAssessment(assessmentQuestions, responses);
    careerMatches = matchCareers(
      careers: careers,
      giftScores: giftScores,
      preference: preference,
    );
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
      await AnalyticsRepository().logEvent(
        'assessment_restored_after_auth',
        assessmentId: latestAssessmentId,
        properties: {
          'answered_count': responses.length,
          'top_gift': giftScores.isEmpty ? null : giftScores.first.gift.name,
        },
      );
      await refreshSavedData();
      await storage.clear();
      return true;
    } catch (error) {
      assessmentSaveError = error.toString();
      notifyListeners();
      return false;
    }
  }

  Future<void> completeAssessment() async {
    giftScores = scoreAssessment(assessmentQuestions, responses);
    careerMatches = matchCareers(
        careers: careers, giftScores: giftScores, preference: preference);
    savedResult = List.unmodifiable(giftScores);
    assessmentSaveError = null;
    await persistPendingAssessmentForAuth();
    notifyListeners();

    // The remote save, consent log and analytics take seconds and can stall,
    // and the account step needs none of them, so let them settle in the
    // background instead of holding up the redirect to signup.
    unawaited(_syncCompletedAssessment());
  }

  Future<void> _syncCompletedAssessment() async {
    final user =
        Env.hasSupabase ? Supabase.instance.client.auth.currentUser : null;
    // Until the visitor has a real account the result stays pending on the
    // device only. restorePendingAssessmentForSignedInUser() writes it under
    // their user id the moment they sign up, so there is nothing to gain from
    // creating a throwaway anonymous row here.
    final canSaveRemotely = user != null && !user.isAnonymous;
    try {
      if (canSaveRemotely) {
        latestAssessmentId =
            await AssessmentRepository().saveCompletedAssessment(
          responses: responses,
          giftScores: giftScores,
        );
        if (assessmentConsentAccepted && latestAssessmentId != null) {
          await LegalAcceptanceRepository()
              .logAssessmentConsent(assessmentId: latestAssessmentId!);
        }
        await refreshSavedData();
      }
      await AnalyticsRepository().logEvent(
        'assessment_completed',
        assessmentId: latestAssessmentId,
        properties: {
          'answered_count': responses.length,
          'top_gift': giftScores.isEmpty ? null : giftScores.first.gift.name,
          'top_score':
              giftScores.isEmpty ? null : giftScores.first.normalizedScore,
        },
      );
      trackWhopEvent(
        'quiz_completed',
        properties: {
          'answered_count': responses.length,
          if (giftScores.isNotEmpty) 'top_gift': giftScores.first.gift.name,
        },
      );
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

  void _logAssessmentProgress() {
    final answered = responses.length;
    final bucket = answered == 1
        ? 1
        : answered == assessmentQuestions.length
            ? assessmentQuestions.length
            : (answered ~/ 5) * 5;
    if (bucket <= 0 || bucket == _lastProgressBucket) return;
    _lastProgressBucket = bucket;
    AnalyticsRepository().logEvent(
      'assessment_progress',
      assessmentId: latestAssessmentId,
      properties: {
        'answered_count': answered,
        'total_count': assessmentQuestions.length,
        'progress_percent':
            (answered / assessmentQuestions.length * 100).round(),
      },
    );
  }
}
