import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/app_state.dart';
import '../../core/models.dart';
import '../../core/scoring.dart';
import '../../widgets/brand_components.dart';
import '../../widgets/responsive.dart';

class SavedPage extends StatefulWidget {
  const SavedPage({super.key});

  @override
  State<SavedPage> createState() => _SavedPageState();
}

class _SavedPageState extends State<SavedPage> {
  @override
  void initState() {
    super.initState();
    appState.refreshSavedData();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: appState,
      builder: (context, _) {
        return DefaultTabController(
          length: 3,
          child: SingleChildScrollView(
            child: PageBand(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const BrandEyebrow('Private library'),
                  const SizedBox(height: 10),
                  Text('Saved',
                      style: Theme.of(context).textTheme.displayMedium),
                  const SizedBox(height: 8),
                  const Text(
                      'Keep the results, career paths, and jobs you want to revisit. Saved items stay private to your account.'),
                  if (appState.savedDataError != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      'Saved data is showing locally because sync failed.',
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                          fontWeight: FontWeight.w700),
                    ),
                  ],
                  const SizedBox(height: 18),
                  const TabBar(tabs: [
                    Tab(text: 'Results'),
                    Tab(text: 'Careers'),
                    Tab(text: 'Jobs')
                  ]),
                  SizedBox(
                    height: 620,
                    child: TabBarView(
                      children: [
                        _SavedResults(),
                        _SavedCareers(),
                        _SavedJobs(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _SavedResults extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final results = appState.savedResults;
    if (results.isEmpty && appState.savedResult.isEmpty) {
      return Center(
        child: EmptyState(
          icon: Icons.auto_awesome,
          title: 'No saved result yet',
          body:
              'Finish the assessment, then save the profile you want to keep.',
          action: FilledButton(
              onPressed: () => context.go('/results'),
              child: const Text('View Results')),
        ),
      );
    }
    if (results.isEmpty) {
      return ListView(
        padding: const EdgeInsets.only(top: 18),
        children: [
          _SavedResultCard(
              title: 'Current Gift Profile', scores: appState.savedResult)
        ],
      );
    }
    return ListView(
      padding: const EdgeInsets.only(top: 18),
      children: [
        for (final result in results)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _SavedResultCard(
              title: result.title,
              createdAt: result.createdAt,
              scores: result.scores,
            ),
          ),
      ],
    );
  }
}

class _SavedResultCard extends StatelessWidget {
  const _SavedResultCard({
    required this.title,
    required this.scores,
    this.createdAt,
  });

  final String title;
  final DateTime? createdAt;
  final List<GiftScore> scores;

  @override
  Widget build(BuildContext context) {
    return InfoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleLarge),
          if (createdAt != null) ...[
            const SizedBox(height: 4),
            Text(_dateLabel(createdAt!)),
          ],
          const SizedBox(height: 12),
          for (final score in scores.take(7))
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                  '${giftLabel(score.gift)}: ${score.normalizedScore}% alignment'),
            ),
        ],
      ),
    );
  }

  String _dateLabel(DateTime value) {
    final local = value.toLocal();
    return 'Saved ${local.month}/${local.day}/${local.year}';
  }
}

class _SavedCareers extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    if (appState.savedCareers.isEmpty) {
      return Center(
        child: EmptyState(
          icon: Icons.work_outline,
          title: 'No saved careers yet',
          body: 'Save the career matches that feel worth a second look.',
          action: FilledButton(
              onPressed: () => context.go('/careers'),
              child: const Text('Browse Careers')),
        ),
      );
    }
    return ListView(
      padding: const EdgeInsets.only(top: 18),
      children: [
        for (final match in appState.savedCareers)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: InfoCard(
              child: ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(match.career.title,
                    style: const TextStyle(fontWeight: FontWeight.w800)),
                subtitle:
                    Text('${match.score}% match · ${match.career.category}'),
                trailing: IconButton(
                  tooltip: 'Remove',
                  onPressed: () => appState.toggleSavedCareer(match),
                  icon: const Icon(Icons.delete_outline),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _SavedJobs extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    if (appState.savedJobs.isEmpty) {
      return Center(
        child: EmptyState(
          icon: Icons.search,
          title: 'No saved jobs yet',
          body:
              'Save open roles from the Opportunities page as you compare next steps.',
          action: FilledButton(
              onPressed: () => context.go('/opportunities'),
              child: const Text('See Opportunities')),
        ),
      );
    }
    return ListView(
      padding: const EdgeInsets.only(top: 18),
      children: [
        for (final job in appState.savedJobs)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: InfoCard(
              child: ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(job.title,
                    style: const TextStyle(fontWeight: FontWeight.w800)),
                subtitle:
                    Text('${job.company} · ${job.location} · ${job.provider}'),
                trailing: IconButton(
                  tooltip: 'Remove',
                  onPressed: () => appState.toggleSavedJob(job),
                  icon: const Icon(Icons.delete_outline),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
