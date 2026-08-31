import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/theme.dart';
import '../../data/billing_service.dart';
import '../../widgets/brand_components.dart';
import '../../widgets/brand_mark.dart';
import '../../widgets/responsive.dart';

class SubscribePage extends StatefulWidget {
  const SubscribePage({super.key});

  @override
  State<SubscribePage> createState() => _SubscribePageState();
}

class _SubscribePageState extends State<SubscribePage> {
  BillingPlan? loadingPlan;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: PageBand(
        maxWidth: 920,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const BrandEyebrow('Full access'),
            const SizedBox(height: 10),
            Text('Unlock your opportunity portal',
                style: Theme.of(context).textTheme.displayMedium),
            const SizedBox(height: 10),
            const Text(
              'Your first matched job is free. The portal opens the full job list, career-lane filtering, saved jobs, and ongoing searches from your strongest matches.',
            ),
            const SizedBox(height: 22),
            const _PortalSummary(),
            const SizedBox(height: 18),
            LayoutBuilder(
              builder: (context, constraints) {
                final wide = constraints.maxWidth > 720;
                final cards = [
                  _PlanCard(
                    title: 'Monthly',
                    price: r'$7.77',
                    cadence: 'per month',
                    description:
                        'A flexible way to keep exploring matched opportunities.',
                    icon: Icons.credit_card,
                    primary: true,
                    loading: loadingPlan == BillingPlan.monthly,
                    onPressed: () => _openCheckout(BillingPlan.monthly),
                  ),
                  _PlanCard(
                    title: 'Yearly',
                    price: r'$77.77',
                    cadence: 'per year',
                    description:
                        'A full year of the opportunity portal for less than ten monthly payments.',
                    icon: Icons.savings_outlined,
                    badge: 'Save 17%',
                    loading: loadingPlan == BillingPlan.yearly,
                    onPressed: () => _openCheckout(BillingPlan.yearly),
                  ),
                ];
                return wide
                    ? Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(child: cards[0]),
                          const SizedBox(width: 14),
                          Expanded(child: cards[1]),
                        ],
                      )
                    : Column(
                        children: [
                          cards[0],
                          const SizedBox(height: 14),
                          cards[1],
                        ],
                      );
              },
            ),
            const SizedBox(height: 20),
            BrandNotice(
              icon: Icons.lock_outline,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('What changes after subscribing',
                      style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 6),
                  const Text(
                    'Opportunities shows the full matched list instead of one free result. Your results, saved careers, and saved jobs stay private to your account. You can manage or cancel your subscription from Account.',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            TextButton.icon(
              onPressed: () => context.go('/opportunities'),
              icon: const Icon(Icons.arrow_back),
              label: const Text('Back to Opportunities'),
            ),
            const SizedBox(height: 6),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                TextButton(
                    onPressed: () => context.go('/terms'),
                    child: const Text('Terms')),
                TextButton(
                    onPressed: () => context.go('/privacy'),
                    child: const Text('Privacy')),
                TextButton(
                    onPressed: () => context.go('/cancellation'),
                    child: const Text('Cancellation policy')),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openCheckout(BillingPlan plan) async {
    setState(() => loadingPlan = plan);
    final result = await BillingService().createCheckoutSession(plan: plan);
    if (!mounted) return;
    setState(() => loadingPlan = null);

    if (!result.isSuccess) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result.error ?? 'Stripe checkout is unavailable.'),
          action: SnackBarAction(
            label: 'Account',
            onPressed: () => context.go('/auth'),
          ),
        ),
      );
      return;
    }

    await launchUrl(Uri.parse(result.url!), webOnlyWindowName: '_self');
  }
}

class _PortalSummary extends StatelessWidget {
  const _PortalSummary();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: BrandTokens.forest,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: BrandTokens.ink.withValues(alpha: .12),
            blurRadius: 26,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final narrow = constraints.maxWidth < 680;
            const items = [
              _PortalStep('01', 'One free job', 'See a first real opening.'),
              _PortalStep('02', 'Career lanes', 'Choose the paths to follow.'),
              _PortalStep('03', 'Full list', 'Compare all matched jobs.'),
            ];
            return narrow
                ? Column(
                    children: [
                      for (var i = 0; i < items.length; i++) ...[
                        items[i],
                        if (i != items.length - 1) const SizedBox(height: 12),
                      ],
                    ],
                  )
                : Row(
                    children: [
                      for (var i = 0; i < items.length; i++) ...[
                        Expanded(child: items[i]),
                        if (i != items.length - 1) const SizedBox(width: 12),
                      ],
                    ],
                  );
          },
        ),
      ),
    );
  }
}

class _PortalStep extends StatelessWidget {
  const _PortalStep(this.number, this.title, this.body);

  final String number;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          radius: 18,
          backgroundColor: BrandTokens.gold,
          child: Text(
            number,
            style: const TextStyle(
              color: BrandTokens.forest,
              fontWeight: FontWeight.w900,
              fontSize: 12,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
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
                style: TextStyle(
                  color: BrandTokens.cream.withValues(alpha: .76),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _PlanCard extends StatelessWidget {
  const _PlanCard({
    required this.title,
    required this.price,
    required this.cadence,
    required this.description,
    required this.icon,
    required this.loading,
    required this.onPressed,
    this.badge,
    this.primary = false,
  });

  final String title;
  final String price;
  final String cadence;
  final String description;
  final IconData icon;
  final bool loading;
  final VoidCallback onPressed;
  final String? badge;
  final bool primary;

  @override
  Widget build(BuildContext context) {
    return InfoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IconBadge(icon, size: 42),
              const Spacer(),
              if (badge != null)
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: BrandTokens.gold.withValues(alpha: .18),
                    border: Border.all(
                      color: BrandTokens.gold.withValues(alpha: .62),
                    ),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                    child: Text(
                      badge!.toUpperCase(),
                      style: const TextStyle(
                        color: BrandTokens.forest,
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                        letterSpacing: .9,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 14),
          if (primary) ...[
            const BrandEyebrow('Most flexible'),
            const SizedBox(height: 8),
          ],
          Text(title, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 10),
          Wrap(
            crossAxisAlignment: WrapCrossAlignment.end,
            spacing: 8,
            runSpacing: 2,
            children: [
              Text(price, style: Theme.of(context).textTheme.headlineMedium),
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(cadence),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(description),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            child: primary
                ? FilledButton.icon(
                    onPressed: loading ? null : onPressed,
                    icon: loading
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.arrow_forward),
                    label:
                        Text(loading ? 'Opening Checkout' : 'Choose Monthly'),
                  )
                : OutlinedButton.icon(
                    onPressed: loading ? null : onPressed,
                    icon: loading
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.arrow_forward),
                    label: Text(loading ? 'Opening Checkout' : 'Choose Yearly'),
                  ),
          ),
        ],
      ),
    );
  }
}
