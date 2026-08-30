import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/app_state.dart';
import '../../core/models.dart';
import '../../core/theme.dart';
import '../../data/job_search_service.dart';
import '../../widgets/brand_components.dart';
import '../../widgets/brand_mark.dart';
import '../../widgets/gift_badge.dart';
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
  var stage = _OpportunityStage.careerLanes;
  final selectedCareerIds = <String>{};

  @override
  void initState() {
    super.initState();
    appState.refreshSubscription();
  }

  @override
  void dispose() {
    location.dispose();
    super.dispose();
  }

  Future<void> _search() async {
    setState(() => loading = true);
    final next = await service.search(
      careerMatches: _activeCareerMatches,
      location: location.text,
      remoteOnly: remoteOnly,
    );
    if (!mounted) return;
    setState(() {
      result = next;
      loading = false;
    });
  }

  List<CareerMatch> get _activeCareerMatches {
    final selected = appState.careerMatches
        .where((match) => selectedCareerIds.contains(match.career.id))
        .toList();
    return selected.isEmpty ? appState.careerMatches : selected;
  }

  void _toggleCareer(CareerMatch match) {
    setState(() {
      if (selectedCareerIds.contains(match.career.id)) {
        selectedCareerIds.remove(match.career.id);
      } else {
        selectedCareerIds.add(match.career.id);
      }
    });
  }

  Future<void> _goToJobs() async {
    setState(() => stage = _OpportunityStage.jobs);
    await _search();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: appState,
      builder: (context, _) {
        if (!appState.hasResults) {
          return PageBand(
            child: EmptyState(
              icon: Icons.assignment_outlined,
              title: 'Take the assessment first',
              body:
                  'Your free opportunity and premium job matches unlock after GiftPath has your gift and career profile.',
              action: FilledButton(
                onPressed: () => context.go('/assessment'),
                child: const Text('Start Assessment'),
              ),
            ),
          );
        }

        final titles = _activeCareerMatches
            .take(5)
            .map((match) => match.career.title)
            .join(', ');
        final jobs = result?.jobs ?? const <JobListing>[];
        final visibleJobs =
            appState.hasActiveSubscription ? jobs : jobs.take(1).toList();
        final lockedCount = appState.hasActiveSubscription
            ? 0
            : jobs.length - visibleJobs.length;
        return SingleChildScrollView(
          child: PageBand(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const BrandEyebrow('Matched opportunities'),
                const SizedBox(height: 10),
                Text('Opportunities',
                    style: Theme.of(context).textTheme.displayMedium),
                const SizedBox(height: 8),
                Text(
                  appState.hasActiveSubscription
                      ? 'Choose the career lanes you want to explore, refine the kind of work you want, then search live openings from those matches.'
                      : 'Pick the career lanes that interest you, refine the work, then see your first live job match free.',
                ),
                const SizedBox(height: 18),
                _OpportunityProgress(stage: stage),
                const SizedBox(height: 16),
                if (stage == _OpportunityStage.careerLanes)
                  _CareerFocusPanel(
                    selectedCareerIds: selectedCareerIds,
                    onToggleCareer: _toggleCareer,
                    onContinue: () =>
                        setState(() => stage = _OpportunityStage.refine),
                  )
                else if (stage == _OpportunityStage.refine)
                  _PreferencePanel(
                    onBack: () =>
                        setState(() => stage = _OpportunityStage.careerLanes),
                    onUpdated: _goToJobs,
                  )
                else ...[
                  _JobSearchPanel(
                    location: location,
                    remoteOnly: remoteOnly,
                    loading: loading,
                    result: result,
                    titles: titles,
                    onBack: () =>
                        setState(() => stage = _OpportunityStage.refine),
                    onRemoteChanged: (value) =>
                        setState(() => remoteOnly = value),
                    onSearch: _search,
                  ),
                  const SizedBox(height: 16),
                  _MatchExplanationPanel(
                      activeCareerMatches: _activeCareerMatches),
                  const SizedBox(height: 20),
                  if (loading && jobs.isEmpty)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(32),
                        child: CircularProgressIndicator(),
                      ),
                    )
                  else ...[
                    Text('Suggested live matches',
                        style: Theme.of(context).textTheme.headlineMedium),
                    const SizedBox(height: 12),
                    for (final job in visibleJobs) _JobCard(job: job),
                    if (lockedCount > 0) _UpgradeCard(lockedCount: lockedCount),
                  ],
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}

enum _OpportunityStage { careerLanes, refine, jobs }

class _OpportunityProgress extends StatelessWidget {
  const _OpportunityProgress({required this.stage});

  final _OpportunityStage stage;

  @override
  Widget build(BuildContext context) {
    final activeIndex = _OpportunityStage.values.indexOf(stage);
    const steps = [
      ('Career lanes', 'Choose the paths worth exploring.'),
      ('Refine', 'Name the work shape you want.'),
      ('Live jobs', 'Compare suggested openings.'),
    ];

    return InfoCard(
      padding: const EdgeInsets.all(16),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final narrow = constraints.maxWidth < 680;
          _ProgressStep buildStep(int index) => _ProgressStep(
                number: index + 1,
                title: steps[index].$1,
                body: steps[index].$2,
                active: index == activeIndex,
                complete: index < activeIndex,
              );

          if (narrow) {
            return Column(
              children: [
                for (var i = 0; i < steps.length; i++) ...[
                  SizedBox(width: double.infinity, child: buildStep(i)),
                  if (i != steps.length - 1) const SizedBox(height: 10),
                ],
              ],
            );
          }

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: buildStep(0)),
              const _ProgressConnector(),
              Expanded(child: buildStep(1)),
              const _ProgressConnector(),
              Expanded(child: buildStep(2)),
            ],
          );
        },
      ),
    );
  }
}

class _ProgressStep extends StatelessWidget {
  const _ProgressStep({
    required this.number,
    required this.title,
    required this.body,
    required this.active,
    required this.complete,
  });

  final int number;
  final String title;
  final String body;
  final bool active;
  final bool complete;

  @override
  Widget build(BuildContext context) {
    final color = complete || active ? BrandTokens.forest : BrandTokens.moss;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 34,
          height: 34,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: complete
                ? BrandTokens.forest
                : active
                    ? BrandTokens.gold
                    : BrandTokens.cream,
            shape: BoxShape.circle,
            border:
                Border.all(color: BrandTokens.forest.withValues(alpha: .22)),
          ),
          child: Text(
            '$number',
            style: TextStyle(
              color: complete ? BrandTokens.cream : BrandTokens.forest,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.w900,
                  )),
              const SizedBox(height: 2),
              Text(
                body,
                style: const TextStyle(fontSize: 13),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ProgressConnector extends StatelessWidget {
  const _ProgressConnector();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 52,
      height: 34,
      child: CustomPaint(
        painter: _ProgressConnectorPainter(),
      ),
    );
  }
}

class _ProgressConnectorPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = BrandTokens.gold.withValues(alpha: .62)
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    var x = 4.0;
    while (x < size.width - 4) {
      canvas.drawLine(
        Offset(x, size.height / 2),
        Offset((x + 8).clamp(0, size.width), size.height / 2),
        paint,
      );
      x += 14;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _UpgradeCard extends StatelessWidget {
  const _UpgradeCard({required this.lockedCount});

  final int lockedCount;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: InfoCard(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const IconBadge(Icons.lock_open_outlined, size: 46),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Unlock $lockedCount more matched jobs',
                      style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 6),
                  const Text(
                    'Open the full matching screen to compare plans and continue when you are ready.',
                  ),
                  const SizedBox(height: 14),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      FilledButton.icon(
                        onPressed: () => context.go('/subscribe'),
                        icon: const Icon(Icons.lock_open_outlined),
                        label: const Text('Unlock Full List'),
                      ),
                      const BrandEyebrow('One matched job is free'),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CareerFocusPanel extends StatelessWidget {
  const _CareerFocusPanel({
    required this.selectedCareerIds,
    required this.onToggleCareer,
    required this.onContinue,
  });

  final Set<String> selectedCareerIds;
  final ValueChanged<CareerMatch> onToggleCareer;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    final matches = appState.careerMatches.take(8).toList();
    final selectedCount = matches
        .where((match) => selectedCareerIds.contains(match.career.id))
        .length;
    return InfoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const IconBadge(Icons.route_outlined, size: 44),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Career lanes from your gifts',
                        style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 6),
                    Text(selectedCount == 0
                        ? 'Searches start from your strongest matches. Select one or more lanes to focus the live jobs.'
                        : '$selectedCount career ${selectedCount == 1 ? 'lane' : 'lanes'} selected for live job search.'),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          LayoutBuilder(
            builder: (context, constraints) {
              final columns = constraints.maxWidth >= 920
                  ? 4
                  : constraints.maxWidth >= 660
                      ? 2
                      : 1;
              return GridView.count(
                crossAxisCount: columns,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: columns == 1
                    ? 1.35
                    : columns == 2
                        ? 1.2
                        : 1.0,
                children: [
                  for (var i = 0; i < matches.length; i++)
                    _CareerFocusCard(
                      match: matches[i],
                      selected:
                          selectedCareerIds.contains(matches[i].career.id),
                      topMatch: i == 0,
                      onTap: () => onToggleCareer(matches[i]),
                    ),
                ],
              );
            },
          ),
          const SizedBox(height: 14),
          Align(
            alignment: Alignment.centerRight,
            child: OutlinedButton.icon(
              onPressed: onContinue,
              icon: const Icon(Icons.arrow_forward),
              label: const Text('Refine work preferences'),
            ),
          ),
        ],
      ),
    );
  }
}

class _CareerFocusCard extends StatelessWidget {
  const _CareerFocusCard({
    required this.match,
    required this.selected,
    required this.topMatch,
    required this.onTap,
  });

  final CareerMatch match;
  final bool selected;
  final bool topMatch;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final saved = appState.isCareerSaved(match.career);
    return Material(
      color: selected
          ? BrandTokens.forest.withValues(alpha: .08)
          : BrandTokens.cream.withValues(alpha: .55),
      borderRadius: BorderRadius.circular(BrandTokens.radiusSm),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(BrandTokens.radiusSm),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(BrandTokens.radiusSm),
            border: Border.all(
              color: selected
                  ? BrandTokens.forest
                  : BrandTokens.forest.withValues(alpha: .16),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    topMatch ? 'TOP MATCH' : '${match.score}% MATCH',
                    style: TextStyle(
                      color: topMatch ? BrandTokens.gold : BrandTokens.forest,
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    selected
                        ? Icons.radio_button_checked
                        : Icons.radio_button_unchecked,
                    size: 18,
                    color: BrandTokens.forest,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                match.career.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 4),
              Text(
                match.career.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const Spacer(),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  for (final gift in match.strongestGifts.take(2))
                    GiftBadge(gift, dense: true),
                  ActionChip(
                    avatar: Icon(
                      saved ? Icons.bookmark : Icons.bookmark_border,
                      size: 16,
                    ),
                    label: Text(saved ? 'Saved' : 'Save'),
                    onPressed: () => appState.toggleSavedCareer(match),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PreferencePanel extends StatefulWidget {
  const _PreferencePanel({required this.onBack, required this.onUpdated});

  final VoidCallback onBack;
  final VoidCallback onUpdated;

  @override
  State<_PreferencePanel> createState() => _PreferencePanelState();
}

class _PreferencePanelState extends State<_PreferencePanel> {
  final interests = <String>{...appState.preference.interests};
  final values = <String>{...appState.preference.values};

  static const allInterests = [
    'Helping people',
    'Teaching',
    'Technology',
    'Business',
    'Healthcare',
    'Creative work',
    'Working with my hands',
    'Leadership',
    'Numbers/data',
    'Communication',
    'Community impact',
    'Faith/ministry'
  ];
  static const allValues = [
    'High earning potential',
    'Work-life balance',
    'Helping others',
    'Remote work',
    'Stability',
    'Creativity',
    'Leadership opportunities',
    'Flexible schedule',
    'Mission-driven work'
  ];

  @override
  Widget build(BuildContext context) {
    return InfoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Refine the work you want to explore',
              style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          const Text(
              'These preferences re-rank your career lanes before the job search runs.'),
          const SizedBox(height: 14),
          const Text('Interests'),
          const SizedBox(height: 8),
          Wrap(spacing: 8, runSpacing: 8, children: [
            for (final item in allInterests)
              FilterChip(
                label: Text(item),
                selected: interests.contains(item),
                onSelected: (selected) => setState(() =>
                    selected ? interests.add(item) : interests.remove(item)),
              ),
          ]),
          const SizedBox(height: 14),
          const Text('Work values'),
          const SizedBox(height: 8),
          Wrap(spacing: 8, runSpacing: 8, children: [
            for (final item in allValues)
              FilterChip(
                label: Text(item),
                selected: values.contains(item),
                onSelected: (selected) => setState(
                    () => selected ? values.add(item) : values.remove(item)),
              ),
          ]),
          const SizedBox(height: 14),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              OutlinedButton.icon(
                onPressed: widget.onBack,
                icon: const Icon(Icons.arrow_back),
                label: const Text('Career lanes'),
              ),
              FilledButton.icon(
                onPressed: () async {
                  await appState.updatePreference(
                      UserPreference(interests: interests, values: values));
                  widget.onUpdated();
                },
                icon: const Icon(Icons.arrow_forward),
                label: const Text('See suggested jobs'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _JobSearchPanel extends StatelessWidget {
  const _JobSearchPanel({
    required this.location,
    required this.remoteOnly,
    required this.loading,
    required this.result,
    required this.titles,
    required this.onBack,
    required this.onRemoteChanged,
    required this.onSearch,
  });

  final TextEditingController location;
  final bool remoteOnly;
  final bool loading;
  final JobSearchResult? result;
  final String titles;
  final VoidCallback onBack;
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
              Expanded(
                  child: Text('Live job search',
                      style: Theme.of(context).textTheme.titleLarge)),
              TextButton.icon(
                onPressed: loading ? null : onBack,
                icon: const Icon(Icons.arrow_back, size: 18),
                label: const Text('Refine'),
              ),
              const SizedBox(width: 8),
              Chip(
                avatar: Icon(
                    live
                        ? Icons.cloud_done_outlined
                        : Icons.data_object_outlined,
                    size: 16),
                label: Text(live ? 'Live API' : 'Demo fallback'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(result?.message ??
              'Searching from: $titles. Requests run through Supabase so Adzuna keys stay off the client.'),
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
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2))
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
                        Wrap(
                            spacing: 10,
                            runSpacing: 10,
                            children: [controls[1], controls[2]]),
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
            children: [
              if (result?.providers.contains('adzuna') ?? false)
                const Chip(label: Text('Adzuna live')),
              if (result?.providers.contains('usajobs') ?? false)
                const Chip(label: Text('USAJOBS live')),
              if (live) const Chip(label: Text('Source links preserved')),
              if (!live) const Chip(label: Text('Demo listings')),
            ],
          ),
        ],
      ),
    );
  }
}

class _MatchExplanationPanel extends StatelessWidget {
  const _MatchExplanationPanel({required this.activeCareerMatches});

  final List<CareerMatch> activeCareerMatches;

  @override
  Widget build(BuildContext context) {
    final topCareers = activeCareerMatches
        .take(3)
        .map((match) => '${match.career.title} (${match.score}%)')
        .join(', ');
    return BrandNotice(
      icon: Icons.percent_outlined,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'How job match works',
            style: TextStyle(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 6),
          Text(
            'GiftPath starts with your selected career lanes${topCareers.isEmpty ? '' : ' - $topCareers'}. A job gets a higher score when its title or search query overlaps that career lane, its description shares words with the lane category, work environment, interests, and values, and the career lane itself ranked highly from your gift profile.',
          ),
          const SizedBox(height: 6),
          const Text(
            'It is a directional fit score, not a hiring prediction. Use it to decide what is worth opening first.',
            style: TextStyle(fontWeight: FontWeight.w700),
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
                      if (job.matchScore >= 90) ...[
                        const BrandEyebrow('Top match'),
                        const SizedBox(height: 6),
                      ],
                      Text(job.title,
                          style: Theme.of(context).textTheme.titleLarge),
                      Text('${job.company} · ${job.location}'),
                    ],
                  ),
                ),
                Text('${job.matchScore}% Match',
                    style: TextStyle(
                        color: job.matchScore >= 90
                            ? BrandTokens.gold
                            : BrandTokens.forest,
                        fontWeight: FontWeight.w900)),
              ],
            ),
            const SizedBox(height: 10),
            Text(_salaryText(job)),
            const SizedBox(height: 10),
            Text(job.description),
            const SizedBox(height: 10),
            Text('Source: ${job.provider}',
                style: const TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: 14),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                FilledButton.icon(
                  onPressed: job.applicationUrl.isEmpty
                      ? null
                      : () => launchUrl(Uri.parse(job.applicationUrl),
                          webOnlyWindowName: '_blank'),
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
    if (job.salaryMin == null && job.salaryMax == null) {
      return job.employmentType;
    }
    if (job.salaryMax == null) {
      return '\$${job.salaryMin! ~/ 1000}k+ · ${job.employmentType}';
    }
    if (job.salaryMin == null) {
      return 'Up to \$${job.salaryMax! ~/ 1000}k · ${job.employmentType}';
    }
    return '\$${job.salaryMin! ~/ 1000}k-\$${job.salaryMax! ~/ 1000}k · ${job.employmentType}';
  }
}
