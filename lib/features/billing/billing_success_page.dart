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
  @override
  void initState() {
    super.initState();
    appState.activateSubscription();
    appState.refreshSubscription();
  }

  @override
  Widget build(BuildContext context) {
    return PageBand(
      maxWidth: 680,
      child: InfoCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const IconBadge(Icons.check_circle_outline, size: 48),
            const SizedBox(height: 16),
            const BrandEyebrow('Full access unlocked'),
            const SizedBox(height: 8),
            Text('Subscription active',
                style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 8),
            const Text(
              'You can now view the full opportunity list for your gift and career matches on this device.',
            ),
            const SizedBox(height: 18),
            FilledButton.icon(
              onPressed: () => context.go('/opportunities'),
              icon: const Icon(Icons.work_outline),
              label: const Text('See All Opportunities'),
            ),
          ],
        ),
      ),
    );
  }
}
