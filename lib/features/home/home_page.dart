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
    return SingleChildScrollView(
      child: Container(
        decoration: const BoxDecoration(color: BrandTokens.cream),
        child: PageBand(
          padding: const EdgeInsets.fromLTRB(20, 48, 20, 64),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final compact = constraints.maxWidth < 620;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const BrandEyebrow('Scripture-informed assessment'),
                  const SizedBox(height: 16),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 980),
                    child: Text(
                      'Your gifts were given for a reason.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        color: BrandTokens.ink,
                        fontSize: compact ? 48 : 88,
                        fontWeight: FontWeight.w900,
                        height: .95,
                      ),
                    ),
                  ),
                  const SizedBox(height: 22),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 760),
                    child: Text(
                      'Take the assessment and see where they lead. Free to start, seven minutes to your first result.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        color: BrandTokens.ink,
                        fontSize: compact ? 19 : 24,
                        fontWeight: FontWeight.w700,
                        height: 1.35,
                      ),
                    ),
                  ),
                  const SizedBox(height: 34),
                  const _HeroVisual(),
                  const SizedBox(height: 30),
                  Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 14,
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
        final compact = constraints.maxWidth < 620;
        final labelWidth = compact ? 118.0 : 230.0;
        return AspectRatio(
          aspectRatio: compact ? .70 : 2.18,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: BrandTokens.forest,
              borderRadius: BorderRadius.circular(compact ? 22 : 34),
              boxShadow: [
                BoxShadow(
                  color: BrandTokens.ink.withValues(alpha: .14),
                  blurRadius: 36,
                  offset: const Offset(0, 22),
                ),
              ],
            ),
            child: LayoutBuilder(
              builder: (context, size) {
                final panelSize = Size(size.maxWidth, size.maxHeight);
                final points = _heroPathPoints(panelSize);
                return Stack(
                  children: [
                    const Positioned.fill(
                        child: CustomPaint(painter: _HeroPathPainter())),
                    _PositionedPathStop(
                      point: points[0],
                      offset: compact
                          ? const Offset(-26, 34)
                          : const Offset(-70, 44),
                      panelSize: panelSize,
                      width: labelWidth,
                      child: _PathStop(
                        title: 'Quiz',
                        body: 'Seven quiet minutes.',
                        width: labelWidth,
                        compact: compact,
                      ),
                    ),
                    _PositionedPathStop(
                      point: points[1],
                      offset: compact
                          ? const Offset(-56, 36)
                          : const Offset(-82, 44),
                      panelSize: panelSize,
                      width: labelWidth,
                      child: _PathStop(
                        title: 'Gifts',
                        body: 'What rises to the top.',
                        width: labelWidth,
                        compact: compact,
                      ),
                    ),
                    _PositionedPathStop(
                      point: points[2],
                      offset: compact
                          ? const Offset(-92, -98)
                          : const Offset(-104, -128),
                      panelSize: panelSize,
                      width: labelWidth,
                      child: _PathStop(
                        title: 'Aligned jobs',
                        body: 'Work that fits the pattern.',
                        width: labelWidth,
                        compact: compact,
                      ),
                    ),
                    _PositionedPathStop(
                      point: points[3],
                      offset: compact
                          ? const Offset(-84, 34)
                          : const Offset(30, 42),
                      panelSize: panelSize,
                      width: labelWidth,
                      child: _PathStop(
                        title: 'Fulfillment',
                        body: 'A next step with purpose.',
                        accent: true,
                        width: labelWidth,
                        compact: compact,
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
    required this.panelSize,
    required this.width,
    required this.child,
  });

  final Offset point;
  final Offset offset;
  final Size panelSize;
  final double width;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final left =
        (point.dx + offset.dx).clamp(24.0, panelSize.width - width - 24);
    final top = (point.dy + offset.dy).clamp(24.0, panelSize.height - 96);
    return Positioned(
      left: left,
      top: top,
      child: child,
    );
  }
}

class _PathStop extends StatelessWidget {
  const _PathStop({
    required this.title,
    required this.body,
    required this.width,
    required this.compact,
    this.accent = false,
  });

  final String title;
  final String body;
  final double width;
  final bool compact;
  final bool accent;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(title,
              style: GoogleFonts.inter(
                color: BrandTokens.cream,
                fontSize: compact ? 21 : 38,
                fontWeight: FontWeight.w900,
                height: 1.02,
              )),
          const SizedBox(height: 5),
          Text(body,
              style: GoogleFonts.inter(
                color: const Color(0xFFE4DBC7),
                fontSize: compact ? 12 : 18,
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
