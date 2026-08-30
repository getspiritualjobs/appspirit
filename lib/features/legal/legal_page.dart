import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/legal_versions.dart';
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
            const Text('Draft last updated: $legalDocumentVersion',
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
    _LegalSection('Who operates GiftPath', [
      'GiftPath is operated by MyOrdr LLC. For contracts, legal policies, invoices, and other formal documents, the operator is MyOrdr LLC, an Arizona limited liability company, doing business as GiftPath.',
      'GiftPath is a trade name for the spiritual-gifts and career-matching software product. It does not create a separate company, tax account, bank account, or liability structure from MyOrdr LLC.',
    ]),
    _LegalSection('Eligibility and acceptance', [
      'You must be at least 18 years old to use GiftPath. Before submitting assessment responses, you must confirm that you are 18 or older and accept these Terms of Service and the Privacy Policy.',
      'GiftPath may record the version of the Terms, Privacy Policy, and assessment data notice you accepted, along with the time of acceptance and the account or session connected to that acceptance.',
    ]),
    _LegalSection('Use of GiftPath', [
      'GiftPath provides a Scripture-informed reflection tool for spiritual gifts, career exploration, and job discovery. It is not a promise of employment, a professional counseling service, or a determination of calling, spiritual worth, or God\'s will.',
      'You agree to use GiftPath honestly, lawfully, and for personal reflection or career exploration. You may not interfere with the service, scrape it at scale, or use it to harm another person.',
    ]),
    _LegalSection('Assessment data notice', [
      'The assessment asks reflective questions related to spiritual gifts and uses your answers to generate gift scores, career lanes, and job matches. By submitting the assessment, you authorize GiftPath to process those responses for those purposes.',
      'Your results are intended to help you notice patterns and choose practical next steps. They should be used with prayer, trusted counsel, and your own judgment.',
    ]),
    _LegalSection('Accounts', [
      'You may use some parts of GiftPath as a guest. Creating an account lets you save results, career matches, jobs, preferences, and billing status across devices.',
      'You are responsible for keeping your login information secure and for activity under your account.',
      'Deleting your GiftPath account is separate from canceling a paid subscription. If you have an active subscription, use the Stripe billing portal to cancel renewal before requesting account deletion.',
    ]),
    _LegalSection('Subscriptions and payment', [
      'GiftPath may offer monthly and annual paid subscription plans. Prices, billing intervals, renewal terms, taxes, and included features are shown before checkout. Payments are processed by Stripe; GiftPath does not store full card numbers.',
      'Paid subscriptions renew automatically until canceled. You can cancel future renewal online through the Stripe billing portal from your Account screen.',
    ]),
    _LegalSection('Career and job information', [
      'Career information, alignment percentages, and job suggestions are generated from your GiftPath profile, preferences, and available job information. They are estimates for comparison, not guarantees.',
      'Job listings may change, expire, or contain errors from third-party sources. Always review the employer\'s posting before applying.',
    ]),
    _LegalSection('Changes and availability', [
      'GiftPath may change features, pricing, or availability over time. We will try to communicate material changes clearly.',
      'We may suspend or terminate accounts that misuse the service or violate these terms.',
    ]),
    _LegalSection('Trade name and trademarks', [
      'An Arizona trade name registration, if approved, identifies GiftPath as a trade name used by MyOrdr LLC. It does not by itself provide nationwide trademark protection.',
      'Before substantial nationwide marketing, GiftPath should complete a federal trademark clearance review.',
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
    _LegalSection('Who operates GiftPath', [
      'GiftPath is operated by MyOrdr LLC. For formal legal purposes, the operator is MyOrdr LLC, an Arizona limited liability company, doing business as GiftPath.',
      'This policy explains how GiftPath handles information for the spiritual-gifts assessment, career matching, saved results, job exploration, billing, and related account features.',
    ]),
    _LegalSection('Information we collect', [
      'GiftPath may collect your email address, authentication details, assessment responses, spiritual gift scores, career matches, saved careers, saved jobs, job search preferences, subscription status, and basic technical information needed to run the app.',
      'If you use Google sign-in, Supabase receives account information from Google so authentication can work. If you subscribe, Stripe processes payment and billing information.',
      'When you submit the assessment, GiftPath may record that you confirmed you are 18 or older and accepted the current Terms, Privacy Policy, and assessment data notice.',
    ]),
    _LegalSection('How we use information', [
      'We use your information to score the assessment, show career and job matches, save your preferences, operate subscriptions, provide account access, troubleshoot the service, and improve GiftPath.',
      'We do not sell identifiable spiritual-gift profiles or assessment responses. We do not publish your results, saved jobs, or saved careers as a public profile.',
      'If GiftPath uses aggregate insights commercially, those insights should be de-identified so they do not identify a specific person or expose a specific user\'s spiritual-gift profile.',
    ]),
    _LegalSection('Assessment and account data', [
      'Where practical, GiftPath separates identifying account information from assessment responses and generated scores. Some connection is still needed so logged-in users can save, retrieve, export, or delete their own results.',
      'Saved assessment data is used to keep your results available across devices and to support career and opportunity matching.',
    ]),
    _LegalSection('Service providers', [
      'GiftPath uses Supabase for authentication and database services, Stripe for payments and subscription management, Resend for transactional email, Cloudflare for hosting and delivery, and third-party job data providers for available listings.',
      'These providers process information as needed to deliver their services to GiftPath.',
    ]),
    _LegalSection('Your choices', [
      'You can use guest mode for local exploration, create an account for saved data, request a password reset, manage or cancel a subscription through Stripe\'s billing portal, and ask us about deleting account data.',
      'You may request access to your data, a practical export of your saved GiftPath information, correction where appropriate, or deletion of account data by contacting us.',
      'Subscription cancellation and account deletion are separate controls. Canceling a subscription stops future billing but does not automatically delete your account. Deleting an account does not automatically resolve a Stripe subscription unless the subscription is canceled first.',
      'Some records may be retained when needed for security, billing, compliance, or dispute resolution.',
    ]),
    _LegalSection('Security', [
      'We use Supabase row-level security, server-side authorization checks, protected API keys, and administrative access controls so private saved data and third-party credentials are not exposed directly in the client.',
      'No web service can guarantee perfect security, but GiftPath is designed so each user can only access their own saved results, careers, jobs, preferences, and billing-related state.',
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
    _LegalSection('Automatic renewal', [
      'GiftPath may offer monthly and annual subscription plans. The checkout page shows the price, billing interval, and renewal terms before you subscribe.',
      'Unless the checkout page says otherwise, subscriptions renew automatically until canceled.',
    ]),
    _LegalSection('How to cancel', [
      'You can cancel your GiftPath subscription from Account by opening the Stripe billing portal. The portal lets you view the subscription, update payment details, and cancel future renewal.',
      'If you cannot access your account, contact get.spiritual.jobs@gmail.com for help locating the subscription.',
    ]),
    _LegalSection('What happens after cancellation', [
      'Cancellation stops future renewal. Unless the checkout or portal says otherwise, you keep paid access through the end of the current billing period.',
      'After paid access ends, your account can still keep saved results, but premium opportunity features may return to the free limit.',
      'Canceling your subscription does not delete your GiftPath account or assessment data. Account deletion is a separate privacy request.',
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
