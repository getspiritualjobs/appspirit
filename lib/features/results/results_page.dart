import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';

import '../../core/app_state.dart';
import '../../core/models.dart';
import '../../core/scoring.dart';
import '../../core/theme.dart';
import '../../data/job_search_service.dart';
import '../../data/seed_data.dart';
import '../../widgets/brand_components.dart';
import '../../widgets/gift_badge.dart';
import '../../widgets/responsive.dart';

class ResultsPage extends StatelessWidget {
  const ResultsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: appState,
      builder: (context, _) {
        if (!appState.hasResults) {
          return PageBand(
            child: EmptyState(
              icon: Icons.auto_awesome,
              title: 'Your results are waiting',
              body:
                  'Complete the assessment to see your strongest gift alignments and career matches.',
              action: FilledButton(
                onPressed: () => context.go('/assessment'),
                child: const Text('Start Assessment'),
              ),
            ),
          );
        }

        final top = appState.topThree;
        final topGift = top.first;
        final topCareer = appState.careerMatches.isEmpty
            ? null
            : appState.careerMatches.first;

        return SingleChildScrollView(
          child: PageBand(
            padding: const EdgeInsets.fromLTRB(20, 34, 20, 52),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final compact = constraints.maxWidth < 620;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const BrandEyebrow('Your gift profile'),
                    const SizedBox(height: 10),
                    Text(
                      'Your GiftPath is taking shape.',
                      style: GoogleFonts.inter(
                        color: BrandTokens.ink,
                        fontSize: compact ? 42 : 54,
                        fontWeight: FontWeight.w900,
                        height: .98,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Your answers formed a pattern. Start with the strongest gifts, then use the career and job matches as next steps to test, pray through, and compare.',
                    ),
                    const SizedBox(height: 24),
                    _ResultsHero(
                      topGift: topGift,
                      topCareer: topCareer,
                      onCareers: () => context.go('/opportunities'),
                      onJobs: () => context.go('/opportunities'),
                    ),
                    const SizedBox(height: 24),
                    _NextStepBar(
                      onCareers: () => context.go('/opportunities'),
                      onJobs: () => context.go('/opportunities'),
                      onSave: appState.saveCurrentResult,
                    ),
                    const SizedBox(height: 28),
                    const BrandDivider(),
                    const SizedBox(height: 28),
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final columns = constraints.maxWidth > 860 ? 3 : 1;
                        return GridView.count(
                          crossAxisCount: columns,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisSpacing: 14,
                          mainAxisSpacing: 14,
                          childAspectRatio: columns == 1 ? 2.35 : .98,
                          children: [
                            for (var i = 0; i < top.length; i++)
                              _TopGiftCard(score: top[i], topReveal: i == 0),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 26),
                    if (topCareer != null) ...[
                      _CareerBridge(match: topCareer),
                      const SizedBox(height: 14),
                      _FirstJobBridge(careerMatches: appState.careerMatches),
                    ],
                    const SizedBox(height: 28),
                    Text(
                      'All Gift Alignments',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 12),
                    for (final score in appState.giftScores) _ScoreRow(score),
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

class _ResultsHero extends StatelessWidget {
  const _ResultsHero({
    required this.topGift,
    required this.topCareer,
    required this.onCareers,
    required this.onJobs,
  });

  final GiftScore topGift;
  final CareerMatch? topCareer;
  final VoidCallback onCareers;
  final VoidCallback onJobs;

  @override
  Widget build(BuildContext context) {
    final gift = gifts.firstWhere((item) => item.key == topGift.gift);
    return LayoutBuilder(
      builder: (context, constraints) {
        final narrow = constraints.maxWidth < 760;
        final reveal = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const BrandEyebrow('Strongest signal'),
            const SizedBox(height: 10),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                gift.name,
                maxLines: 1,
                style: GoogleFonts.inter(
                  color: BrandTokens.cream,
                  fontSize: narrow ? 48 : 58,
                  fontWeight: FontWeight.w900,
                  height: .95,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              '${topGift.normalizedScore}% alignment',
              style: const TextStyle(
                color: BrandTokens.gold,
                fontSize: 18,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 14),
            Text(
              gift.shortDescription,
              style: const TextStyle(
                color: BrandTokens.cream,
                fontSize: 17,
                height: 1.45,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              gift.scripture,
              style: TextStyle(
                color: BrandTokens.cream.withValues(alpha: .78),
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        );
        final pathGraphic = _ResultsPathGraphic(
          careerTitle: topCareer?.career.title ?? 'Career matches',
          onCareers: onCareers,
          onJobs: onJobs,
        );
        return DecoratedBox(
          decoration: BoxDecoration(
            color: BrandTokens.forest,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: BrandTokens.ink.withValues(alpha: .12),
                blurRadius: 30,
                offset: const Offset(0, 18),
              ),
            ],
          ),
          child: Padding(
            padding: EdgeInsets.all(narrow ? 20 : 28),
            child: narrow
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      reveal,
                      const SizedBox(height: 24),
                      pathGraphic,
                    ],
                  )
                : Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(flex: 5, child: reveal),
                      const SizedBox(width: 28),
                      Expanded(flex: 6, child: pathGraphic),
                    ],
                  ),
          ),
        );
      },
    );
  }
}

class _ResultsPathGraphic extends StatelessWidget {
  const _ResultsPathGraphic({
    required this.careerTitle,
    required this.onCareers,
    required this.onJobs,
  });

  final String careerTitle;
  final VoidCallback onCareers;
  final VoidCallback onJobs;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: BrandTokens.ink.withValues(alpha: .16),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: BrandTokens.gold.withValues(alpha: .18)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(
              height: 132,
              width: double.infinity,
              child: CustomPaint(painter: _ResultsPathPainter()),
            ),
            const SizedBox(height: 14),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                const _PathPill('Gifts', 'Known'),
                _PathPill('Career lanes', careerTitle),
                const _PathPill('Open jobs', 'One free match'),
              ],
            ),
            const SizedBox(height: 18),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                FilledButton.icon(
                  onPressed: onCareers,
                  icon: const Icon(Icons.work_outline),
                  label: const Text('Choose a Career Lane'),
                  style: FilledButton.styleFrom(
                    backgroundColor: BrandTokens.gold,
                    foregroundColor: BrandTokens.forest,
                  ),
                ),
                OutlinedButton.icon(
                  onPressed: onJobs,
                  icon: const Icon(Icons.open_in_new),
                  label: const Text('Open Job Matches'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: BrandTokens.cream,
                    side: BorderSide(
                        color: BrandTokens.cream.withValues(alpha: .45)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _PathPill extends StatelessWidget {
  const _PathPill(this.title, this.body);

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 146,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: BrandTokens.cream,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            body,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: BrandTokens.cream.withValues(alpha: .72),
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _ResultsPathPainter extends CustomPainter {
  const _ResultsPathPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(size.width * .08, size.height * .64)
      ..cubicTo(size.width * .26, size.height * .10, size.width * .39,
          size.height * .92, size.width * .54, size.height * .44)
      ..cubicTo(size.width * .68, size.height * .02, size.width * .82,
          size.height * .62, size.width * .94, size.height * .34);

    final shadow = Paint()
      ..color = BrandTokens.ink.withValues(alpha: .30)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 7
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(path.shift(const Offset(0, 4)), shadow);

    final track = Paint()
      ..color = BrandTokens.gold.withValues(alpha: .62)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.4
      ..strokeCap = StrokeCap.round;
    for (final metric in path.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        canvas.drawPath(
          metric.extractPath(distance, (distance + 16).clamp(0, metric.length)),
          track,
        );
        distance += 28;
      }
    }

    final points = [
      Offset(size.width * .08, size.height * .64),
      Offset(size.width * .54, size.height * .44),
      Offset(size.width * .94, size.height * .34),
    ];
    for (var i = 0; i < points.length; i++) {
      final point = points[i];
      canvas.drawCircle(
          point, 20, Paint()..color = BrandTokens.gold.withValues(alpha: .18));
      canvas.drawCircle(point, 13, Paint()..color = BrandTokens.gold);
      final number = TextPainter(
        text: TextSpan(
          text: '${i + 1}',
          style: const TextStyle(
            color: BrandTokens.forest,
            fontSize: 13,
            fontWeight: FontWeight.w900,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      number.paint(
        canvas,
        Offset(point.dx - number.width / 2, point.dy - number.height / 2),
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _NextStepBar extends StatelessWidget {
  const _NextStepBar({
    required this.onCareers,
    required this.onJobs,
    required this.onSave,
  });

  final VoidCallback onCareers;
  final VoidCallback onJobs;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final narrow = constraints.maxWidth < 780;
        final children = <Widget>[
          const _NextStepAction(
            eyebrow: '01',
            title: 'Read your gifts',
            body:
                'Start with the top three before treating any career as a conclusion.',
            icon: Icons.auto_awesome,
            onTap: null,
          ),
          _NextStepAction(
            eyebrow: '02',
            title: 'Choose career lanes',
            body:
                'Pick the kinds of work you want the opportunity search to follow.',
            icon: Icons.work_outline,
            onTap: onCareers,
          ),
          _NextStepAction(
            eyebrow: '03',
            title: 'Open jobs',
            body:
                'View one free matched job, then unlock the rest when you are ready.',
            icon: Icons.open_in_new,
            onTap: onJobs,
          ),
          _NextStepAction(
            eyebrow: 'Save',
            title: 'Keep this profile',
            body: 'Save the result so you can come back after comparing paths.',
            icon: Icons.bookmark_add_outlined,
            onTap: onSave,
          ),
        ];
        if (narrow) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (var i = 0; i < children.length; i++) ...[
                children[i],
                if (i != children.length - 1) const SizedBox(height: 12),
              ],
            ],
          );
        }
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (var i = 0; i < children.length; i++) ...[
              Expanded(child: children[i]),
              if (i != children.length - 1) const SizedBox(width: 12),
            ],
          ],
        );
      },
    );
  }
}

class _NextStepAction extends StatelessWidget {
  const _NextStepAction({
    required this.eyebrow,
    required this.title,
    required this.body,
    required this.icon,
    required this.onTap,
  });

  final String eyebrow;
  final String title;
  final String body;
  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final clickable = onTap != null;
    return InfoCard(
      padding: const EdgeInsets.all(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  eyebrow.toUpperCase(),
                  style: const TextStyle(
                    color: BrandTokens.gold,
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.4,
                  ),
                ),
                const Spacer(),
                Icon(icon, color: BrandTokens.forest, size: 20),
              ],
            ),
            const SizedBox(height: 12),
            Text(title, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 6),
            Text(body),
            if (clickable) ...[
              const SizedBox(height: 12),
              const Text(
                'Continue',
                style: TextStyle(
                  color: BrandTokens.forest,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _CareerBridge extends StatelessWidget {
  const _CareerBridge({required this.match});

  final CareerMatch match;

  @override
  Widget build(BuildContext context) {
    return InfoCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.signpost_outlined,
              color: BrandTokens.forest, size: 34),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const BrandEyebrow('First career signal'),
                const SizedBox(height: 6),
                Text(
                  '${match.career.title} is your current top career match.',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 6),
                Text(match.reason),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text(
            '${match.score}%',
            style: const TextStyle(
              color: BrandTokens.gold,
              fontSize: 24,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _FirstJobBridge extends StatelessWidget {
  const _FirstJobBridge({required this.careerMatches});

  final List<CareerMatch> careerMatches;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<JobSearchResult>(
      future: JobSearchService().search(careerMatches: careerMatches),
      builder: (context, snapshot) {
        final job = snapshot.data?.jobs.isNotEmpty ?? false
            ? snapshot.data!.jobs.first
            : null;
        return InfoCard(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.open_in_new,
                  color: BrandTokens.forest, size: 34),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const BrandEyebrow('First job match'),
                    const SizedBox(height: 6),
                    Text(
                      job == null
                          ? 'We are finding your first open role.'
                          : job.title,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      job == null
                          ? 'Live openings are pulled from your top career matches when you open Opportunities.'
                          : '${job.company} · ${job.location}',
                    ),
                    const SizedBox(height: 14),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        FilledButton.icon(
                          onPressed: () => context.go('/opportunities'),
                          icon: const Icon(Icons.route_outlined),
                          label: const Text('Open opportunities'),
                        ),
                        OutlinedButton.icon(
                          onPressed: () => context.go('/subscribe'),
                          icon: const Icon(Icons.lock_open_outlined),
                          label: const Text('Unlock more'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              if (job != null) ...[
                const SizedBox(width: 12),
                Text(
                  '${job.matchScore}%',
                  style: const TextStyle(
                    color: BrandTokens.gold,
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _TopGiftCard extends StatelessWidget {
  const _TopGiftCard({required this.score, required this.topReveal});

  final GiftScore score;
  final bool topReveal;

  @override
  Widget build(BuildContext context) {
    final gift = gifts.firstWhere((item) => item.key == score.gift);
    return InfoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (topReveal)
            const BrandEyebrow('Top gift reveal')
          else
            GiftBadge(score.gift),
          const SizedBox(height: 14),
          Text(gift.name, style: Theme.of(context).textTheme.headlineMedium),
          Text(
            '${score.normalizedScore}% alignment',
            style: TextStyle(
              color: topReveal ? BrandTokens.gold : BrandTokens.forest,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 12),
          Text(gift.shortDescription),
          const Spacer(),
          Text(gift.scripture,
              style: const TextStyle(fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

class _ScoreRow extends StatelessWidget {
  const _ScoreRow(this.score);

  final GiftScore score;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          SizedBox(
            width: 150,
            child: Text(
              giftLabel(score.gift),
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
          ),
          Expanded(
            child: LinearProgressIndicator(
              value: score.normalizedScore / 100,
              minHeight: 8,
            ),
          ),
          const SizedBox(width: 12),
          Text('${score.normalizedScore}%'),
        ],
      ),
    );
  }
}
