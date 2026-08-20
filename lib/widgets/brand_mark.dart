import 'package:flutter/material.dart';

class GiftPathMark extends StatelessWidget {
  const GiftPathMark({this.size = 34, super.key});

  final double size;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary,
        borderRadius: BorderRadius.circular(size * .24),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.primary.withValues(alpha: .16),
            offset: const Offset(0, 6),
            blurRadius: 16,
          ),
        ],
      ),
      child: SizedBox(
        width: size,
        height: size,
        child: Icon(Icons.auto_awesome, color: Colors.white, size: size * .56),
      ),
    );
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
