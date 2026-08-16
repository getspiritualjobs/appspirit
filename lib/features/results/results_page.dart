import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/app_state.dart';
import '../../core/models.dart';
import '../../core/scoring.dart';
import '../../data/seed_data.dart';
import '../../widgets/gift_badge.dart';
import '../../widgets/responsive.dart';

class ResultsPage extends StatelessWidget {
  const ResultsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: appState,
      builder: (context, _) {
        if (!appState.hasResults) {
          return PageBand(
            child: EmptyState(
              icon: Icons.auto_awesome,
              title: 'Your results are waiting',
              body: 'Complete the assessment to see your strongest gift alignments and career matches.',
              action: FilledButton(onPressed: () => context.go('/assessment'), child: const Text('Start Assessment')),
            ),
          );
        }

        final top = appState.topThree;
        return SingleChildScrollView(
          child: PageBand(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Assessment Complete', style: Theme.of(context).textTheme.displayMedium),
                const SizedBox(height: 8),
                const Text("Here's how your gifts showed up. Your results are one lens for reflection in work, church, relationships, and community."),
                const SizedBox(height: 22),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final columns = constraints.maxWidth > 860 ? 3 : 1;
                    return GridView.count(
                      crossAxisCount: columns,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisSpacing: 14,
                      mainAxisSpacing: 14,
                      childAspectRatio: columns == 1 ? 2.2 : .92,
                      children: [
                        for (final score in top) _TopGiftCard(score: score),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 22),
                _ShareCard(top: top),
                const SizedBox(height: 22),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    FilledButton.icon(
                      onPressed: () => context.go('/careers'),
                      icon: const Icon(Icons.work_outline),
                      label: const Text('See where your gifts could take you'),
                    ),
                    OutlinedButton.icon(
                      onPressed: appState.saveCurrentResult,
                      icon: const Icon(Icons.bookmark_add_outlined),
                      label: const Text('Save Results'),
                    ),
                  ],
                ),
                const SizedBox(height: 28),
                Text('All Gift Alignments', style: Theme.of(context).textTheme.headlineMedium),
                const SizedBox(height: 12),
                for (final score in appState.giftScores) _ScoreRow(score),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _TopGiftCard extends StatelessWidget {
  const _TopGiftCard({required this.score});

  final GiftScore score;

  @override
  Widget build(BuildContext context) {
    final gift = gifts.firstWhere((item) => item.key == score.gift);
    return InfoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GiftBadge(score.gift),
          const SizedBox(height: 16),
          Text(gift.name, style: Theme.of(context).textTheme.headlineMedium),
          Text('${score.normalizedScore}% alignment', style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.w900)),
          const SizedBox(height: 12),
          Text(gift.shortDescription),
          const Spacer(),
          Text(gift.scripture, style: const TextStyle(fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

class _ShareCard extends StatelessWidget {
  const _ShareCard({required this.top});

  final List<GiftScore> top;

  @override
  Widget build(BuildContext context) {
    return InfoCard(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: const Color(0xFF203D35),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('My top spiritual gift alignments', style: TextStyle(color: Colors.white70, fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),
            Wrap(spacing: 10, runSpacing: 10, children: [for (final score in top) GiftBadge(score.gift)]),
            const SizedBox(height: 18),
            const Text(
              'Discover how you are gifted. Explore where those gifts could take you.',
              style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900),
            ),
          ],
        ),
      ),
    );
  }
}

class _ScoreRow extends StatelessWidget {
  const _ScoreRow(this.score);

  final GiftScore score;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          SizedBox(width: 150, child: Text(giftLabel(score.gift), style: const TextStyle(fontWeight: FontWeight.w800))),
          Expanded(child: LinearProgressIndicator(value: score.normalizedScore / 100, minHeight: 8)),
          const SizedBox(width: 12),
          Text('${score.normalizedScore}%'),
        ],
      ),
    );
  }
}
