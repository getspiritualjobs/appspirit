import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme.dart';
import '../../widgets/brand_components.dart';
import '../../widgets/responsive.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final viewportHeight = MediaQuery.sizeOf(context).height;
    return SingleChildScrollView(
      child: Container(
        decoration: const BoxDecoration(color: BrandTokens.cream),
        child: PageBand(
          padding: const EdgeInsets.fromLTRB(20, 28, 20, 34),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final compact = constraints.maxWidth < 620;
              final heroHeight = compact
                  ? (viewportHeight * .42).clamp(300.0, 430.0)
                  : (viewportHeight * .44).clamp(320.0, 430.0);
              return Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const BrandEyebrow('Scripture-informed assessment'),
                  const SizedBox(height: 10),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1040),
                    child: Text(
                      'Your gifts were given for a reason.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        color: BrandTokens.ink,
                        fontSize: compact ? 42 : 68,
                        fontWeight: FontWeight.w900,
                        height: .92,
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 760),
                    child: Text(
                      'Take the assessment and see where they lead. Free to start, seven minutes to your first result.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        color: BrandTokens.ink,
                        fontSize: compact ? 17 : 20,
                        fontWeight: FontWeight.w700,
                        height: 1.25,
                      ),
                    ),
                  ),
                  const SizedBox(height: 22),
                  compact
                      ? const _HeroVisual()
                      : SizedBox(
                          height: heroHeight,
                          width: double.infinity,
                          child: const _HeroVisual(),
                        ),
                  const SizedBox(height: 18),
                  Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 14,
                    runSpacing: 12,
                    children: [
                      FilledButton.icon(
                        onPressed: () => context.go('/assessment'),
                        icon: const Icon(Icons.arrow_forward),
                        label: const Text('Discover my gifts'),
                        style: FilledButton.styleFrom(
                          backgroundColor: BrandTokens.gold,
                          foregroundColor: BrandTokens.forest,
                        ),
                      ),
                      OutlinedButton.icon(
                        onPressed: () => context.go('/about'),
                        icon: const Icon(Icons.info_outline),
                        label: const Text('How it works'),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
        ),
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
        if (constraints.maxWidth < 620) return const _HeroVisualCompact();
        return const _HeroVisualWide();
      },
    );
  }
}

/// Desktop/tablet: labels float directly beside their node, the way the
/// brand mockup does. Each label box is *centered* on its node's x — at
/// this hero's actual node spacing (nodes sit at roughly 13/38/62/87% of
/// the panel width) a centered 220px-wide box never reaches a neighboring
/// node's box, so there's no need to guess pixel offsets per stop. Only
/// the peak (stop 3) needs to sit above rather than below; it's anchored
/// by its *bottom* edge so a 1- or 2-line title never collides with the
/// dot underneath it.
class _HeroVisualWide extends StatelessWidget {
  const _HeroVisualWide();

  static const _labelWidth = 220.0;
  static const _gap = 22.0;

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: BrandTokens.forest,
          borderRadius: BorderRadius.circular(BrandTokens.radiusLg),
          boxShadow: [
            BoxShadow(
              color: BrandTokens.ink.withValues(alpha: .14),
              blurRadius: 28,
              offset: const Offset(0, 16),
            ),
          ],
        ),
        child: LayoutBuilder(
          builder: (context, size) {
            final panelSize = Size(size.maxWidth, size.maxHeight);
            final points = _heroPathPoints(panelSize);

            Widget stop(int i, String title, String body,
                {bool accent = false, bool above = false}) {
              final p = points[i];
              final left = (p.dx - _labelWidth / 2)
                  .clamp(16.0, panelSize.width - _labelWidth - 16);
              return Positioned(
                left: left,
                top: above ? null : p.dy + _gap,
                bottom: above ? panelSize.height - p.dy + _gap : null,
                width: _labelWidth,
                child: _PathStop(title: title, body: body, accent: accent),
              );
            }

            return Stack(
              children: [
                const Positioned.fill(
                    child: CustomPaint(painter: _HeroPathPainter())),
                stop(0, 'Quiz', 'Seven quiet minutes.'),
                stop(1, 'Gifts', 'What rises to the top.'),
                stop(2, 'Aligned jobs', 'Work that fits the pattern.',
                    above: true),
                stop(3, 'Fulfillment', 'A next step with purpose.',
                    accent: true),
              ],
            );
          },
        ),
      ),
    );
  }
}

/// Mobile: at phone width, four nodes spaced across the panel sit too
/// close together for any floating label wide enough to read — there's
/// no offset that avoids collision when the labels themselves are wider
/// than the gap between nodes. Rather than fight that geometry, the path
/// stays purely decorative here and the four stops read as a plain,
/// unambiguous 2x2 grid underneath it.
class _HeroVisualCompact extends StatelessWidget {
  const _HeroVisualCompact();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: BrandTokens.forest,
        borderRadius: BorderRadius.circular(BrandTokens.radiusMd),
        boxShadow: [
          BoxShadow(
            color: BrandTokens.ink.withValues(alpha: .14),
            blurRadius: 22,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 22),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(
              height: 150,
              width: double.infinity,
              child: CustomPaint(painter: _HeroPathPainter()),
            ),
            const SizedBox(height: 20),
            const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                    child: _PathStop(
                        title: 'Quiz',
                        body: 'Seven quiet minutes.',
                        compact: true)),
                SizedBox(width: 14),
                Expanded(
                    child: _PathStop(
                        title: 'Gifts',
                        body: 'What rises to the top.',
                        compact: true)),
              ],
            ),
            const SizedBox(height: 18),
            const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                    child: _PathStop(
                        title: 'Aligned jobs',
                        body: 'Work that fits the pattern.',
                        compact: true)),
                SizedBox(width: 14),
                Expanded(
                    child: _PathStop(
                        title: 'Fulfillment',
                        body: 'A next step with purpose.',
                        accent: true,
                        compact: true)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _PathStop extends StatelessWidget {
  const _PathStop({
    required this.title,
    required this.body,
    this.compact = false,
    this.accent = false,
  });

  final String title;
  final String body;
  final bool compact;
  final bool accent;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(title,
            style: GoogleFonts.fraunces(
              color: accent ? BrandTokens.goldBright : BrandTokens.cream,
              fontSize: compact ? 18 : 26,
              fontWeight: FontWeight.w600,
              height: 1.05,
            )),
        const SizedBox(height: 5),
        Text(body,
            style: GoogleFonts.inter(
              color: const Color(0xFFE4DBC7),
              fontSize: compact ? 12 : 14.5,
              fontWeight: FontWeight.w600,
              height: 1.28,
            )),
      ],
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
      ..cubicTo(size.width * .22, size.height * .25, size.width * .29,
          size.height * .76, points[1].dx, points[1].dy)
      ..cubicTo(size.width * .47, size.height * .63, size.width * .49,
          size.height * .36, points[2].dx, points[2].dy)
      ..cubicTo(size.width * .72, size.height * .18, size.width * .89,
          size.height * .30, points[3].dx, points[3].dy);

    final shadow = Paint()
      ..color = BrandTokens.ink.withValues(alpha: .20)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(path.shift(const Offset(0, 4)), shadow);

    final track = Paint()
      ..color = BrandTokens.gold.withValues(alpha: .54)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.6
      ..strokeCap = StrokeCap.round;
    _drawDashes(canvas, path, track, 18, 13);

    for (var i = 0; i < points.length; i++) {
      final point = points[i];
      final large = size.width > 760;
      final haloRadius = large ? 27.0 : 19.0;
      final nodeRadius = large ? 18.0 : 13.5;
      canvas.drawCircle(point, haloRadius,
          Paint()..color = BrandTokens.gold.withValues(alpha: .16));
      canvas.drawCircle(point, nodeRadius, Paint()..color = BrandTokens.gold);
      final number = TextPainter(
        text: TextSpan(
          text: '${i + 1}',
          style: TextStyle(
            color: BrandTokens.forest,
            fontSize: large ? 18 : 13,
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
  if (size.width < 620) {
    return [
      Offset(size.width * .14, size.height * .56),
      Offset(size.width * .37, size.height * .66),
      Offset(size.width * .62, size.height * .38),
      Offset(size.width * .88, size.height * .54),
    ];
  }

  return [
    Offset(size.width * .13, size.height * .60),
    Offset(size.width * .38, size.height * .64),
    Offset(size.width * .62, size.height * .38),
    Offset(size.width * .87, size.height * .58),
  ];
}
