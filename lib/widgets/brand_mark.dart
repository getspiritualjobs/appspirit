import 'package:flutter/material.dart';

class GiftPathMark extends StatelessWidget {
  const GiftPathMark({this.size = 34, this.showBackground = true, super.key});

  final double size;
  final bool showBackground;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    Widget mark(double markSize) => SizedBox(
          width: markSize,
          height: markSize,
          child: CustomPaint(
            painter: _GiftPathMarkPainter(
              color: showBackground ? Colors.white : scheme.primary,
              pathColor: showBackground ? scheme.primary : scheme.surface,
            ),
          ),
        );

    if (!showBackground) return mark(size);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: scheme.primary,
        borderRadius: BorderRadius.circular(size * .22),
      ),
      child: SizedBox(
        width: size,
        height: size,
        child: Padding(
          padding: EdgeInsets.all(size * .14),
          child: mark(size * .72),
        ),
      ),
    );
  }
}

class GiftPathLogo extends StatelessWidget {
  const GiftPathLogo({this.markSize = 34, this.compact = false, super.key});

  final double markSize;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        GiftPathMark(size: markSize),
        SizedBox(width: compact ? 8 : 10),
        Text(
          'GiftPath',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: scheme.onSurface,
                fontWeight: FontWeight.w900,
                fontSize: compact ? 20 : 22,
              ),
        ),
      ],
    );
  }
}

class _GiftPathMarkPainter extends CustomPainter {
  const _GiftPathMarkPainter({required this.color, required this.pathColor});

  final Color color;
  final Color pathColor;

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.shortestSide;
    final radius = Radius.circular(s * .035);
    final paint = Paint()..color = color;

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(s * .39, s * .10, s * .22, s * .80),
        radius,
      ),
      paint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(s * .12, s * .32, s * .76, s * .24),
        radius,
      ),
      paint,
    );

    final path = Path()
      ..moveTo(s * .46, s * .92)
      ..cubicTo(s * .34, s * .70, s * .33, s * .47, s * .50, s * .38)
      ..cubicTo(s * .58, s * .34, s * .66, s * .30, s * .76, s * .24);

    final dashPaint = Paint()
      ..color = pathColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = s * .08
      ..strokeCap = StrokeCap.butt;
    for (final metric in path.computeMetrics()) {
      var distance = 0.0;
      final dash = s * .11;
      final gap = s * .075;
      while (distance < metric.length) {
        canvas.drawPath(
          metric.extractPath(
              distance, (distance + dash).clamp(0, metric.length)),
          dashPaint,
        );
        distance += dash + gap;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _GiftPathMarkPainter oldDelegate) {
    return color != oldDelegate.color || pathColor != oldDelegate.pathColor;
  }
}

class IconBadge extends StatelessWidget {
  const IconBadge(this.icon, {this.size = 42, this.color, super.key});

  final IconData icon;
  final double size;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final badgeColor = color ?? Theme.of(context).colorScheme.primary;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: badgeColor.withValues(alpha: .10),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: badgeColor.withValues(alpha: .16)),
      ),
      child: SizedBox(
        width: size,
        height: size,
        child: Icon(icon, color: badgeColor, size: size * .48),
      ),
    );
  }
}

class GoogleMark extends StatelessWidget {
  const GoogleMark({this.size = 20, super.key});

  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: const CustomPaint(painter: _GoogleMarkPainter()),
    );
  }
}

class _GoogleMarkPainter extends CustomPainter {
  const _GoogleMarkPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final stroke = size.width * .16;
    final rect = Offset(stroke / 2, stroke / 2) &
        Size(size.width - stroke, size.height - stroke);
    void arc(Color color, double start, double sweep) {
      canvas.drawArc(
        rect,
        start,
        sweep,
        false,
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.square
          ..strokeWidth = stroke,
      );
    }

    arc(const Color(0xFF4285F4), -.15, 1.18);
    arc(const Color(0xFF34A853), 1.03, 1.33);
    arc(const Color(0xFFFBBC05), 2.36, 1.18);
    arc(const Color(0xFFEA4335), 3.54, 1.63);

    final blue = Paint()
      ..color = const Color(0xFF4285F4)
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.square
      ..strokeWidth = stroke;
    canvas.drawLine(
      Offset(size.width * .55, size.height * .50),
      Offset(size.width * .92, size.height * .50),
      blue,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
