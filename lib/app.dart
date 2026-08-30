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
            GoRoute(
              path: '/',
              pageBuilder: (_, state) => _brandPage(state, const HomePage()),
            ),
            GoRoute(
              path: '/assessment',
              pageBuilder: (_, state) =>
                  _brandPage(state, const AssessmentPage()),
            ),
            GoRoute(
              path: '/results',
              pageBuilder: (_, state) => _brandPage(state, const ResultsPage()),
            ),
            GoRoute(path: '/careers', redirect: (_, __) => '/opportunities'),
            GoRoute(
              path: '/opportunities',
              pageBuilder: (_, state) =>
                  _brandPage(state, const OpportunitiesPage()),
            ),
            GoRoute(
              path: '/blog',
              pageBuilder: (_, state) => _brandPage(state, const BlogPage()),
            ),
            GoRoute(
              path: '/blog/new',
              pageBuilder: (_, state) =>
                  _brandPage(state, const BlogEditorPage()),
            ),
            GoRoute(
              path: '/blog/:slug/edit',
              pageBuilder: (_, state) => _brandPage(
                state,
                BlogEditorPage(slug: state.pathParameters['slug']),
              ),
            ),
            GoRoute(
              path: '/blog/:slug',
              pageBuilder: (_, state) => _brandPage(
                state,
                BlogPostPage(slug: state.pathParameters['slug'] ?? ''),
              ),
            ),
            GoRoute(
              path: '/saved',
              pageBuilder: (_, state) => _brandPage(state, const SavedPage()),
            ),
            GoRoute(
              path: '/about',
              pageBuilder: (_, state) => _brandPage(state, const AboutPage()),
            ),
            GoRoute(
              path: '/auth',
              pageBuilder: (_, state) => _brandPage(state, const AuthPage()),
            ),
            GoRoute(
              path: '/confirm-account',
              pageBuilder: (_, state) =>
                  _brandPage(state, const ConfirmAccountPage()),
            ),
            GoRoute(
              path: '/reset-password',
              pageBuilder: (_, state) =>
                  _brandPage(state, const AuthPage(resetPasswordOnly: true)),
            ),
            GoRoute(
              path: '/terms',
              pageBuilder: (_, state) => _brandPage(
                  state, const LegalPage(document: LegalDocument.terms)),
            ),
            GoRoute(
              path: '/privacy',
              pageBuilder: (_, state) => _brandPage(
                  state, const LegalPage(document: LegalDocument.privacy)),
            ),
            GoRoute(
              path: '/cancellation',
              pageBuilder: (_, state) => _brandPage(
                  state, const LegalPage(document: LegalDocument.cancellation)),
            ),
            GoRoute(
              path: '/subscribe',
              pageBuilder: (_, state) =>
                  _brandPage(state, const SubscribePage()),
            ),
            GoRoute(
              path: '/billing/success',
              pageBuilder: (_, state) =>
                  _brandPage(state, const BillingSuccessPage()),
            ),
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

CustomTransitionPage<void> _brandPage(GoRouterState state, Widget child) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    transitionDuration: const Duration(milliseconds: 180),
    reverseTransitionDuration: const Duration(milliseconds: 140),
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final reduceMotion = MediaQuery.disableAnimationsOf(context);
      if (reduceMotion) return child;
      final curved = CurvedAnimation(
        parent: animation,
        curve: const Cubic(.2, .7, .3, 1),
        reverseCurve: Curves.easeOut,
      );
      return FadeTransition(
        opacity: curved,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, .012),
            end: Offset.zero,
          ).animate(curved),
          child: child,
        ),
      );
    },
  );
}
