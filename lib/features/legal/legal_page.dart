import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme.dart';
import '../../widgets/brand_components.dart';
import '../../widgets/responsive.dart';

enum LegalDocument { terms, privacy, cancellation }

class LegalPage extends StatelessWidget {
  const LegalPage({required this.document, super.key});

  final LegalDocument document;

  @override
  Widget build(BuildContext context) {
    final content = _contentFor(document);
    return SingleChildScrollView(
      child: PageBand(
        maxWidth: 860,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            BrandEyebrow(content.eyebrow),
            const SizedBox(height: 10),
            Text(content.title,
                style: Theme.of(context).textTheme.displayMedium),
            const SizedBox(height: 8),
            const Text('Draft last updated: August 28, 2026',
                style: TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: 18),
            const BrandNotice(
              icon: Icons.gavel_outlined,
              child: Text(
                'Draft for product planning. Have an attorney review before launch, especially before accepting paid subscribers.',
              ),
            ),
            const SizedBox(height: 18),
            for (final section in content.sections) ...[
              InfoCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(section.title,
                        style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 8),
                    for (final paragraph in section.paragraphs) ...[
                      Text(paragraph),
                      const SizedBox(height: 10),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 12),
            ],
            const SizedBox(height: 10),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                _LegalLink(
                    label: 'Terms',
                    path: '/terms',
                    active: document == LegalDocument.terms),
                _LegalLink(
                    label: 'Privacy',
                    path: '/privacy',
                    active: document == LegalDocument.privacy),
                _LegalLink(
                    label: 'Cancellation',
                    path: '/cancellation',
                    active: document == LegalDocument.cancellation),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _LegalLink extends StatelessWidget {
  const _LegalLink({
    required this.label,
    required this.path,
    required this.active,
  });

  final String label;
  final String path;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return active
        ? FilledButton(
            onPressed: null,
            style: FilledButton.styleFrom(
              disabledBackgroundColor: BrandTokens.forest,
              disabledForegroundColor: BrandTokens.cream,
            ),
            child: Text(label),
          )
        : OutlinedButton(
            onPressed: () => context.go(path),
            child: Text(label),
          );
  }
}

_LegalContent _contentFor(LegalDocument document) {
  return switch (document) {
    LegalDocument.terms => _terms,
    LegalDocument.privacy => _privacy,
    LegalDocument.cancellation => _cancellation,
  };
}

class _LegalContent {
  const _LegalContent({
    required this.eyebrow,
    required this.title,
    required this.sections,
  });

  final String eyebrow;
  final String title;
  final List<_LegalSection> sections;
}

class _LegalSection {
  const _LegalSection(this.title, this.paragraphs);

  final String title;
  final List<String> paragraphs;
}

const _terms = _LegalContent(
  eyebrow: 'Legal',
  title: 'Terms of service',
  sections: [
    _LegalSection('Use of GiftPath', [
      'GiftPath provides a Scripture-informed reflection tool for spiritual gifts, career exploration, and job discovery. It is not a promise of employment, a professional counseling service, or a determination of calling, spiritual worth, or God\'s will.',
      'You agree to use GiftPath honestly, lawfully, and for personal reflection or career exploration. You may not interfere with the service, scrape it at scale, or use it to harm another person.',
    ]),
    _LegalSection('Accounts', [
      'You may use some parts of GiftPath as a guest. Creating an account lets you save results, career matches, jobs, preferences, and billing status across devices.',
      'You are responsible for keeping your login information secure and for activity under your account.',
    ]),
    _LegalSection('Subscriptions and payment', [
      'GiftPath may offer paid subscription plans. Prices, billing intervals, and included features are shown before checkout. Payments are processed by Stripe; GiftPath does not store full card numbers.',
      'Unless a checkout screen says otherwise, subscriptions renew automatically until canceled.',
    ]),
    _LegalSection('Career and job information', [
      'Career information and match percentages are generated from your responses, seeded career data, preferences, and available job data from third-party providers. They are estimates for comparison, not guarantees.',
      'Job listings may change, expire, or contain errors from third-party sources. Always review the employer\'s posting before applying.',
    ]),
    _LegalSection('Changes and availability', [
      'GiftPath may change features, pricing, or availability over time. We will try to communicate material changes clearly.',
      'We may suspend or terminate accounts that misuse the service or violate these terms.',
    ]),
    _LegalSection('Contact', [
      'Questions about these terms can be sent to get.spiritual.jobs@gmail.com.',
    ]),
  ],
);

const _privacy = _LegalContent(
  eyebrow: 'Privacy',
  title: 'Privacy policy',
  sections: [
    _LegalSection('Information we collect', [
      'GiftPath may collect your email address, authentication details, assessment responses, spiritual gift scores, career matches, saved careers, saved jobs, job search preferences, subscription status, and basic technical information needed to run the app.',
      'If you use Google sign-in, Supabase receives account information from Google so authentication can work. If you subscribe, Stripe processes payment and billing information.',
    ]),
    _LegalSection('How we use information', [
      'We use your information to score the assessment, show career and job matches, save your preferences, operate subscriptions, provide account access, troubleshoot the service, and improve GiftPath.',
      'We do not sell your assessment responses. We do not publish your results, saved jobs, or saved careers as a public profile.',
    ]),
    _LegalSection('Service providers', [
      'GiftPath uses Supabase for authentication and database services, Stripe for payments and subscription management, Resend for transactional email, Cloudflare for hosting and delivery, and job data providers such as Adzuna for live listings.',
      'These providers process information as needed to deliver their services to GiftPath.',
    ]),
    _LegalSection('Your choices', [
      'You can use guest mode for local exploration, create an account for saved data, request a password reset, manage or cancel a subscription through Stripe\'s billing portal, and ask us about deleting account data.',
      'Some records may be retained when needed for security, billing, compliance, or dispute resolution.',
    ]),
    _LegalSection('Security', [
      'We use Supabase row-level security and server-side functions so private saved data and API keys are not exposed directly in the client. No web service can guarantee perfect security.',
    ]),
    _LegalSection('Contact', [
      'Privacy questions can be sent to get.spiritual.jobs@gmail.com.',
    ]),
  ],
);

const _cancellation = _LegalContent(
  eyebrow: 'Billing',
  title: 'Cancellation policy',
  sections: [
    _LegalSection('How to cancel', [
      'You can cancel your GiftPath subscription from Account by opening the Stripe billing portal. The portal lets you view the subscription, update payment details, and cancel future renewal.',
      'If you cannot access your account, contact get.spiritual.jobs@gmail.com for help locating the subscription.',
    ]),
    _LegalSection('What happens after cancellation', [
      'Cancellation stops future renewal. Unless the checkout or portal says otherwise, you keep paid access through the end of the current billing period.',
      'After paid access ends, your account can still keep saved results, but premium opportunity features may return to the free limit.',
    ]),
    _LegalSection('Refunds', [
      'Subscription fees are generally non-refundable once a billing period begins, except where required by law or when GiftPath chooses to make an exception.',
      'If there was a billing error, duplicate charge, or technical issue that prevented access, contact us and include the email used for checkout.',
    ]),
    _LegalSection('Price or plan changes', [
      'If pricing or plan features change, GiftPath will aim to communicate the change before it affects an existing paid subscription.',
    ]),
  ],
);
