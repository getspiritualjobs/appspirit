import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/env.dart';
import 'blog_repository.dart';

class AdminDashboardRepository {
  const AdminDashboardRepository();

  SupabaseClient? get _client {
    if (!Env.hasSupabase) return null;
    return Supabase.instance.client;
  }

  Future<AdminDashboardState> load() async {
    final isAdmin = await const BlogRepository().isAdmin();
    if (!isAdmin) {
      return const AdminDashboardState(isAdmin: false);
    }

    final client = _client;
    if (client == null) {
      return const AdminDashboardState(
        isAdmin: true,
        error: 'Supabase is not configured in this build.',
      );
    }

    try {
      final since = DateTime.now()
          .toUtc()
          .subtract(const Duration(days: 30))
          .toIso8601String();

      final responses = await Future.wait([
        client
            .from('app_events')
            .select(
                'event_name,user_id,anonymous_session_id,properties,created_at')
            .gte('created_at', since)
            .order('created_at', ascending: false)
            .limit(5000),
        client
            .from('job_api_usage')
            .select(
                'provider,query,location,remote,cache_hit,http_status,result_count,deduped_count,duration_ms,error,created_at')
            .gte('created_at', since)
            .order('created_at', ascending: false)
            .limit(250),
        client
            .from('blog_posts')
            .select('status,created_at,published_at,updated_at')
            .order('updated_at', ascending: false)
            .limit(250),
      ]);

      final events = (responses[0] as List<dynamic>)
          .map((row) => AdminEvent.fromRow(Map<String, dynamic>.from(row)))
          .toList();
      final jobUsage = (responses[1] as List<dynamic>)
          .map((row) => JobApiUsageItem.fromRow(Map<String, dynamic>.from(row)))
          .toList();
      final blogPosts = (responses[2] as List<dynamic>)
          .map((row) => Map<String, dynamic>.from(row))
          .toList();

      return AdminDashboardState(
        isAdmin: true,
        funnel: AdminFunnelSummary.fromEvents(events),
        quizProgress: QuizProgressSummary.fromEvents(events),
        jobApi: JobApiSummary.fromUsage(jobUsage),
        blog: BlogAdminSummary.fromRows(blogPosts),
        recentEvents: events.take(14).toList(),
      );
    } catch (error) {
      return AdminDashboardState(
        isAdmin: true,
        error: 'Admin stats could not load: $error',
      );
    }
  }
}

class AdminDashboardState {
  const AdminDashboardState({
    required this.isAdmin,
    this.funnel = const AdminFunnelSummary(),
    this.quizProgress = const QuizProgressSummary(),
    this.jobApi = const JobApiSummary(),
    this.blog = const BlogAdminSummary(),
    this.recentEvents = const [],
    this.error,
  });

  final bool isAdmin;
  final AdminFunnelSummary funnel;
  final QuizProgressSummary quizProgress;
  final JobApiSummary jobApi;
  final BlogAdminSummary blog;
  final List<AdminEvent> recentEvents;
  final String? error;
}

class AdminFunnelSummary {
  const AdminFunnelSummary({
    this.quizStarts = 0,
    this.quizCompletions = 0,
    this.accountCreations = 0,
    this.checkoutStarts = 0,
    this.subscriptionStarts = 0,
    this.subscriptionCancels = 0,
    this.uniqueVisitors = 0,
  });

  final int quizStarts;
  final int quizCompletions;
  final int accountCreations;
  final int checkoutStarts;
  final int subscriptionStarts;
  final int subscriptionCancels;
  final int uniqueVisitors;

  int get quizCompletionRate =>
      quizStarts == 0 ? 0 : ((quizCompletions / quizStarts) * 100).round();

  int get accountConversionRate => quizCompletions == 0
      ? 0
      : ((accountCreations / quizCompletions) * 100).round();

  int get checkoutConversionRate => accountCreations == 0
      ? 0
      : ((checkoutStarts / accountCreations) * 100).round();

  static AdminFunnelSummary fromEvents(List<AdminEvent> events) {
    final quizStarterIds = <String>{};
    final visitorIds = <String>{};
    var completions = 0;
    var accountCreations = 0;
    var checkoutStarts = 0;
    var subscriptionStarts = 0;
    var subscriptionCancels = 0;

    for (final event in events) {
      visitorIds.add(event.identity);
      switch (event.name) {
        case 'assessment_progress':
          if (event.answeredCount >= 1) quizStarterIds.add(event.identity);
          break;
        case 'assessment_completed':
          completions += 1;
          break;
        case 'account_create_completed':
          accountCreations += 1;
          break;
        case 'checkout_started':
          checkoutStarts += 1;
          break;
        case 'subscription_started':
          subscriptionStarts += 1;
          break;
        case 'subscription_canceled':
          subscriptionCancels += 1;
          break;
      }
    }

    return AdminFunnelSummary(
      quizStarts: quizStarterIds.length,
      quizCompletions: completions,
      accountCreations: accountCreations,
      checkoutStarts: checkoutStarts,
      subscriptionStarts: subscriptionStarts,
      subscriptionCancels: subscriptionCancels,
      uniqueVisitors: visitorIds.length,
    );
  }
}

class QuizProgressSummary {
  const QuizProgressSummary({this.buckets = const []});

  final List<QuizProgressBucket> buckets;

  static QuizProgressSummary fromEvents(List<AdminEvent> events) {
    final progressByPerson = <String, int>{};
    for (final event
        in events.where((item) => item.name == 'assessment_progress')) {
      final current = progressByPerson[event.identity] ?? 0;
      if (event.answeredCount > current) {
        progressByPerson[event.identity] = event.answeredCount;
      }
    }

    final buckets = [
      QuizProgressBucket('Started', 0, 13),
      QuizProgressBucket('25%', 14, 27),
      QuizProgressBucket('50%', 28, 41),
      QuizProgressBucket('75%', 42, 55),
      QuizProgressBucket('Completed', 56, 56),
    ];

    for (final answered in progressByPerson.values) {
      for (final bucket in buckets) {
        if (answered >= bucket.minAnswered && answered <= bucket.maxAnswered) {
          bucket.people += 1;
          break;
        }
      }
    }

    return QuizProgressSummary(buckets: buckets);
  }
}

class QuizProgressBucket {
  QuizProgressBucket(this.label, this.minAnswered, this.maxAnswered);

  final String label;
  final int minAnswered;
  final int maxAnswered;
  int people = 0;
}

class JobApiSummary {
  const JobApiSummary({
    this.totalCalls = 0,
    this.cacheHits = 0,
    this.errors = 0,
    this.averageDurationMs = 0,
    this.averageResults = 0,
    this.recent = const [],
  });

  final int totalCalls;
  final int cacheHits;
  final int errors;
  final int averageDurationMs;
  final int averageResults;
  final List<JobApiUsageItem> recent;

  int get cacheHitRate =>
      totalCalls == 0 ? 0 : ((cacheHits / totalCalls) * 100).round();

  static JobApiSummary fromUsage(List<JobApiUsageItem> usage) {
    if (usage.isEmpty) return const JobApiSummary();
    final durations = usage.where((item) => item.durationMs != null).toList();
    final totalDuration =
        durations.fold<int>(0, (sum, item) => sum + (item.durationMs ?? 0));
    final totalResults =
        usage.fold<int>(0, (sum, item) => sum + item.resultCount);

    return JobApiSummary(
      totalCalls: usage.length,
      cacheHits: usage.where((item) => item.cacheHit).length,
      errors: usage.where((item) => item.error != null).length,
      averageDurationMs:
          durations.isEmpty ? 0 : (totalDuration / durations.length).round(),
      averageResults: (totalResults / usage.length).round(),
      recent: usage.take(10).toList(),
    );
  }
}

class JobApiUsageItem {
  const JobApiUsageItem({
    required this.provider,
    required this.query,
    required this.location,
    required this.cacheHit,
    required this.resultCount,
    required this.createdAt,
    this.dedupedCount,
    this.durationMs,
    this.httpStatus,
    this.error,
  });

  final String provider;
  final String query;
  final String location;
  final bool cacheHit;
  final int resultCount;
  final int? dedupedCount;
  final int? durationMs;
  final int? httpStatus;
  final String? error;
  final DateTime createdAt;

  factory JobApiUsageItem.fromRow(Map<String, dynamic> row) {
    return JobApiUsageItem(
      provider: row['provider']?.toString() ?? 'unknown',
      query: row['query']?.toString() ?? '',
      location: row['location']?.toString() ?? '',
      cacheHit: row['cache_hit'] == true,
      resultCount: _asInt(row['result_count']),
      dedupedCount:
          row['deduped_count'] == null ? null : _asInt(row['deduped_count']),
      durationMs:
          row['duration_ms'] == null ? null : _asInt(row['duration_ms']),
      httpStatus:
          row['http_status'] == null ? null : _asInt(row['http_status']),
      error: row['error']?.toString(),
      createdAt: DateTime.tryParse(row['created_at']?.toString() ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
    );
  }
}

class BlogAdminSummary {
  const BlogAdminSummary({this.published = 0, this.drafts = 0});

  final int published;
  final int drafts;

  static BlogAdminSummary fromRows(List<Map<String, dynamic>> rows) {
    return BlogAdminSummary(
      published: rows.where((row) => row['status'] == 'published').length,
      drafts: rows.where((row) => row['status'] == 'draft').length,
    );
  }
}

class AdminEvent {
  const AdminEvent({
    required this.name,
    required this.identity,
    required this.properties,
    required this.createdAt,
  });

  final String name;
  final String identity;
  final Map<String, dynamic> properties;
  final DateTime createdAt;

  int get answeredCount => _asInt(properties['answered_count']);

  factory AdminEvent.fromRow(Map<String, dynamic> row) {
    final userId = row['user_id']?.toString();
    final anonymousId = row['anonymous_session_id']?.toString();
    return AdminEvent(
      name: row['event_name']?.toString() ?? 'unknown',
      identity: (userId?.isNotEmpty ?? false)
          ? userId!
          : ((anonymousId?.isNotEmpty ?? false) ? anonymousId! : 'anonymous'),
      properties: Map<String, dynamic>.from(
        (row['properties'] as Map?) ?? {},
      ),
      createdAt: DateTime.tryParse(row['created_at']?.toString() ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
    );
  }
}

int _asInt(Object? value) {
  if (value is int) return value;
  if (value is num) return value.round();
  return int.tryParse(value?.toString() ?? '') ?? 0;
}
