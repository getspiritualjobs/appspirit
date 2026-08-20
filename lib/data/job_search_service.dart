import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/env.dart';
import '../core/models.dart';
import 'seed_data.dart';

class JobSearchResult {
  const JobSearchResult({
    required this.jobs,
    required this.source,
    this.message,
  });

  final List<JobListing> jobs;
  final JobSearchSource source;
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
          .toList();

      return JobSearchResult(
        jobs: jobs.isEmpty ? demoJobs : jobs,
        source: jobs.isEmpty ? JobSearchSource.demo : JobSearchSource.live,
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
    return JobListing(
      id: _asString(json['id'], fallback: title),
      provider: _asString(json['provider'], fallback: 'unknown'),
      title: title,
      company: _asString(json['company'], fallback: 'Unknown company'),
      location: _asString(json['location'], fallback: 'Location not listed'),
      description:
          _asString(json['description'], fallback: 'No description provided.'),
      salaryMin: _asInt(json['salaryMin']),
      salaryMax: _asInt(json['salaryMax']),
      employmentType:
          _asString(json['employmentType'], fallback: 'Not specified'),
      remote: json['remote'] == true,
      postedDate:
          DateTime.tryParse(_asString(json['postedDate'])) ?? DateTime.now(),
      applicationUrl: _asString(json['applicationUrl']),
      matchScore: _estimateJobMatch(title, careerMatches),
    );
  }

  int _estimateJobMatch(String title, List<CareerMatch> careerMatches) {
    if (careerMatches.isEmpty) return 82;
    for (final match in careerMatches) {
      final careerTitle = match.career.title.toLowerCase();
      final jobTitle = title.toLowerCase();
      if (jobTitle.contains(careerTitle) || careerTitle.contains(jobTitle)) {
        return match.score;
      }
    }
    return careerMatches.first.score.clamp(65, 94);
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
