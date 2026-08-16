import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/app_state.dart';
import '../../core/models.dart';
import '../../data/job_search_service.dart';
import '../../widgets/responsive.dart';

class OpportunitiesPage extends StatefulWidget {
  const OpportunitiesPage({super.key});

  @override
  State<OpportunitiesPage> createState() => _OpportunitiesPageState();
}

class _OpportunitiesPageState extends State<OpportunitiesPage> {
  final service = JobSearchService();
  final location = TextEditingController();
  JobSearchResult? result;
  var loading = false;
  var remoteOnly = false;

  @override
  void initState() {
    super.initState();
    _search();
  }

  @override
  void dispose() {
    location.dispose();
    super.dispose();
  }

  Future<void> _search() async {
    setState(() => loading = true);
    final next = await service.search(
      careerMatches: appState.careerMatches,
      location: location.text,
      remoteOnly: remoteOnly,
    );
    if (!mounted) return;
    setState(() {
      result = next;
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: appState,
      builder: (context, _) {
        final titles = appState.careerMatches.take(5).map((match) => match.career.title).join(', ');
        final jobs = result?.jobs ?? const <JobListing>[];
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
                _JobSearchPanel(
                  location: location,
                  remoteOnly: remoteOnly,
                  loading: loading,
                  result: result,
                  onRemoteChanged: (value) => setState(() => remoteOnly = value),
                  onSearch: _search,
                ),
                const SizedBox(height: 20),
                if (loading && jobs.isEmpty)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32),
                      child: CircularProgressIndicator(),
                    ),
                  )
                else
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
  const _JobSearchPanel({
    required this.location,
    required this.remoteOnly,
    required this.loading,
    required this.result,
    required this.onRemoteChanged,
    required this.onSearch,
  });

  final TextEditingController location;
  final bool remoteOnly;
  final bool loading;
  final JobSearchResult? result;
  final ValueChanged<bool> onRemoteChanged;
  final VoidCallback onSearch;

  @override
  Widget build(BuildContext context) {
    final live = result?.source == JobSearchSource.live;
    return InfoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text('Live job search', style: Theme.of(context).textTheme.titleLarge)),
              Chip(
                avatar: Icon(live ? Icons.cloud_done_outlined : Icons.data_object_outlined, size: 16),
                label: Text(live ? 'Live API' : 'Demo fallback'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(result?.message ?? 'Searches are generated from your highest-ranked career matches and routed through Supabase Edge Functions.'),
          const SizedBox(height: 12),
          LayoutBuilder(
            builder: (context, constraints) {
              final narrow = constraints.maxWidth < 620;
              final controls = [
                Expanded(
                  flex: narrow ? 0 : 1,
                  child: TextField(
                    controller: location,
                    decoration: const InputDecoration(
                      labelText: 'Location',
                      hintText: 'Phoenix, Remote, United States',
                      prefixIcon: Icon(Icons.place_outlined),
                    ),
                    onSubmitted: (_) => onSearch(),
                  ),
                ),
                FilterChip(
                  label: const Text('Remote only'),
                  selected: remoteOnly,
                  onSelected: onRemoteChanged,
                  avatar: const Icon(Icons.public, size: 18),
                ),
                FilledButton.icon(
                  onPressed: loading ? null : onSearch,
                  icon: loading
                      ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Icon(Icons.search),
                  label: const Text('Search Jobs'),
                ),
              ];
              return narrow
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        controls[0],
                        const SizedBox(height: 10),
                        Wrap(spacing: 10, runSpacing: 10, children: [controls[1], controls[2]]),
                      ],
                    )
                  : Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        controls[0],
                        const SizedBox(width: 10),
                        controls[1],
                        const SizedBox(width: 10),
                        controls[2],
                      ],
                    );
            },
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: const [
              Chip(label: Text('Adzuna ready')),
              Chip(label: Text('USAJOBS ready')),
              Chip(label: Text('Source links preserved')),
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
            Text(_salaryText(job)),
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
                  onPressed: job.applicationUrl.isEmpty ? null : () => launchUrl(Uri.parse(job.applicationUrl), webOnlyWindowName: '_blank'),
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

  String _salaryText(JobListing job) {
    if (job.salaryMin == null && job.salaryMax == null) return job.employmentType;
    if (job.salaryMax == null) return '\$${job.salaryMin! ~/ 1000}k+ · ${job.employmentType}';
    if (job.salaryMin == null) return 'Up to \$${job.salaryMax! ~/ 1000}k · ${job.employmentType}';
    return '\$${job.salaryMin! ~/ 1000}k-\$${job.salaryMax! ~/ 1000}k · ${job.employmentType}';
  }
}
