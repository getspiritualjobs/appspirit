import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme.dart';
import '../../widgets/brand_components.dart';
import '../../widgets/brand_mark.dart';
import '../../widgets/responsive.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      controller: _scrollController,
      child: Column(
        children: [
          const _HeroSection(),
          _RevealOnScroll(
              controller: _scrollController, child: const _ScriptureBand()),
          _RevealOnScroll(
              controller: _scrollController, child: const _FeatureSection()),
          _RevealOnScroll(
              controller: _scrollController, child: const _HowItWorksSection()),
          _RevealOnScroll(
              controller: _scrollController, child: const _CtaBand()),
          _RevealOnScroll(
              controller: _scrollController, child: const _Footer()),
        ],
      ),
    );
  }
}

class _RevealOnScroll extends StatefulWidget {
  const _RevealOnScroll({
    required this.controller,
    required this.child,
  });

  final ScrollController controller;
  final Widget child;

  @override
  State<_RevealOnScroll> createState() => _RevealOnScrollState();
}

class _RevealOnScrollState extends State<_RevealOnScroll> {
  final _key = GlobalKey();
  bool _shown = false;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_checkVisibility);
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkVisibility());
  }

  @override
  void didUpdateWidget(covariant _RevealOnScroll oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller == widget.controller) return;
    oldWidget.controller.removeListener(_checkVisibility);
    widget.controller.addListener(_checkVisibility);
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkVisibility());
  }

  @override
  void dispose() {
    widget.controller.removeListener(_checkVisibility);
    super.dispose();
  }

  void _checkVisibility() {
    if (_shown || !mounted) return;
    final context = _key.currentContext;
    if (context == null) return;
    final box = context.findRenderObject() as RenderBox?;
    if (box == null || !box.attached) return;
    final top = box.localToGlobal(Offset.zero).dy;
    final height = box.size.height;
    final viewportHeight = MediaQuery.sizeOf(context).height;
    if (top < viewportHeight * .88 && top + height > viewportHeight * .12) {
      setState(() => _shown = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.disableAnimationsOf(context)) {
      return KeyedSubtree(key: _key, child: widget.child);
    }

    return AnimatedOpacity(
      key: _key,
      opacity: _shown ? 1 : 0,
      duration: const Duration(milliseconds: 700),
      curve: Curves.ease,
      child: TweenAnimationBuilder<double>(
        tween: Tween<double>(begin: 18, end: _shown ? 0 : 18),
        duration: const Duration(milliseconds: 700),
        curve: const Cubic(.2, .7, .3, 1),
        builder: (context, offset, child) {
          return Transform.translate(
            offset: Offset(0, offset),
            child: child,
          );
        },
        child: widget.child,
      ),
    );
  }
}

class _HeroSection extends StatelessWidget {
  const _HeroSection();

  @override
  Widget build(BuildContext context) {
    final viewportHeight = MediaQuery.sizeOf(context).height;
    return DecoratedBox(
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
                  child: Text.rich(
                    TextSpan(
                      style: GoogleFonts.fraunces(
                        color: BrandTokens.ink,
                        fontSize: compact ? 42 : 70,
                        fontWeight: FontWeight.w600,
                        height: .98,
                        letterSpacing: -1,
                      ),
                      children: [
                        const TextSpan(text: 'Your gifts were given\n'),
                        TextSpan(
                          text: 'for a reason.',
                          style: GoogleFonts.fraunces(
                            fontStyle: FontStyle.italic,
                            fontWeight: FontWeight.w500,
                            color: BrandTokens.forest,
                          ),
                        ),
                      ],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 14),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 760),
                  child: Text.rich(
                    TextSpan(
                      style: GoogleFonts.inter(
                        color: BrandTokens.ink,
                        fontSize: compact ? 17 : 20,
                        fontWeight: FontWeight.w700,
                        height: 1.25,
                      ),
                      children: const [
                        TextSpan(
                            text:
                                'Take the assessment and see where they lead. '),
                        TextSpan(
                            text: 'Free',
                            style: TextStyle(
                                color: BrandTokens.gold,
                                fontWeight: FontWeight.w900)),
                        TextSpan(text: ' to start, '),
                        TextSpan(
                            text: 'seven minutes',
                            style: TextStyle(
                                color: BrandTokens.gold,
                                fontWeight: FontWeight.w900)),
                        TextSpan(text: ' to your first result.'),
                      ],
                    ),
                    textAlign: TextAlign.center,
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
                const SizedBox(height: 24),
                FilledButton.icon(
                  onPressed: () => context.go('/assessment'),
                  icon: const Icon(Icons.arrow_forward),
                  label: const Text('Discover my gifts'),
                  style: FilledButton.styleFrom(
                    backgroundColor: BrandTokens.gold,
                    foregroundColor: BrandTokens.forest,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 26, vertical: 16),
                    textStyle: const TextStyle(fontSize: 16),
                  ),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () => context.go('/about'),
                  child: const Text('How it works'),
                ),
                const SizedBox(height: 8),
                const Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 20,
                  runSpacing: 8,
                  children: [
                    _TrustBadge('Grounded in Romans 12'),
                    _TrustBadge('Free to start'),
                    _TrustBadge('7-minute first result'),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _TrustBadge extends StatelessWidget {
  const _TrustBadge(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.star_rounded, size: 14, color: BrandTokens.gold),
        const SizedBox(width: 6),
        Text(label,
            style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: BrandTokens.mossSoft)),
      ],
    );
  }
}

class _ScriptureBand extends StatelessWidget {
  const _ScriptureBand();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(color: BrandTokens.cream),
      child: PageBand(
        maxWidth: 760,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 64),
        child: Column(
          children: [
            Text(
              '“Each of you should use whatever gift you have received '
              'to serve others, as faithful stewards of God’s grace in '
              'its various forms.”',
              textAlign: TextAlign.center,
              style: GoogleFonts.fraunces(
                fontStyle: FontStyle.italic,
                fontWeight: FontWeight.w500,
                fontSize: 26,
                height: 1.4,
                color: BrandTokens.forest,
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              '1 PETER 4:10',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.6,
                color: BrandTokens.moss,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FeatureSection extends StatelessWidget {
  const _FeatureSection();

  static const _items = [
    (
      Icons.auto_stories_outlined,
      'Rooted, not trendy',
      'Built on the seven gifts named in Romans 12, with room for the '
          'fuller lists in 1 Corinthians and Ephesians — not a '
          'repackaged personality quiz.',
    ),
    (
      Icons.hourglass_bottom_outlined,
      'Seven honest minutes',
      'One question at a time so answers come from your actual life, '
          'not the version of you that’s performing for a test.',
    ),
    (
      Icons.route_outlined,
      'From score to job',
      'Your alignment score becomes career lanes, then real '
          'opportunities — so reflection turns into a next step, not '
          'just a printout.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(color: BrandTokens.cream),
      child: PageBand(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 72),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final wide = constraints.maxWidth >= 860;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const BrandEyebrow('Why GiftPath'),
                const SizedBox(height: 10),
                Text('Reflection first. Direction second.',
                    style: GoogleFonts.fraunces(
                        fontSize: wide ? 38 : 28,
                        fontWeight: FontWeight.w600,
                        color: BrandTokens.ink)),
                const SizedBox(height: 12),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 620),
                  child: const Text(
                    'Most career tools start with a resume. GiftPath starts '
                    'with who you already are — then walks that forward '
                    'into real, searchable next steps.',
                    style: TextStyle(
                        fontSize: 16, color: BrandTokens.moss, height: 1.55),
                  ),
                ),
                const SizedBox(height: 32),
                wide
                    ? Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          for (var i = 0; i < _items.length; i++) ...[
                            if (i > 0) const SizedBox(width: 20),
                            Expanded(child: _FeatureCard(_items[i])),
                          ],
                        ],
                      )
                    : Column(
                        children: [
                          for (var i = 0; i < _items.length; i++) ...[
                            if (i > 0) const SizedBox(height: 16),
                            _FeatureCard(_items[i]),
                          ],
                        ],
                      ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _FeatureCard extends StatefulWidget {
  const _FeatureCard(this.data);

  final (IconData, String, String) data;

  @override
  State<_FeatureCard> createState() => _FeatureCardState();
}

class _FeatureCardState extends State<_FeatureCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    final lifted = _hovered && !reduceMotion;
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: TweenAnimationBuilder<double>(
        tween: Tween<double>(end: lifted ? -4 : 0),
        duration: const Duration(milliseconds: 250),
        curve: const Cubic(.2, .7, .3, 1),
        builder: (context, offset, child) {
          return Transform.translate(offset: Offset(0, offset), child: child);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: const Cubic(.2, .7, .3, 1),
          decoration: BoxDecoration(
            color: BrandTokens.surface,
            borderRadius: BorderRadius.circular(BrandTokens.radiusMd),
            border: Border.all(
              color: BrandTokens.forest.withValues(alpha: lifted ? .14 : .08),
            ),
            boxShadow: [
              BoxShadow(
                color: BrandTokens.ink.withValues(alpha: lifted ? .10 : .06),
                blurRadius: lifted ? 50 : 24,
                spreadRadius: lifted ? -30 : 0,
                offset: Offset(0, lifted ? 28 : 14),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 26, 24, 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [BrandTokens.forest, BrandTokens.forestDeep],
                    ),
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: Icon(widget.data.$1,
                      color: BrandTokens.goldBright, size: 22),
                ),
                const SizedBox(height: 18),
                Text(widget.data.$2,
                    style: GoogleFonts.fraunces(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: BrandTokens.ink)),
                const SizedBox(height: 8),
                Text(widget.data.$3,
                    style: const TextStyle(
                        fontSize: 14.5, color: BrandTokens.moss, height: 1.5)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _HowItWorksSection extends StatelessWidget {
  const _HowItWorksSection();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(color: BrandTokens.creamDim),
      child: PageBand(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 72),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final wide = constraints.maxWidth >= 900;
            const steps = Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                BrandEyebrow('The path'),
                SizedBox(height: 10),
                _HowHeading(),
                SizedBox(height: 24),
                _HowStep('01', 'Answer honestly',
                    '56 short prompts, one screen at a time, no wrong answers.'),
                _HowStep('02', 'See what rises',
                    'Your top two or three gifts, scored and explained in plain language.'),
                _HowStep('03', 'Explore aligned work',
                    'Career lanes matched to your pattern, not a generic job board.'),
                _HowStep('04', 'Take a real step',
                    'Save what resonates and follow it into an actual opportunity.',
                    last: true),
              ],
            );
            const sample = _SampleResultCard();
            if (!wide) {
              return const Column(
                  children: [steps, SizedBox(height: 32), sample]);
            }
            return const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 4, child: steps),
                SizedBox(width: 48),
                Expanded(flex: 5, child: sample),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _HowHeading extends StatelessWidget {
  const _HowHeading();

  @override
  Widget build(BuildContext context) {
    return Text('Four stops, in order',
        style: GoogleFonts.fraunces(
            fontSize: 30, fontWeight: FontWeight.w600, color: BrandTokens.ink));
  }
}

class _HowStep extends StatelessWidget {
  const _HowStep(this.number, this.title, this.body, {this.last = false});

  final String number;
  final String title;
  final String body;
  final bool last;

  @override
  Widget build(BuildContext context) {
    final line = BorderSide(color: BrandTokens.forest.withValues(alpha: .1));
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border(top: line, bottom: last ? line : BorderSide.none),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 30,
              child: Text(number,
                  style: GoogleFonts.fraunces(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: BrandTokens.gold)),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          fontSize: 16.5,
                          fontWeight: FontWeight.w800,
                          color: BrandTokens.ink)),
                  const SizedBox(height: 4),
                  Text(body,
                      style: const TextStyle(
                          fontSize: 14, color: BrandTokens.moss, height: 1.5)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SampleResultCard extends StatelessWidget {
  const _SampleResultCard();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: BrandTokens.surface,
        borderRadius: BorderRadius.circular(BrandTokens.radiusMd),
        border: Border.all(color: BrandTokens.forest.withValues(alpha: .08)),
        boxShadow: [
          BoxShadow(
            color: BrandTokens.ink.withValues(alpha: .08),
            blurRadius: 30,
            offset: const Offset(0, 18),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
              decoration: BoxDecoration(
                color: BrandTokens.gold.withValues(alpha: .12),
                borderRadius: BorderRadius.circular(999),
              ),
              child: const Text('SAMPLE RESULT',
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.2,
                      color: BrandTokens.gold)),
            ),
            const SizedBox(height: 16),
            Text('Your strongest gifts',
                style: GoogleFonts.fraunces(
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                    color: BrandTokens.ink)),
            const SizedBox(height: 8),
            const Text(
              'Based on your answers, these rose to the top — here’s '
              'where GiftPath sends you next.',
              style: TextStyle(
                  fontSize: 14.5, color: BrandTokens.moss, height: 1.5),
            ),
            const SizedBox(height: 18),
            const Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _SampleChip('Teaching — 92%', top: true),
                _SampleChip('Encouragement — 87%', top: true),
                _SampleChip('Leadership — 74%'),
                _SampleChip('Serving — 68%'),
                _SampleChip('Mercy — 61%'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SampleChip extends StatelessWidget {
  const _SampleChip(this.label, {this.top = false});

  final String label;
  final bool top;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        gradient: top
            ? const LinearGradient(
                colors: [BrandTokens.forest, BrandTokens.forestDeep])
            : null,
        color: top ? null : BrandTokens.cream,
        border: top
            ? null
            : Border.all(color: BrandTokens.forest.withValues(alpha: .12)),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(label,
          style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: top ? BrandTokens.goldBright : BrandTokens.forest)),
    );
  }
}

class _CtaBand extends StatelessWidget {
  const _CtaBand();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(color: BrandTokens.cream),
      child: PageBand(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 72),
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [BrandTokens.forest, BrandTokens.forestDeep],
            ),
            borderRadius: BorderRadius.circular(BrandTokens.radiusLg),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 56),
            child: Column(
              children: [
                Text(
                  'Your seven minutes start whenever you’re ready.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.fraunces(
                      fontSize: 32,
                      fontWeight: FontWeight.w600,
                      color: BrandTokens.cream,
                      height: 1.15),
                ),
                const SizedBox(height: 12),
                Text(
                  'No account required to see your first result.',
                  style: TextStyle(
                      fontSize: 15,
                      color: BrandTokens.cream.withValues(alpha: .7)),
                ),
                const SizedBox(height: 26),
                FilledButton.icon(
                  onPressed: () => context.go('/assessment'),
                  icon: const Icon(Icons.arrow_forward),
                  label: const Text('Discover my gifts'),
                  style: FilledButton.styleFrom(
                    backgroundColor: BrandTokens.gold,
                    foregroundColor: BrandTokens.forest,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 26, vertical: 16),
                    textStyle: const TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Footer extends StatelessWidget {
  const _Footer();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(color: BrandTokens.cream),
      child: PageBand(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 44),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final wide = constraints.maxWidth >= 760;
            const brand = Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                GiftPathLogo(markSize: 26, compact: true),
                SizedBox(height: 12),
                SizedBox(
                  width: 260,
                  child: Text(
                    'Discover your gifts. Find your path. A '
                    'scripture-informed assessment for reflection and next '
                    'steps.',
                    style: TextStyle(
                        fontSize: 13.5, color: BrandTokens.moss, height: 1.5),
                  ),
                ),
              ],
            );
            final columns = Wrap(
              spacing: 40,
              runSpacing: 24,
              children: [
                const _FooterColumn(
                    'Product', ['Assessment', 'Opportunities', 'Saved']),
                const _FooterColumn('Learn', ['How it works', 'Blog', 'About']),
                _FooterColumn('Company', const ['Privacy', 'Terms', 'Contact'],
                    onTap: (label) {
                  if (label == 'Privacy' || label == 'Terms') {
                    context.go('/legal');
                  }
                }),
              ],
            );
            return Column(
              children: [
                Divider(color: BrandTokens.forest.withValues(alpha: .1)),
                const SizedBox(height: 40),
                wide
                    ? Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Expanded(flex: 3, child: brand),
                          Expanded(flex: 4, child: columns),
                        ],
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          brand,
                          const SizedBox(height: 28),
                          columns,
                        ],
                      ),
                const SizedBox(height: 36),
                const Wrap(
                  alignment: WrapAlignment.spaceBetween,
                  runSpacing: 8,
                  children: [
                    Text(
                        '© 2026 GiftPath. Discover your gifts. Find '
                        'your path.',
                        style: TextStyle(
                            fontSize: 12.5, color: BrandTokens.mossSoft)),
                    Text('Made for reflection, not prediction.',
                        style: TextStyle(
                            fontSize: 12.5, color: BrandTokens.mossSoft)),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _FooterColumn extends StatelessWidget {
  const _FooterColumn(this.title, this.links, {this.onTap});

  final String title;
  final List<String> links;
  final ValueChanged<String>? onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 140,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(title.toUpperCase(),
              style: const TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.2,
                  color: BrandTokens.mossSoft)),
          const SizedBox(height: 14),
          for (final link in links)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: InkWell(
                onTap: onTap == null ? null : () => onTap!(link),
                child: Text(link,
                    style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: BrandTokens.ink)),
              ),
            ),
        ],
      ),
    );
  }
}

class _HeroVisual extends StatefulWidget {
  const _HeroVisual();

  @override
  State<_HeroVisual> createState() => _HeroVisualState();
}

class _HeroVisualState extends State<_HeroVisual>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _progress;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    );
    _progress = CurvedAnimation(
      parent: _controller,
      curve: const Cubic(.3, .7, .2, 1),
    );
    Future<void>.delayed(const Duration(milliseconds: 300), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    if (reduceMotion) {
      return const _HeroVisualLayout(progress: 1);
    }

    return AnimatedBuilder(
      animation: _progress,
      builder: (context, _) => _HeroVisualLayout(progress: _progress.value),
    );
  }
}

class _HeroVisualLayout extends StatelessWidget {
  const _HeroVisualLayout({required this.progress});

  final double progress;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 620) {
          return _HeroVisualCompact(progress: progress);
        }
        return _HeroVisualWide(progress: progress);
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
  const _HeroVisualWide({required this.progress});

  static const _labelWidth = 220.0;
  static const _gap = 22.0;
  final double progress;

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
                Positioned.fill(
                  child: CustomPaint(
                    painter: _HeroPathPainter(progress: progress),
                  ),
                ),
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
  const _HeroVisualCompact({required this.progress});

  final double progress;

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
            SizedBox(
              height: 150,
              width: double.infinity,
              child: CustomPaint(painter: _HeroPathPainter(progress: progress)),
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
  const _HeroPathPainter({required this.progress});

  final double progress;

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
      ..color = BrandTokens.gold.withValues(alpha: .16)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.6
      ..strokeCap = StrokeCap.round;
    _drawDashes(canvas, path, track, 18, 13);

    final active = Paint()
      ..color = BrandTokens.gold.withValues(alpha: .54)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.6
      ..strokeCap = StrokeCap.round;
    _drawDashes(canvas, _extractPath(path, progress), active, 18, 13);

    for (var i = 0; i < points.length; i++) {
      final nodeProgress =
          ((progress - _nodeThresholds[i]) / .12).clamp(0.0, 1.0);
      if (nodeProgress <= 0) continue;
      final point = points[i];
      final large = size.width > 760;
      final haloRadius = (large ? 27.0 : 19.0) * nodeProgress;
      final nodeRadius = (large ? 18.0 : 13.5) * nodeProgress;
      canvas.drawCircle(
          point,
          haloRadius,
          Paint()
            ..color = BrandTokens.gold.withValues(alpha: .16 * nodeProgress));
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

  Path _extractPath(Path path, double progress) {
    final extracted = Path();
    for (final metric in path.computeMetrics()) {
      extracted.addPath(
        metric.extractPath(0, metric.length * progress.clamp(0, 1)),
        Offset.zero,
      );
    }
    return extracted;
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
  bool shouldRepaint(covariant _HeroPathPainter oldDelegate) {
    return progress != oldDelegate.progress;
  }
}

const _nodeThresholds = [0.02, 0.34, 0.64, 0.94];

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
