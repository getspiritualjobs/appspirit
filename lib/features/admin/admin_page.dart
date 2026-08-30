import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme.dart';
import '../../data/admin_dashboard_repository.dart';
import '../../widgets/brand_components.dart';
import '../../widgets/responsive.dart';

class AdminPage extends StatefulWidget {
  const AdminPage({super.key});

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  final repository = const AdminDashboardRepository();
  late Future<AdminDashboardState> _dashboard;

  @override
  void initState() {
    super.initState();
    _dashboard = repository.load();
  }

  void _refresh() {
    setState(() => _dashboard = repository.load());
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<AdminDashboardState>(
      future: _dashboard,
      builder: (context, snapshot) {
        final data = snapshot.data;

        if (snapshot.connectionState != ConnectionState.done) {
          return const PageBand(
            maxWidth: 760,
            child: LinearProgressIndicator(minHeight: 3),
          );
        }

        if (data == null || !data.isAdmin) {
          return SingleChildScrollView(
            child: PageBand(
              maxWidth: 720,
              child: EmptyState(
                icon: Icons.lock_outline,
                eyebrow: 'Private admin',
                title: 'Admin access only',
                body:
                    'Sign in with the GiftPath editor account to post articles and view launch stats.',
                action: FilledButton(
                  onPressed: () => context.go('/auth?returnTo=/admin'),
                  child: const Text('Sign in'),
                ),
              ),
            ),
          );
        }

        return SingleChildScrollView(
          child: PageBand(
            maxWidth: 1180,
            padding: const EdgeInsets.fromLTRB(20, 34, 20, 56),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _AdminHeader(onRefresh: _refresh),
                if (data.error != null) ...[
                  const SizedBox(height: 18),
                  BrandNotice(
                    icon: Icons.warning_amber_rounded,
                    child: Text(data.error!),
                  ),
                ],
                const SizedBox(height: 24),
                _FunnelGrid(summary: data.funnel),
                const SizedBox(height: 24),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final wide = constraints.maxWidth >= 900;
                    final children = [
                      _QuizProgressCard(summary: data.quizProgress),
                      _JobApiCard(summary: data.jobApi),
                    ];
                    if (!wide) {
                      return Column(
                        children: [
                          for (final child in children) ...[
                            child,
                            const SizedBox(height: 18),
                          ],
                        ],
                      );
                    }
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: children[0]),
                        const SizedBox(width: 18),
                        Expanded(child: children[1]),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 24),
                _BlogTools(summary: data.blog),
                const SizedBox(height: 24),
                _RecentActivity(events: data.recentEvents),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _AdminHeader extends StatelessWidget {
  const _AdminHeader({required this.onRefresh});

  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    return InfoCard(
      padding: const EdgeInsets.all(28),
      child: Wrap(
        spacing: 18,
        runSpacing: 18,
        alignment: WrapAlignment.spaceBetween,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 680),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const BrandEyebrow('GiftPath launch room'),
                const SizedBox(height: 10),
                Text(
                  'Admin dashboard',
                  style: Theme.of(context).textTheme.displayMedium,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Post blog articles, watch the assessment funnel, and keep an eye on job API usage before ads start running.',
                ),
              ],
            ),
          ),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              FilledButton.icon(
                onPressed: () => context.go('/blog/new'),
                icon: const Icon(Icons.edit_note),
                label: const Text('New post'),
              ),
              OutlinedButton.icon(
                onPressed: onRefresh,
                icon: const Icon(Icons.refresh),
                label: const Text('Refresh'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FunnelGrid extends StatelessWidget {
  const _FunnelGrid({required this.summary});

  final AdminFunnelSummary summary;

  @override
  Widget build(BuildContext context) {
    final items = [
      _Metric(
        'Visitors',
        summary.uniqueVisitors.toString(),
        '30-day tracked identities',
      ),
      _Metric(
        'Quiz starts',
        summary.quizStarts.toString(),
        '${summary.quizCompletionRate}% complete',
      ),
      _Metric(
        'Quiz completions',
        summary.quizCompletions.toString(),
        'finished assessments',
      ),
      _Metric(
        'Accounts',
        summary.accountCreations.toString(),
        '${summary.accountConversionRate}% after quiz',
      ),
      _Metric(
        'Checkouts',
        summary.checkoutStarts.toString(),
        '${summary.checkoutConversionRate}% after account',
      ),
      _Metric(
        'Subscriptions',
        summary.subscriptionStarts.toString(),
        '${summary.subscriptionCancels} cancels logged',
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final columns = width >= 960 ? 3 : (width >= 620 ? 2 : 1);
        return GridView.count(
          crossAxisCount: columns,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 14,
          mainAxisSpacing: 14,
          childAspectRatio: columns == 1 ? 3.1 : 2.5,
          children: [for (final item in items) _MetricCard(metric: item)],
        );
      },
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({required this.metric});

  final _Metric metric;

  @override
  Widget build(BuildContext context) {
    return InfoCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            metric.label,
            style: const TextStyle(
              color: BrandTokens.forest,
              fontWeight: FontWeight.w900,
            ),
          ),
          const Spacer(),
          Text(
            metric.value,
            style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  color: BrandTokens.forest,
                  height: .95,
                ),
          ),
          const SizedBox(height: 6),
          Text(metric.note, style: const TextStyle(fontSize: 13)),
        ],
      ),
    );
  }
}

class _QuizProgressCard extends StatelessWidget {
  const _QuizProgressCard({required this.summary});

  final QuizProgressSummary summary;

  @override
  Widget build(BuildContext context) {
    final maxPeople = summary.buckets.fold<int>(
      1,
      (max, bucket) => bucket.people > max ? bucket.people : max,
    );
    return InfoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const BrandEyebrow('Assessment funnel'),
          const SizedBox(height: 8),
          Text(
            'Quiz progress',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 16),
          if (summary.buckets.every((bucket) => bucket.people == 0))
            const Text('No quiz progress events have been logged yet.')
          else
            for (final bucket in summary.buckets)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _ProgressRow(
                  label: bucket.label,
                  value: bucket.people,
                  progress: bucket.people / maxPeople,
                ),
              ),
        ],
      ),
    );
  }
}

class _ProgressRow extends StatelessWidget {
  const _ProgressRow({
    required this.label,
    required this.value,
    required this.progress,
  });

  final String label;
  final int value;
  final double progress;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 92,
          child: Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w800),
          ),
        ),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: LinearProgressIndicator(
              value: progress.clamp(0, 1),
              minHeight: 10,
              backgroundColor: BrandTokens.forest.withValues(alpha: .10),
            ),
          ),
        ),
        const SizedBox(width: 12),
        SizedBox(
          width: 34,
          child: Text(
            value.toString(),
            textAlign: TextAlign.right,
            style: const TextStyle(fontWeight: FontWeight.w900),
          ),
        ),
      ],
    );
  }
}

class _JobApiCard extends StatelessWidget {
  const _JobApiCard({required this.summary});

  final JobApiSummary summary;

  @override
  Widget build(BuildContext context) {
    return InfoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const BrandEyebrow('Adzuna health'),
          const SizedBox(height: 8),
          Text(
            'Job API usage',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _Pill('${summary.totalCalls} calls'),
              _Pill('${summary.cacheHitRate}% cached'),
              _Pill('${summary.errors} errors'),
              _Pill('${summary.averageDurationMs}ms avg'),
              _Pill('${summary.averageResults} avg results'),
            ],
          ),
          const SizedBox(height: 18),
          if (summary.recent.isEmpty)
            const Text('No job API calls have been logged yet.')
          else
            for (final item in summary.recent)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _JobUsageRow(item: item),
              ),
        ],
      ),
    );
  }
}

class _JobUsageRow extends StatelessWidget {
  const _JobUsageRow({required this.item});

  final JobApiUsageItem item;

  @override
  Widget build(BuildContext context) {
    final status = item.error == null
        ? (item.cacheHit ? 'cache' : 'live')
        : 'error ${item.httpStatus ?? ''}'.trim();
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          item.error == null ? Icons.check_circle_outline : Icons.error_outline,
          color: item.error == null
              ? BrandTokens.forest
              : Theme.of(context).colorScheme.error,
          size: 20,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${item.query.isEmpty ? 'job search' : item.query} · ${item.location.isEmpty ? 'anywhere' : item.location}',
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
              Text(
                '$status · ${item.resultCount} results'
                '${item.dedupedCount == null ? '' : ' · ${item.dedupedCount} after dedupe'}'
                '${item.durationMs == null ? '' : ' · ${item.durationMs}ms'}'
                ' · ${_dateTimeLabel(item.createdAt)}',
                style: const TextStyle(fontSize: 13),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _BlogTools extends StatelessWidget {
  const _BlogTools({required this.summary});

  final BlogAdminSummary summary;

  @override
  Widget build(BuildContext context) {
    return InfoCard(
      child: Wrap(
        spacing: 18,
        runSpacing: 18,
        alignment: WrapAlignment.spaceBetween,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 620),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const BrandEyebrow('Content'),
                const SizedBox(height: 8),
                Text(
                  'Blog publishing',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                Text(
                  '${summary.published} published posts and ${summary.drafts} drafts are in Supabase.',
                ),
              ],
            ),
          ),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              FilledButton.icon(
                onPressed: () => context.go('/blog/new'),
                icon: const Icon(Icons.add),
                label: const Text('Write post'),
              ),
              OutlinedButton.icon(
                onPressed: () => context.go('/blog'),
                icon: const Icon(Icons.article_outlined),
                label: const Text('Manage blog'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RecentActivity extends StatelessWidget {
  const _RecentActivity({required this.events});

  final List<AdminEvent> events;

  @override
  Widget build(BuildContext context) {
    return InfoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const BrandEyebrow('Latest signals'),
          const SizedBox(height: 8),
          Text(
            'Recent activity',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 14),
          if (events.isEmpty)
            const Text('No tracked app events have been logged yet.')
          else
            for (final event in events)
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.timeline_outlined),
                title: Text(_eventLabel(event.name)),
                subtitle: Text(_eventDetail(event)),
                trailing: Text(_dateTimeLabel(event.createdAt)),
              ),
        ],
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: BrandTokens.forest.withValues(alpha: .08),
        borderRadius: BorderRadius.circular(99),
        border: Border.all(color: BrandTokens.forest.withValues(alpha: .16)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Text(
          label,
          style: const TextStyle(
            color: BrandTokens.forest,
            fontWeight: FontWeight.w900,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}

class _Metric {
  const _Metric(this.label, this.value, this.note);

  final String label;
  final String value;
  final String note;
}

String _eventLabel(String name) {
  return switch (name) {
    'assessment_progress' => 'Quiz progress',
    'assessment_completed' => 'Quiz completed',
    'account_create_started' => 'Account started',
    'account_create_completed' => 'Account created',
    'checkout_started' => 'Checkout started',
    'subscription_started' => 'Subscription started',
    'subscription_canceled' => 'Subscription canceled',
    _ => name.replaceAll('_', ' '),
  };
}

String _eventDetail(AdminEvent event) {
  if (event.name == 'assessment_progress') {
    return '${event.answeredCount} of 56 answered';
  }
  if (event.properties.isEmpty) return 'No extra details';
  return event.properties.entries
      .take(3)
      .map((entry) => '${entry.key}: ${entry.value}')
      .join(' · ');
}

String _dateTimeLabel(DateTime date) {
  if (date.millisecondsSinceEpoch == 0) return '';
  final local = date.toLocal();
  final hour = local.hour % 12 == 0 ? 12 : local.hour % 12;
  final minute = local.minute.toString().padLeft(2, '0');
  final suffix = local.hour >= 12 ? 'PM' : 'AM';
  return '${local.month}/${local.day} $hour:$minute $suffix';
}
