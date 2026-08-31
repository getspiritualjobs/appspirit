import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/app_state.dart';
import '../../widgets/brand_components.dart';
import '../../widgets/brand_mark.dart';
import '../../widgets/responsive.dart';

class BillingSuccessPage extends StatefulWidget {
  const BillingSuccessPage({super.key});

  @override
  State<BillingSuccessPage> createState() => _BillingSuccessPageState();
}

class _BillingSuccessPageState extends State<BillingSuccessPage> {
  var _confirming = true;

  @override
  void initState() {
    super.initState();
    unawaited(_confirmSubscription());
  }

  /// Stripe confirms the purchase through the webhook, which can land a moment
  /// after the redirect, so poll for it rather than assuming success. Access is
  /// never granted client side: refreshSubscription() is the only writer.
  Future<void> _confirmSubscription() async {
    for (var attempt = 0; attempt < 10; attempt++) {
      await appState.refreshSubscription();
      if (!mounted) return;
      if (appState.hasActiveSubscription) break;
      await Future<void>.delayed(const Duration(seconds: 2));
      if (!mounted) return;
    }
    if (mounted) setState(() => _confirming = false);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: appState,
      builder: (context, _) {
        final active = appState.hasActiveSubscription;
        return PageBand(
          maxWidth: 680,
          child: InfoCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                IconBadge(
                  active
                      ? Icons.check_circle_outline
                      : _confirming
                          ? Icons.hourglass_empty
                          : Icons.schedule_outlined,
                  size: 48,
                ),
                const SizedBox(height: 16),
                BrandEyebrow(active
                    ? 'Full access unlocked'
                    : _confirming
                        ? 'Confirming your payment'
                        : 'Still confirming'),
                const SizedBox(height: 8),
                Text(
                  active
                      ? 'Subscription active'
                      : _confirming
                          ? 'Finishing up'
                          : 'Payment received',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  active
                      ? 'You can now view the full opportunity list for your gift and career matches.'
                      : _confirming
                          ? 'Stripe is confirming your payment. This usually takes a few seconds.'
                          : 'Stripe has not confirmed the payment yet. It usually lands within a minute, and your access opens as soon as it does. Refresh this page, or contact us if it stays this way.',
                ),
                const SizedBox(height: 18),
                if (_confirming && !active)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(8),
                      child: CircularProgressIndicator(),
                    ),
                  )
                else
                  FilledButton.icon(
                    onPressed: () => context.go('/opportunities'),
                    icon: const Icon(Icons.work_outline),
                    label: Text(active
                        ? 'See All Opportunities'
                        : 'Back to Opportunities'),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
