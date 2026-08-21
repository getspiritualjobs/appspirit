import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme.dart';
import '../../widgets/brand_components.dart';
import '../../widgets/responsive.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SingleChildScrollView(
      child: Column(
        children: [
          Container(
            decoration: const BoxDecoration(color: BrandTokens.cream),
            child: PageBand(
              padding: const EdgeInsets.fromLTRB(20, 56, 20, 36),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final wide = constraints.maxWidth > 760;
                  final heroText = Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const BrandEyebrow('Scripture-informed assessment'),
                      const SizedBox(height: 14),
                      Text('Discover your gifts. Find your path.',
                          style: theme.textTheme.displayLarge),
                      const SizedBox(height: 18),
                      Text(
                        'Answer one thoughtful question at a time, then see how your Romans 12 gift profile connects to careers, next steps, and real opportunities.',
                        style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w500, height: 1.45),
                      ),
                      const SizedBox(height: 26),
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: [
                          FilledButton.icon(
                            onPressed: () => context.go('/assessment'),
                            icon: const Icon(Icons.arrow_forward),
                            label: const Text('Discover My Gifts'),
                          ),
                          OutlinedButton.icon(
                            onPressed: () => context.go('/about'),
                            icon: const Icon(Icons.info_outline),
                            label: const Text('How It Works'),
                          ),
                        ],
                      ),
                    ],
                  );
                  const visual = _HeroVisual();
                  return wide
                      ? Row(children: [
                          Expanded(flex: 6, child: heroText),
                          const SizedBox(width: 36),
                          const Expanded(flex: 5, child: visual)
                        ])
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                              heroText,
                              const SizedBox(height: 28),
                              visual
                            ]);
                },
              ),
            ),
          ),
          PageBand(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const BrandDivider(),
                const SizedBox(height: 32),
                const BrandEyebrow('From reflection to action'),
                const SizedBox(height: 10),
                Text('A reflective path from giftedness to next steps',
                    style: theme.textTheme.headlineMedium),
                const SizedBox(height: 18),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final columns = constraints.maxWidth > 860
                        ? 4
                        : constraints.maxWidth > 560
                            ? 2
                            : 1;
                    return Stack(
                      children: [
                        if (columns == 4)
                          const Positioned.fill(
                            top: 30,
                            bottom: 42,
                            child: DashedPathConnector(),
                          ),
                        GridView.count(
                          crossAxisCount: columns,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisSpacing: 14,
                          mainAxisSpacing: 14,
                          childAspectRatio: columns == 1 ? 3.4 : 1.28,
                          children: const [
                            _JourneyStep('01', 'Discover',
                                'Take the spiritual gifts assessment without rushing the answer.'),
                            _JourneyStep('02', 'Understand',
                                'See the gifts that rose to the top and the language behind them.'),
                            _JourneyStep('03', 'Explore',
                                'Compare career paths through the full pattern of your scores.'),
                            _JourneyStep('04', 'Act',
                                'Open one free job match, then save the paths worth revisiting.'),
                          ],
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 26),
                const InfoCard(
                  child: Text(
                    'Spiritual gifts extend beyond occupation. Your results are designed to help you reflect on how your gifts may show up in work, church, relationships, family, volunteering, and community.',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroVisual extends StatelessWidget {
  const _HeroVisual();

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.0,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: .78),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
              color:
                  Theme.of(context).colorScheme.primary.withValues(alpha: .12)),
        ),
        child: const Stack(
          children: [
            Positioned.fill(
              left: 18,
              right: 18,
              top: 66,
              bottom: 70,
              child: DashedPathConnector(),
            ),
            Positioned(
                top: 34,
                left: 28,
                child: _MiniCard(
                    icon: Icons.menu_book_outlined,
                    label: 'Teaching',
                    value: '94%')),
            Positioned(
                top: 126,
                right: 26,
                child: _MiniCard(
                    icon: Icons.favorite_border,
                    label: 'Encouragement',
                    value: '88%')),
            Positioned(
                bottom: 34,
                left: 42,
                child: _MiniCard(
                    icon: Icons.work_outline,
                    label: 'Career Match',
                    value: '92%')),
          ],
        ),
      ),
    );
  }
}

class _MiniCard extends StatelessWidget {
  const _MiniCard(
      {required this.icon, required this.label, required this.value});

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: BrandTokens.forest, size: 28),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(label,
                    style: const TextStyle(fontWeight: FontWeight.w800)),
                Text(value,
                    style: const TextStyle(
                        color: BrandTokens.forest,
                        fontSize: 22,
                        fontWeight: FontWeight.w900)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _JourneyStep extends StatelessWidget {
  const _JourneyStep(this.number, this.title, this.body);

  final String number;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return InfoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(number,
              style: const TextStyle(
                  color: BrandTokens.gold,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.4)),
          const SizedBox(height: 8),
          Text(title, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 6),
          Text(body),
        ],
      ),
    );
  }
}
