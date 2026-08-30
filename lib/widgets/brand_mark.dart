import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../core/theme.dart';

class GiftPathMark extends StatelessWidget {
  const GiftPathMark({this.size = 34, this.showBackground = false, super.key});

  final double size;
  final bool showBackground;

  @override
  Widget build(BuildContext context) {
    final asset = showBackground
        ? 'assets/giftpath-app-icon.png'
        : 'assets/giftpath-mark.png';
    final image = Image.asset(
      asset,
      width: size,
      height: size,
      fit: BoxFit.contain,
      filterQuality: FilterQuality.high,
      errorBuilder: (_, __, ___) => Icon(
        Icons.signpost_outlined,
        color: Theme.of(context).colorScheme.primary,
        size: size * .74,
      ),
    );

    if (!showBackground) return image;

    return ClipRRect(
      borderRadius: BorderRadius.circular(size * .22),
      child: image,
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
          style: GoogleFonts.fraunces(
            color: scheme.onSurface,
            fontWeight: FontWeight.w600,
            fontSize: compact ? 24 : 29,
            height: .95,
            letterSpacing: .1,
          ),
        ),
      ],
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
        borderRadius: BorderRadius.circular(BrandTokens.radiusSm + 1),
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
