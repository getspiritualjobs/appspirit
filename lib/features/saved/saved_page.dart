import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/app_state.dart';
import '../../core/scoring.dart';
import '../../widgets/responsive.dart';

class SavedPage extends StatelessWidget {
  const SavedPage({super.key});

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
                  Text('Saved', style: Theme.of(context).textTheme.displayMedium),
                  const SizedBox(height: 8),
                  const Text('Saved results, career matches, and jobs are private to your account when Supabase Auth is configured.'),
                  const SizedBox(height: 18),
                  const TabBar(tabs: [Tab(text: 'Results'), Tab(text: 'Careers'), Tab(text: 'Jobs')]),
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
    if (appState.savedResult.isEmpty) {
      return Center(
        child: EmptyState(
          icon: Icons.auto_awesome,
          title: 'No saved result yet',
          body: 'Save your result after finishing the assessment.',
          action: FilledButton(onPressed: () => context.go('/results'), child: const Text('View Results')),
        ),
      );
    }
    return ListView(
      padding: const EdgeInsets.only(top: 18),
      children: [
        InfoCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Saved Gift Profile', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 12),
              for (final score in appState.savedResult.take(7))
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text('${giftLabel(score.gift)}: ${score.normalizedScore}% alignment'),
                ),
            ],
          ),
        ),
      ],
    );
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
          body: 'Save career matches you want to revisit.',
          action: FilledButton(onPressed: () => context.go('/careers'), child: const Text('Browse Careers')),
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
                title: Text(match.career.title, style: const TextStyle(fontWeight: FontWeight.w800)),
                subtitle: Text('${match.score}% match · ${match.career.category}'),
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
          body: 'Save jobs from the Opportunities page.',
          action: FilledButton(onPressed: () => context.go('/opportunities'), child: const Text('See Opportunities')),
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
                title: Text(job.title, style: const TextStyle(fontWeight: FontWeight.w800)),
                subtitle: Text('${job.company} · ${job.location} · ${job.provider}'),
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
