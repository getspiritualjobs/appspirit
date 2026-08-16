import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/app_state.dart';
import '../../core/models.dart';
import '../../data/seed_data.dart';
import '../../widgets/responsive.dart';

class OpportunitiesPage extends StatelessWidget {
  const OpportunitiesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final jobs = demoJobs;
    return AnimatedBuilder(
      animation: appState,
      builder: (context, _) {
        final titles = appState.careerMatches.take(5).map((match) => match.career.title).join(', ');
        return SingleChildScrollView(
          child: PageBand(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Opportunities for You', style: Theme.of(context).textTheme.displayMedium),
                const SizedBox(height: 8),
                Text(
                  appState.hasResults
                      ? 'Searches can be generated from your highest-ranked careers: $titles.'
                      : 'Demo opportunities are shown until you complete the assessment and configure job API credentials.',
                ),
                const SizedBox(height: 18),
                const _JobSearchPanel(),
                const SizedBox(height: 20),
                for (final job in jobs) _JobCard(job: job),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _JobSearchPanel extends StatelessWidget {
  const _JobSearchPanel();

  @override
  Widget build(BuildContext context) {
    return InfoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Live job integrations', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          const Text('Adzuna and USAJOBS should be queried through the Supabase Edge Function at /functions/v1/search-jobs. Demo jobs remain available when credentials are missing.'),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: const [
              Chip(label: Text('Location')),
              Chip(label: Text('Remote')),
              Chip(label: Text('Salary')),
              Chip(label: Text('Full-time')),
              Chip(label: Text('Date posted')),
            ],
          ),
        ],
      ),
    );
  }
}

class _JobCard extends StatelessWidget {
  const _JobCard({required this.job});

  final JobListing job;

  @override
  Widget build(BuildContext context) {
    final saved = appState.isJobSaved(job);
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: InfoCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(job.title, style: Theme.of(context).textTheme.titleLarge),
                      Text('${job.company} · ${job.location}'),
                    ],
                  ),
                ),
                Text('${job.matchScore}% Match', style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.w900)),
              ],
            ),
            const SizedBox(height: 10),
            Text(job.salaryMin == null ? job.employmentType : '\$${job.salaryMin! ~/ 1000}k-\$${job.salaryMax! ~/ 1000}k · ${job.employmentType}'),
            const SizedBox(height: 10),
            Text(job.description),
            const SizedBox(height: 10),
            Text('Source: ${job.provider}', style: const TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: 14),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                FilledButton.icon(
                  onPressed: () => launchUrl(Uri.parse(job.applicationUrl), webOnlyWindowName: '_blank'),
                  icon: const Icon(Icons.open_in_new),
                  label: const Text('View Job'),
                ),
                OutlinedButton.icon(
                  onPressed: () => appState.toggleSavedJob(job),
                  icon: Icon(saved ? Icons.bookmark : Icons.bookmark_border),
                  label: Text(saved ? 'Saved' : 'Save'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
