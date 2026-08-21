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
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 430;
        return AspectRatio(
          aspectRatio: compact ? .92 : 1.08,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: BrandTokens.forest,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: BrandTokens.ink.withValues(alpha: .14),
                  blurRadius: 28,
                  offset: const Offset(0, 18),
                ),
              ],
            ),
            child: Stack(
              children: [
                const Positioned.fill(
                    child: CustomPaint(painter: _HeroPathPainter())),
                Positioned(
                  left: compact ? 24 : 34,
                  top: compact ? 30 : 34,
                  child: const _PathStop(
                    number: '01',
                    title: 'Quiz',
                    body: 'Seven quiet minutes.',
                  ),
                ),
                Positioned(
                  right: compact ? 24 : 38,
                  top: compact ? 108 : 78,
                  child: const _PathStop(
                    number: '02',
                    title: 'Gifts',
                    body: 'What rises to the top.',
                  ),
                ),
                Positioned(
                  left: compact ? 28 : 54,
                  bottom: compact ? 108 : 82,
                  child: const _PathStop(
                    number: '03',
                    title: 'Aligned jobs',
                    body: 'Work that fits the pattern.',
                  ),
                ),
                Positioned(
                  right: compact ? 24 : 34,
                  bottom: compact ? 28 : 34,
                  child: const _PathStop(
                    number: '04',
                    title: 'Fulfillment',
                    body: 'A next step with purpose.',
                    accent: true,
                  ),
                ),
              ],
            ),
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
    return SizedBox(
      width: 142,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(number,
              style: TextStyle(
                color: accent
                    ? BrandTokens.gold
                    : BrandTokens.gold.withValues(alpha: .84),
                fontSize: 12,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.3,
              )),
          const SizedBox(height: 7),
          Text(title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: BrandTokens.cream,
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    height: 1.02,
                  )),
          const SizedBox(height: 5),
          Text(body,
              style: const TextStyle(
                color: Color(0xFFE4DBC7),
                fontSize: 13,
                fontWeight: FontWeight.w600,
                height: 1.25,
              )),
        ],
      ),
    );
  }
}

class _HeroPathPainter extends CustomPainter {
  const _HeroPathPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final dotPaint = Paint()
      ..color = BrandTokens.cream.withValues(alpha: .055)
      ..style = PaintingStyle.fill;
    for (var y = 18.0; y < size.height; y += 28) {
      for (var x = 20.0; x < size.width; x += 30) {
        canvas.drawCircle(Offset(x, y), 1.15, dotPaint);
      }
    }

    final path = Path()
      ..moveTo(size.width * .12, size.height * .72)
      ..cubicTo(size.width * .24, size.height * .30, size.width * .42,
          size.height * .78, size.width * .54, size.height * .44)
      ..cubicTo(size.width * .64, size.height * .18, size.width * .82,
          size.height * .22, size.width * .90, size.height * .55);

    final shadow = Paint()
      ..color = BrandTokens.ink.withValues(alpha: .20)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(path.shift(const Offset(0, 4)), shadow);

    final track = Paint()
      ..color = BrandTokens.cream.withValues(alpha: .30)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;
    _drawDashes(canvas, path, track, 15, 11);

    final gold = Paint()
      ..color = BrandTokens.gold
      ..style = PaintingStyle.fill;
    for (final point in [
      Offset(size.width * .12, size.height * .72),
      Offset(size.width * .43, size.height * .57),
      Offset(size.width * .62, size.height * .32),
      Offset(size.width * .90, size.height * .55),
    ]) {
      canvas.drawCircle(point, 5.5, gold);
      canvas.drawCircle(
          point, 11, Paint()..color = BrandTokens.gold.withValues(alpha: .14));
    }
  }

  void _drawDashes(
      Canvas canvas, Path path, Paint paint, double dash, double gap) {
    for (final metric in path.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        canvas.drawPath(
          metric.extractPath(
              distance, (distance + dash).clamp(0, metric.length)),
          paint,
        );
        distance += dash + gap;
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
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
