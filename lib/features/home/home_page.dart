import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

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
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFFFFCF7), Color(0xFFE7F0EA)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: PageBand(
              padding: const EdgeInsets.fromLTRB(20, 52, 20, 36),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final wide = constraints.maxWidth > 760;
                  final heroText = Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Discover your gifts. Explore your calling.',
                          style: theme.textTheme.displayLarge),
                      const SizedBox(height: 18),
                      Text(
                        'Take a Scripture-informed spiritual gifts assessment and discover careers and opportunities where your gifts may thrive.',
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
                    return GridView.count(
                      crossAxisCount: columns,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisSpacing: 14,
                      mainAxisSpacing: 14,
                      childAspectRatio: columns == 1 ? 3.6 : 1.35,
                      children: const [
                        _JourneyStep('01', 'Discover',
                            'Take the spiritual gifts assessment.'),
                        _JourneyStep('02', 'Understand',
                            'See your strongest gifts and what they mean.'),
                        _JourneyStep('03', 'Explore',
                            'Discover careers aligned with how you are gifted.'),
                        _JourneyStep('04', 'Act',
                            'Explore real opportunities where you can put gifts to work.'),
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
      aspectRatio: 1.08,
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
              child: CustomPaint(painter: _PathPainter()),
            ),
            Positioned(
                top: 30,
                left: 28,
                child: _MiniCard(
                    icon: Icons.auto_awesome, label: 'Teaching', value: '94%')),
            Positioned(
                top: 132,
                right: 26,
                child: _MiniCard(
                    icon: Icons.favorite_border,
                    label: 'Encouragement',
                    value: '88%')),
            Positioned(
                bottom: 30,
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
            IconBadge(icon, size: 36),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(label,
                    style: const TextStyle(fontWeight: FontWeight.w800)),
                Text(value),
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
              style: TextStyle(
                  color: Theme.of(context).colorScheme.secondary,
                  fontWeight: FontWeight.w900)),
          const SizedBox(height: 8),
          Text(title, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 6),
          Text(body),
        ],
      ),
    );
  }
}

class _PathPainter extends CustomPainter {
  const _PathPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF2D5A4A).withValues(alpha: .16)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;
    final path = Path()
      ..moveTo(size.width * .18, size.height * .25)
      ..cubicTo(size.width * .7, size.height * .15, size.width * .3,
          size.height * .58, size.width * .78, size.height * .50)
      ..cubicTo(size.width * .35, size.height * .66, size.width * .58,
          size.height * .92, size.width * .22, size.height * .82);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
