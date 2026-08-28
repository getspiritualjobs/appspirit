import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/env.dart';
import '../core/models.dart';
import 'seed_data.dart';

class JobSearchResult {
  const JobSearchResult({
    required this.jobs,
    required this.source,
    this.providers = const [],
    this.message,
  });

  final List<JobListing> jobs;
  final JobSearchSource source;
  final List<String> providers;
  final String? message;
}

enum JobSearchSource { live, demo, unavailable }

class JobSearchService {
  Future<JobSearchResult> search({
    required List<CareerMatch> careerMatches,
    String location = '',
    bool remoteOnly = false,
    int? salaryMin,
    String? employmentType,
  }) async {
    final titles = careerMatches.isEmpty
        ? [
            'Learning and Development Specialist',
            'Career Coach',
            'Nonprofit Program Manager'
          ]
        : careerMatches.take(5).map((match) => match.career.title).toList();

    if (!Env.hasSupabase) {
      return JobSearchResult(
        jobs: demoJobs,
        source: JobSearchSource.demo,
        message: 'Demo jobs are showing because Supabase is not configured.',
      );
    }

    try {
      final response = await Supabase.instance.client.functions.invoke(
        'search-jobs',
        body: {
          'titles': titles,
          if (location.trim().isNotEmpty) 'location': location.trim(),
          'remote': remoteOnly,
          if (salaryMin != null) 'salaryMin': salaryMin,
          if (employmentType != null && employmentType.isNotEmpty)
            'employmentType': employmentType,
        },
      );

      final data = response.data;
      if (data is! Map) {
        return JobSearchResult(
          jobs: demoJobs,
          source: JobSearchSource.demo,
          message:
              'Demo jobs are showing because the job API returned an unexpected response.',
        );
      }

      final rawJobs = data['jobs'];
      final providers = data['providers'] is List
          ? (data['providers'] as List).map((item) => item.toString()).toList()
          : const <String>[];
      if (rawJobs is! List || rawJobs.isEmpty) {
        return JobSearchResult(
          jobs: demoJobs,
          source: JobSearchSource.demo,
          message:
              'Demo jobs are showing until Adzuna or USAJOBS credentials are added to Supabase.',
        );
      }

      final jobs = rawJobs
          .whereType<Map>()
          .map((job) => _fromJson(job.cast<String, dynamic>(), careerMatches))
          .where((job) => !remoteOnly || job.remote)
          .toList()
        ..sort((a, b) => b.matchScore.compareTo(a.matchScore));

      return JobSearchResult(
        jobs: jobs.isEmpty ? demoJobs : jobs,
        source: jobs.isEmpty ? JobSearchSource.demo : JobSearchSource.live,
        providers: jobs.isEmpty ? const [] : providers,
        message: jobs.isEmpty
            ? 'No live jobs matched those filters, so demo jobs are showing.'
            : null,
      );
    } catch (error) {
      return JobSearchResult(
        jobs: demoJobs,
        source: JobSearchSource.demo,
        message:
            'Demo jobs are showing because the live job search is not deployed yet.',
      );
    }
  }

  JobListing _fromJson(
      Map<String, dynamic> json, List<CareerMatch> careerMatches) {
    final title = _asString(json['title']);
    final company = _asString(json['company'], fallback: 'Unknown company');
    final location =
        _asString(json['location'], fallback: 'Location not listed');
    final description =
        _asString(json['description'], fallback: 'No description provided.');
    return JobListing(
      id: _asString(json['id'], fallback: title),
      provider: _asString(json['provider'], fallback: 'unknown'),
      title: title,
      company: company,
      location: location,
      description: description,
      salaryMin: _asInt(json['salaryMin']),
      salaryMax: _asInt(json['salaryMax']),
      employmentType:
          _asString(json['employmentType'], fallback: 'Not specified'),
      remote: json['remote'] == true,
      postedDate:
          DateTime.tryParse(_asString(json['postedDate'])) ?? DateTime.now(),
      applicationUrl: _asString(json['applicationUrl']),
      matchScore: estimateJobMatchScore(
        title: title,
        company: company,
        description: description,
        matchedQuery: _asString(json['matchedQuery']),
        careerMatches: careerMatches,
      ),
    );
  }

  String _asString(Object? value, {String fallback = ''}) {
    if (value == null) return fallback;
    final text = value.toString().trim();
    return text.isEmpty ? fallback : text;
  }

  int? _asInt(Object? value) {
    if (value is int) return value;
    if (value is num) return value.round();
    return int.tryParse(value?.toString() ?? '');
  }
}

int estimateJobMatchScore({
  required String title,
  required String company,
  required String description,
  String matchedQuery = '',
  required List<CareerMatch> careerMatches,
}) {
  if (careerMatches.isEmpty) return 82;

  final haystack = _tokenize('$title $company $description');
  final searchableText = '$title $company $description'.toLowerCase();
  final queryTokens = _tokenize(matchedQuery);
  var bestScore = 0;

  for (var index = 0; index < careerMatches.length; index++) {
    final match = careerMatches[index];
    final career = match.career;
    final titleTokens = _tokenize(career.title);
    final contextTokens = _tokenize([
      career.category,
      career.description,
      career.environment,
      ...career.interests,
      ...career.values,
    ].join(' '));

    final titleOverlapCount = _overlapCount(titleTokens, haystack);
    final queryOverlapCount = _overlapCount(titleTokens, queryTokens);
    final hasStrongTitleOverlap =
        titleOverlapCount >= (titleTokens.length <= 1 ? 1 : 2);
    final hasStrongQueryOverlap =
        queryOverlapCount >= (titleTokens.length <= 1 ? 1 : 2);
    final titleOverlap =
        hasStrongTitleOverlap ? titleOverlapCount / titleTokens.length : 0.0;
    final queryOverlap =
        hasStrongQueryOverlap ? queryOverlapCount / titleTokens.length : 0.0;
    final contextOverlap = _overlapRatio(contextTokens, haystack);
    final exactTitleBoost =
        searchableText.contains(career.title.toLowerCase()) ? 10 : 0;
    final rankBoost = (5 - index).clamp(0, 5).toDouble();
    final careerBase = match.score *
        (hasStrongTitleOverlap || hasStrongQueryOverlap ? .68 : .52);

    final score = careerBase +
        (titleOverlap * 22) +
        (queryOverlap * 10) +
        (contextOverlap * 8) +
        exactTitleBoost +
        rankBoost;
    if (score.round() > bestScore) bestScore = score.round();
  }

  return bestScore.clamp(55, 99);
}

Set<String> _tokenize(String value) {
  const stopWords = {
    'and',
    'the',
    'for',
    'with',
    'from',
    'that',
    'this',
    'your',
    'you',
    'our',
    'are',
    'work',
    'job',
    'jobs',
    'role',
    'roles',
  };
  return value
      .toLowerCase()
      .replaceAll(RegExp(r'[^a-z0-9\s]'), ' ')
      .split(RegExp(r'\s+'))
      .where((word) => word.length > 2 && !stopWords.contains(word))
      .toSet();
}

double _overlapRatio(Set<String> needle, Set<String> haystack) {
  if (needle.isEmpty || haystack.isEmpty) return 0;
  return _overlapCount(needle, haystack) / needle.length;
}

int _overlapCount(Set<String> needle, Set<String> haystack) {
  return needle.where(haystack.contains).length;
}
