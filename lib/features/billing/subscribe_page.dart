import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

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
            Text('Unlock every matched opportunity',
                style: Theme.of(context).textTheme.displayMedium),
            const SizedBox(height: 10),
            const Text(
              'Your first matched job is free. Subscribe when you want the full list, saved jobs, and ongoing searches from your career matches.',
            ),
            const SizedBox(height: 22),
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
                        'Best value if you want GiftPath available through a longer season of discernment.',
                    icon: Icons.savings_outlined,
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
                    'The Opportunities page shows the full matched list instead of one free result. Your existing results, saved careers, and saved jobs stay private to your account.',
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

class _PlanCard extends StatelessWidget {
  const _PlanCard({
    required this.title,
    required this.price,
    required this.cadence,
    required this.description,
    required this.icon,
    required this.loading,
    required this.onPressed,
    this.primary = false,
  });

  final String title;
  final String price;
  final String cadence;
  final String description;
  final IconData icon;
  final bool loading;
  final VoidCallback onPressed;
  final bool primary;

  @override
  Widget build(BuildContext context) {
    return InfoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          IconBadge(icon, size: 42),
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
