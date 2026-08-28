import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'core/theme.dart';
import 'features/about/about_page.dart';
import 'features/assessment/assessment_page.dart';
import 'features/auth/auth_page.dart';
import 'features/blog/blog_page.dart';
import 'features/billing/billing_success_page.dart';
import 'features/billing/subscribe_page.dart';
import 'features/legal/confirm_account_page.dart';
import 'features/legal/legal_page.dart';
import 'features/home/home_page.dart';
import 'features/opportunities/opportunities_page.dart';
import 'features/results/results_page.dart';
import 'features/saved/saved_page.dart';
import 'widgets/app_shell.dart';

class GiftPathApp extends StatelessWidget {
  const GiftPathApp({this.initialLocation, super.key});

  final String? initialLocation;

  @override
  Widget build(BuildContext context) {
    final router = GoRouter(
      initialLocation: initialLocation,
      overridePlatformDefaultLocation: initialLocation != null,
      routes: [
        ShellRoute(
          builder: (context, state, child) => AppShell(child: child),
          routes: [
            GoRoute(path: '/', builder: (_, __) => const HomePage()),
            GoRoute(
                path: '/assessment',
                builder: (_, __) => const AssessmentPage()),
            GoRoute(path: '/results', builder: (_, __) => const ResultsPage()),
            GoRoute(path: '/careers', redirect: (_, __) => '/opportunities'),
            GoRoute(
                path: '/opportunities',
                builder: (_, __) => const OpportunitiesPage()),
            GoRoute(path: '/blog', builder: (_, __) => const BlogPage()),
            GoRoute(
              path: '/blog/:slug',
              builder: (_, state) =>
                  BlogPostPage(slug: state.pathParameters['slug'] ?? ''),
            ),
            GoRoute(path: '/saved', builder: (_, __) => const SavedPage()),
            GoRoute(path: '/about', builder: (_, __) => const AboutPage()),
            GoRoute(path: '/auth', builder: (_, __) => const AuthPage()),
            GoRoute(
                path: '/confirm-account',
                builder: (_, __) => const ConfirmAccountPage()),
            GoRoute(
                path: '/reset-password',
                builder: (_, __) => const AuthPage(resetPasswordOnly: true)),
            GoRoute(
                path: '/terms',
                builder: (_, __) =>
                    const LegalPage(document: LegalDocument.terms)),
            GoRoute(
                path: '/privacy',
                builder: (_, __) =>
                    const LegalPage(document: LegalDocument.privacy)),
            GoRoute(
                path: '/cancellation',
                builder: (_, __) =>
                    const LegalPage(document: LegalDocument.cancellation)),
            GoRoute(
                path: '/subscribe', builder: (_, __) => const SubscribePage()),
            GoRoute(
                path: '/billing/success',
                builder: (_, __) => const BillingSuccessPage()),
          ],
        ),
      ],
    );

    return MaterialApp.router(
      title: 'GiftPath',
      debugShowCheckedModeBanner: false,
      theme: buildGiftPathTheme(),
      routerConfig: router,
    );
  }
}
