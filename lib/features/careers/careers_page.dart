import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/app_state.dart';
import '../../core/models.dart';
import '../../core/theme.dart';
import '../../widgets/brand_components.dart';
import '../../widgets/gift_badge.dart';
import '../../widgets/responsive.dart';

class CareersPage extends StatelessWidget {
  const CareersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: appState,
      builder: (context, _) {
        if (!appState.hasResults) {
          return PageBand(
            maxWidth: 640,
            padding: const EdgeInsets.fromLTRB(20, 40, 20, 20),
            child: EmptyState(
              icon: Icons.work_outline,
              title: 'Career matches start with your gift profile',
              body:
                  'Take the assessment first so the full profile can influence your recommendations.',
              action: FilledButton(
                  onPressed: () => context.go('/assessment'),
                  child: const Text('Take Assessment')),
            ),
          );
        }

        return SingleChildScrollView(
          child: PageBand(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const BrandEyebrow('Career discovery'),
                const SizedBox(height: 10),
                Text('Careers for Your Gifts',
                    style: Theme.of(context).textTheme.displayMedium),
                const SizedBox(height: 8),
                const Text(
                    'These matches use your full gift profile, then adjust when you add interests and work preferences.'),
                const SizedBox(height: 18),
                _PreferencePanel(),
                const SizedBox(height: 20),
                for (var i = 0; i < appState.careerMatches.take(20).length; i++)
                  _CareerCard(
                    match: appState.careerMatches[i],
                    topMatch: i == 0,
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _PreferencePanel extends StatefulWidget {
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
          Text('Refine your matches',
              style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 10),
          const Text('What interests you?'),
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
          const Text("What's important in your next career?"),
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
          Align(
            alignment: Alignment.centerRight,
            child: FilledButton.icon(
              onPressed: () => appState.updatePreference(
                  UserPreference(interests: interests, values: values)),
              icon: const Icon(Icons.tune),
              label: const Text('Update Matches'),
            ),
          ),
        ],
      ),
    );
  }
}

class _CareerCard extends StatelessWidget {
  const _CareerCard({required this.match, required this.topMatch});

  final CareerMatch match;
  final bool topMatch;

  @override
  Widget build(BuildContext context) {
    final career = match.career;
    final saved = appState.isCareerSaved(career);
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
                      if (topMatch) ...[
                        const BrandEyebrow('Top match'),
                        const SizedBox(height: 6),
                      ],
                      Text(career.title,
                          style: Theme.of(context).textTheme.titleLarge),
                      Text(career.category),
                    ],
                  ),
                ),
                _MatchScore(score: match.score, topMatch: topMatch),
              ],
            ),
            const SizedBox(height: 10),
            Wrap(spacing: 8, runSpacing: 8, children: [
              for (final gift in match.strongestGifts)
                GiftBadge(gift, dense: true)
            ]),
            const SizedBox(height: 12),
            Text(match.reason),
            const SizedBox(height: 12),
            Text(
                '\$${career.salaryLow ~/ 1000}k-\$${career.salaryHigh ~/ 1000}k typical salary · ${career.educationRequirement}'),
            const SizedBox(height: 8),
            Text(career.description),
            const SizedBox(height: 14),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                OutlinedButton.icon(
                  onPressed: () => appState.toggleSavedCareer(match),
                  icon: Icon(saved ? Icons.bookmark : Icons.bookmark_border),
                  label: Text(saved ? 'Saved' : 'Save Career'),
                ),
                FilledButton.icon(
                  onPressed: () => context.go('/opportunities'),
                  icon: const Icon(Icons.search),
                  label: const Text('See Open Jobs'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MatchScore extends StatelessWidget {
  const _MatchScore({required this.score, required this.topMatch});

  final int score;
  final bool topMatch;

  @override
  Widget build(BuildContext context) {
    final color = topMatch ? BrandTokens.gold : BrandTokens.forest;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text('$score%',
            style: TextStyle(
              color: color,
              fontSize: 30,
              fontWeight: FontWeight.w900,
              height: 1,
            )),
        const SizedBox(height: 3),
        const Text('Match',
            style: TextStyle(
              color: BrandTokens.ink,
              fontSize: 12,
              fontWeight: FontWeight.w800,
            )),
      ],
    );
  }
}
