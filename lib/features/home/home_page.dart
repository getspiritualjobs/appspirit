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
                      Text('Your gifts were given for a reason.',
                          style: theme.textTheme.displayLarge),
                      const SizedBox(height: 18),
                      Text(
                        'Take the assessment and see where they lead. Free to start, seven minutes to your first result.',
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
                            style: FilledButton.styleFrom(
                              backgroundColor: BrandTokens.gold,
                              foregroundColor: BrandTokens.forest,
                            ),
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
          aspectRatio: compact ? .92 : 1.02,
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
            child: LayoutBuilder(
              builder: (context, size) {
                final w = size.maxWidth;
                final h = size.maxHeight;
                final points = _heroPathPoints(Size(w, h));
                return Stack(
                  children: [
                    const Positioned.fill(
                        child: CustomPaint(painter: _HeroPathPainter())),
                    _PositionedPathStop(
                      point: points[0],
                      offset: compact
                          ? const Offset(-34, 34)
                          : const Offset(-46, 38),
                      child: const _PathStop(
                        title: 'Quiz',
                        body: 'Seven quiet minutes.',
                      ),
                    ),
                    _PositionedPathStop(
                      point: points[1],
                      offset: compact
                          ? const Offset(-44, 34)
                          : const Offset(-46, 38),
                      child: const _PathStop(
                        title: 'Gifts',
                        body: 'What rises to the top.',
                      ),
                    ),
                    _PositionedPathStop(
                      point: points[2],
                      offset: compact
                          ? const Offset(-112, -104)
                          : const Offset(-122, -110),
                      child: const _PathStop(
                        title: 'Aligned jobs',
                        body: 'Work that fits the pattern.',
                      ),
                    ),
                    _PositionedPathStop(
                      point: points[3],
                      offset: compact
                          ? const Offset(-124, 36)
                          : const Offset(-154, 42),
                      child: const _PathStop(
                        title: 'Fulfillment',
                        body: 'A next step with purpose.',
                        accent: true,
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        );
      },
    );
  }
}

class _PositionedPathStop extends StatelessWidget {
  const _PositionedPathStop({
    required this.point,
    required this.offset,
    required this.child,
  });

  final Offset point;
  final Offset offset;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: point.dx + offset.dx,
      top: point.dy + offset.dy,
      child: child,
    );
  }
}

class _PathStop extends StatelessWidget {
  const _PathStop({
    required this.title,
    required this.body,
    this.accent = false,
  });

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
          Text(title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: BrandTokens.cream,
                    fontSize: 23,
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

    final points = _heroPathPoints(size);
    final path = Path()
      ..moveTo(points[0].dx, points[0].dy)
      ..cubicTo(size.width * .23, size.height * .33, size.width * .32,
          size.height * .76, points[1].dx, points[1].dy)
      ..cubicTo(size.width * .51, size.height * .58, size.width * .52,
          size.height * .36, points[2].dx, points[2].dy)
      ..cubicTo(size.width * .74, size.height * .20, size.width * .90,
          size.height * .30, points[3].dx, points[3].dy);

    final shadow = Paint()
      ..color = BrandTokens.ink.withValues(alpha: .20)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(path.shift(const Offset(0, 4)), shadow);

    final track = Paint()
      ..color = BrandTokens.cream.withValues(alpha: .30)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.6
      ..strokeCap = StrokeCap.round;
    _drawDashes(canvas, path, track, 18, 13);

    for (var i = 0; i < points.length; i++) {
      final point = points[i];
      canvas.drawCircle(
          point, 19, Paint()..color = BrandTokens.gold.withValues(alpha: .16));
      canvas.drawCircle(point, 13.5, Paint()..color = BrandTokens.gold);
      final number = TextPainter(
        text: TextSpan(
          text: '${i + 1}',
          style: const TextStyle(
            color: BrandTokens.forest,
            fontSize: 13,
            fontWeight: FontWeight.w900,
            height: 1,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      number.paint(canvas,
          Offset(point.dx - number.width / 2, point.dy - number.height / 2));
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

List<Offset> _heroPathPoints(Size size) {
  return [
    Offset(size.width * .15, size.height * .59),
    Offset(size.width * .43, size.height * .69),
    Offset(size.width * .66, size.height * .40),
    Offset(size.width * .88, size.height * .59),
  ];
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
