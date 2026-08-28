import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../widgets/brand_components.dart';
import '../../widgets/brand_mark.dart';
import '../../widgets/responsive.dart';

class ConfirmAccountPage extends StatelessWidget {
  const ConfirmAccountPage({super.key});

  String? _safeReturnTo(BuildContext context) {
    final value = GoRouterState.of(context).uri.queryParameters['returnTo'];
    return switch (value) {
      '/results' || '/opportunities' || '/saved' => value,
      _ => null,
    };
  }

  @override
  Widget build(BuildContext context) {
    final returnTo = _safeReturnTo(context);
    return SingleChildScrollView(
      child: PageBand(
        maxWidth: 680,
        child: InfoCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const IconBadge(Icons.mark_email_read_outlined, size: 48),
              const SizedBox(height: 16),
              const BrandEyebrow('Account confirmation'),
              const SizedBox(height: 10),
              Text('Confirm your account',
                  style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 10),
              const Text(
                'We sent a confirmation link to your email. Open it when you can so your GiftPath account can keep results, saved careers, and saved jobs across devices.',
              ),
              const SizedBox(height: 18),
              const BrandNotice(
                icon: Icons.info_outline,
                child: Text(
                  'You can keep viewing this result on the current device while the email confirmation is pending.',
                ),
              ),
              const SizedBox(height: 18),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  if (returnTo != null)
                    FilledButton.icon(
                      onPressed: () => context.go(returnTo),
                      icon: const Icon(Icons.arrow_forward),
                      label: Text(
                          returnTo == '/results' ? 'View results' : 'Continue'),
                    ),
                  OutlinedButton.icon(
                    onPressed: () => context.go('/auth'),
                    icon: const Icon(Icons.person_outline),
                    label: const Text('Back to account'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
