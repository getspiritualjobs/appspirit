import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'core/theme.dart';
import 'features/about/about_page.dart';
import 'features/assessment/assessment_page.dart';
import 'features/auth/auth_page.dart';
import 'features/billing/billing_success_page.dart';
import 'features/careers/careers_page.dart';
import 'features/home/home_page.dart';
import 'features/opportunities/opportunities_page.dart';
import 'features/results/results_page.dart';
import 'features/saved/saved_page.dart';
import 'widgets/app_shell.dart';

class GiftPathApp extends StatelessWidget {
  const GiftPathApp({super.key});

  @override
  Widget build(BuildContext context) {
    final router = GoRouter(
      routes: [
        ShellRoute(
          builder: (context, state, child) => AppShell(child: child),
          routes: [
            GoRoute(path: '/', builder: (_, __) => const HomePage()),
            GoRoute(
                path: '/assessment',
                builder: (_, __) => const AssessmentPage()),
            GoRoute(path: '/results', builder: (_, __) => const ResultsPage()),
            GoRoute(path: '/careers', builder: (_, __) => const CareersPage()),
            GoRoute(
                path: '/opportunities',
                builder: (_, __) => const OpportunitiesPage()),
            GoRoute(path: '/saved', builder: (_, __) => const SavedPage()),
            GoRoute(path: '/about', builder: (_, __) => const AboutPage()),
            GoRoute(path: '/auth', builder: (_, __) => const AuthPage()),
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
