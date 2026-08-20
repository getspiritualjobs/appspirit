import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../core/theme.dart';

class BrandEyebrow extends StatelessWidget {
  const BrandEyebrow(this.label, {super.key});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label.toUpperCase(),
      style: GoogleFonts.inter(
        color: BrandTokens.gold,
        fontSize: 12,
        fontWeight: FontWeight.w900,
        letterSpacing: 1.8,
      ),
    );
  }
}

class BrandDivider extends StatelessWidget {
  const BrandDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _rule(),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 14),
          child: Text(
            '◆',
            style: TextStyle(color: BrandTokens.gold, fontSize: 13),
          ),
        ),
        _rule(),
      ],
    );
  }

  Widget _rule() {
    return Container(
      width: 84,
      height: 1,
      color: BrandTokens.gold.withValues(alpha: .58),
    );
  }
}

class DashedPathProgress extends StatelessWidget {
  const DashedPathProgress({
    required this.total,
    required this.currentIndex,
    required this.answered,
    super.key,
  });

  final int total;
  final int currentIndex;
  final int answered;

  @override
  Widget build(BuildContext context) {
    final progress = total <= 1 ? 1.0 : (currentIndex + 1) / total;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 42,
          width: double.infinity,
          child: CustomPaint(
            painter: _DashedPathPainter(
              progress: progress.clamp(0, 1),
              color: BrandTokens.forest,
              accent: BrandTokens.gold,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '$answered of $total answered',
          style: const TextStyle(
            color: BrandTokens.forest,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}

class DashedPathConnector extends StatelessWidget {
  const DashedPathConnector({super.key});

  @override
  Widget build(BuildContext context) {
    return const IgnorePointer(
      child: CustomPaint(
        painter: _DashedPathPainter(
          progress: 1,
          color: BrandTokens.forest,
          accent: BrandTokens.gold,
          subtle: true,
        ),
        size: Size.infinite,
      ),
    );
  }
}

class BrandNotice extends StatelessWidget {
  const BrandNotice({
    required this.icon,
    required this.child,
    this.accent = false,
    super.key,
  });

  final IconData icon;
  final Widget child;
  final bool accent;

  @override
  Widget build(BuildContext context) {
    final color = accent ? BrandTokens.gold : BrandTokens.forest;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color.withValues(alpha: accent ? .12 : .08),
        borderRadius: const BorderRadius.all(Radius.circular(8)),
        border: Border.all(color: color.withValues(alpha: .16)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(width: 12),
            Expanded(child: child),
          ],
        ),
      ),
    );
  }
}

class _DashedPathPainter extends CustomPainter {
  const _DashedPathPainter({
    required this.progress,
    required this.color,
    required this.accent,
    this.subtle = false,
  });

  final double progress;
  final Color color;
  final Color accent;
  final bool subtle;

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(0, size.height * .58)
      ..cubicTo(size.width * .22, size.height * .08, size.width * .34,
          size.height * .92, size.width * .53, size.height * .44)
      ..cubicTo(size.width * .68, size.height * .06, size.width * .82,
          size.height * .72, size.width, size.height * .32);

    final track = Paint()
      ..color = color.withValues(alpha: subtle ? .15 : .18)
      ..style = PaintingStyle.stroke
      ..strokeWidth = subtle ? 3 : 4
      ..strokeCap = StrokeCap.round;
    _drawDashedPath(canvas, path, track, 13, 10);

    final active = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = subtle ? 3.5 : 4.5
      ..strokeCap = StrokeCap.round;
    for (final metric in path.computeMetrics()) {
      canvas.drawPath(
        metric.extractPath(0, metric.length * progress),
        active,
      );
    }

    final metric = path.computeMetrics().first;
    final tangent = metric.getTangentForOffset(metric.length * progress);
    if (tangent == null) return;
    canvas.drawCircle(
      tangent.position,
      subtle ? 4.5 : 6,
      Paint()..color = accent,
    );
  }

  void _drawDashedPath(
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
  bool shouldRepaint(covariant _DashedPathPainter oldDelegate) {
    return progress != oldDelegate.progress ||
        color != oldDelegate.color ||
        accent != oldDelegate.accent ||
        subtle != oldDelegate.subtle;
  }
}
