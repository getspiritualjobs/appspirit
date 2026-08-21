import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme.dart';
import '../../widgets/brand_components.dart';
import '../../widgets/brand_mark.dart';
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
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 430;
        return SizedBox(
          height: compact ? 430 : 390,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned(
                left: compact ? 18 : 6,
                right: compact ? 18 : 24,
                top: compact ? 58 : 64,
                height: compact ? 260 : 210,
                child: const DashedPathConnector(),
              ),
              Positioned(
                left: compact ? 0 : 10,
                top: compact ? 10 : 6,
                child: const _PathStop(
                  number: '01',
                  title: 'Quiz',
                  body: 'Answer one honest prompt at a time.',
                ),
              ),
              Positioned(
                right: compact ? 0 : 16,
                top: compact ? 100 : 78,
                child: const _PathStop(
                  number: '02',
                  title: 'Gifts',
                  body: 'See the pattern that rises to the top.',
                ),
              ),
              Positioned(
                left: compact ? 0 : 34,
                bottom: compact ? 92 : 50,
                child: const _PathStop(
                  number: '03',
                  title: 'Aligned jobs',
                  body: 'Compare roles through your gift profile.',
                ),
              ),
              Positioned(
                right: compact ? 0 : 4,
                bottom: compact ? 2 : 10,
                child: const _PathStop(
                  number: '04',
                  title: 'Fulfillment',
                  body: 'Choose a next step you can actually take.',
                  accent: true,
                ),
              ),
              Positioned(
                left: compact ? 132 : 170,
                top: compact ? 202 : 172,
                child: GiftPathMark(size: compact ? 46 : 54),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _PathStop extends StatelessWidget {
  const _PathStop({
    required this.number,
    required this.title,
    required this.body,
    this.accent = false,
  });

  final String number;
  final String title;
  final String body;
  final bool accent;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
        child: SizedBox(
          width: 178,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(number,
                  style: TextStyle(
                    color: accent ? BrandTokens.gold : BrandTokens.forest,
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.2,
                  )),
              const SizedBox(height: 8),
              Text(title, style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 6),
              Text(body),
            ],
          ),
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
