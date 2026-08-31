import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/env.dart';
import '../core/models.dart';
import '../core/scoring.dart';
import 'seed_data.dart';

class SavedDataSnapshot {
  const SavedDataSnapshot({
    this.results = const [],
    this.careers = const [],
    this.jobs = const [],
    this.preference = const UserPreference(),
  });

  final List<SavedGiftResult> results;
  final List<CareerMatch> careers;
  final List<JobListing> jobs;
  final UserPreference preference;
}

class SavedDataRepository {
  SavedDataRepository({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;

  Future<SavedDataSnapshot> fetchSnapshot() async {
    if (!Env.hasSupabase) return const SavedDataSnapshot();
    final user = _client.auth.currentUser;
    if (user == null) return const SavedDataSnapshot();

    final results = await _fetchResults();
    final savedCareers = await _fetchCareers();
    final savedJobs = await _fetchJobs();
    final preference = await _fetchPreference();

    return SavedDataSnapshot(
      results: results,
      careers: savedCareers,
      jobs: savedJobs,
      preference: preference,
    );
  }

  Future<void> saveCareer(CareerMatch match) async {
    final user = _currentUser();
    if (user == null) return;

    await _client.from('saved_careers').upsert({
      'user_id': user.id,
      'career_id': match.career.id,
      'match_score': match.score,
    });
  }

  Future<void> removeCareer(Career career) async {
    final user = _client.auth.currentUser;
    if (!Env.hasSupabase || user == null) return;

    await _client
        .from('saved_careers')
        .delete()
        .eq('user_id', user.id)
        .eq('career_id', career.id);
  }

  Future<void> saveJob(JobListing job) async {
    final user = _currentUser();
    if (user == null) return;

    await _client.from('saved_jobs').upsert({
      'user_id': user.id,
      'external_job_id': job.id,
      'provider': job.provider,
      'title': job.title,
      'company': job.company,
      'location': job.location,
      'job_url': job.applicationUrl,
      'payload': _jobPayload(job),
    });
  }

  Future<void> removeJob(JobListing job) async {
    final user = _client.auth.currentUser;
    if (!Env.hasSupabase || user == null) return;

    await _client
        .from('saved_jobs')
        .delete()
        .eq('user_id', user.id)
        .eq('provider', job.provider)
        .eq('external_job_id', job.id);
  }

  Future<void> savePreference(UserPreference preference) async {
    final user = _currentUser();
    if (user == null) return;

    await _client.from('job_search_preferences').upsert({
      'user_id': user.id,
      'location': preference.location,
      'remote_preference': preference.remoteOnly ? 'remote' : 'any',
      'salary_min': preference.salaryMin,
      'employment_type': preference.employmentType,
      'interests': preference.interests.toList(),
      'values': preference.values.toList(),
      'updated_at': DateTime.now().toUtc().toIso8601String(),
    });
  }

  Future<List<SavedGiftResult>> _fetchResults() async {
    final rows = await _client
        .from('saved_results')
        .select('id,assessment_id,title,created_at')
        .order('created_at', ascending: false);

    final results = <SavedGiftResult>[];
    for (final row in rows) {
      final data = row.cast<String, dynamic>();
      final assessmentId = data['assessment_id'] as String;
      final scoreRows = await _client
          .from('gift_scores')
          .select('gift_id,raw_score,normalized_score')
          .eq('assessment_id', assessmentId)
          .order('normalized_score', ascending: false);

      results.add(SavedGiftResult(
        id: data['id'] as String,
        assessmentId: assessmentId,
        title: (data['title'] as String?) ?? 'My Spiritual Gifts',
        createdAt: DateTime.tryParse((data['created_at'] as String?) ?? '') ??
            DateTime.now(),
        scores: [
          for (final scoreRow in scoreRows)
            _giftScoreFromRow(scoreRow.cast<String, dynamic>())
        ],
      ));
    }

    return results;
  }

  Future<List<CareerMatch>> _fetchCareers() async {
    final rows = await _client
        .from('saved_careers')
        .select('career_id,match_score')
        .order('created_at', ascending: false);

    return [
      for (final row in rows)
        if (_careerById(row['career_id'] as String?) != null)
          _careerMatchFromRow(row.cast<String, dynamic>())
    ];
  }

  Future<List<JobListing>> _fetchJobs() async {
    final rows = await _client
        .from('saved_jobs')
        .select(
            'external_job_id,provider,title,company,location,job_url,payload,saved_at')
        .order('saved_at', ascending: false);

    return [
      for (final row in rows) _jobFromRow(row.cast<String, dynamic>()),
    ];
  }

  Future<UserPreference> _fetchPreference() async {
    final row = await _client
        .from('job_search_preferences')
        .select(
            'location,remote_preference,salary_min,employment_type,interests,values')
        .maybeSingle();
    if (row == null) return const UserPreference();

    final data = row.cast<String, dynamic>();
    return UserPreference(
      location: (data['location'] as String?) ?? '',
      remoteOnly: data['remote_preference'] == 'remote',
      salaryMin: data['salary_min'] as int?,
      employmentType: data['employment_type'] as String?,
      interests: _stringSet(data['interests']),
      values: _stringSet(data['values']),
    );
  }

  User? _currentUser() {
    if (!Env.hasSupabase) return null;
    final user = _client.auth.currentUser;
    if (user == null || user.isAnonymous) return null;
    return user;
  }

  GiftScore _giftScoreFromRow(Map<String, dynamic> row) {
    return GiftScore(
      gift: _giftKey((row['gift_id'] as String?) ?? ''),
      rawScore: (row['raw_score'] as num?)?.toDouble() ?? 0,
      normalizedScore: (row['normalized_score'] as num?)?.round() ?? 0,
    );
  }

  CareerMatch _careerMatchFromRow(Map<String, dynamic> row) {
    final career = _careerById(row['career_id'] as String?)!;
    final strongest = career.giftWeights.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final top = strongest.take(3).map((entry) => entry.key).toList();
    return CareerMatch(
      career: career,
      score: (row['match_score'] as num?)?.round() ?? 80,
      strongestGifts: top,
      reason:
          'Saved because this career matched your ${giftLabel(top.first)} profile.',
    );
  }

  Career? _careerById(String? id) {
    if (id == null) return null;
    for (final career in careers) {
      if (career.id == id) return career;
    }
    return null;
  }

  JobListing _jobFromRow(Map<String, dynamic> row) {
    final payload = row['payload'] is Map
        ? (row['payload'] as Map).cast<String, dynamic>()
        : <String, dynamic>{};
    return JobListing(
      id: (row['external_job_id'] as String?) ?? '',
      provider: (row['provider'] as String?) ?? 'unknown',
      title: (row['title'] as String?) ?? 'Untitled role',
      company: (row['company'] as String?) ?? 'Unknown company',
      location: (row['location'] as String?) ?? 'Location not listed',
      description:
          (payload['description'] as String?) ?? 'No description provided.',
      salaryMin: payload['salaryMin'] as int?,
      salaryMax: payload['salaryMax'] as int?,
      employmentType: (payload['employmentType'] as String?) ?? 'Not specified',
      remote: payload['remote'] == true,
      postedDate: DateTime.tryParse((payload['postedDate'] as String?) ?? '') ??
          DateTime.now(),
      applicationUrl: (row['job_url'] as String?) ?? '',
      matchScore: (payload['matchScore'] as int?) ?? 80,
    );
  }

  Map<String, dynamic> _jobPayload(JobListing job) {
    return {
      'description': job.description,
      'salaryMin': job.salaryMin,
      'salaryMax': job.salaryMax,
      'employmentType': job.employmentType,
      'remote': job.remote,
      'postedDate': job.postedDate.toIso8601String(),
      'matchScore': job.matchScore,
    };
  }

  GiftKey _giftKey(String value) {
    return GiftKey.values.firstWhere(
      (gift) => gift.name == value,
      orElse: () => GiftKey.serving,
    );
  }

  Set<String> _stringSet(Object? value) {
    if (value is List) return value.map((item) => item.toString()).toSet();
    return const {};
  }
}
