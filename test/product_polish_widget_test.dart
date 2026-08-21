import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:spiritual_gifts_career_discovery/core/app_state.dart';
import 'package:spiritual_gifts_career_discovery/core/models.dart';
import 'package:spiritual_gifts_career_discovery/core/theme.dart';
import 'package:spiritual_gifts_career_discovery/data/seed_data.dart';
import 'package:spiritual_gifts_career_discovery/features/assessment/assessment_page.dart';
import 'package:spiritual_gifts_career_discovery/features/auth/auth_page.dart';
import 'package:spiritual_gifts_career_discovery/features/billing/subscribe_page.dart';
import 'package:spiritual_gifts_career_discovery/features/opportunities/opportunities_page.dart';
import 'package:spiritual_gifts_career_discovery/features/results/results_page.dart';
import 'package:spiritual_gifts_career_discovery/widgets/brand_components.dart';

void main() {
  tearDown(_resetAppState);

  testWidgets('brand divider and dashed path progress render',
      (WidgetTester tester) async {
    await tester.pumpWidget(_shell(const Column(
      children: [
        BrandEyebrow('Scripture-informed assessment'),
        BrandDivider(),
        SizedBox(
          width: 360,
          height: 72,
          child: DashedPathProgress(total: 56, currentIndex: 12, answered: 12),
        ),
      ],
    )));

    expect(find.text('SCRIPTURE-INFORMED ASSESSMENT'), findsOneWidget);
    expect(find.text('◆'), findsOneWidget);
    expect(find.text('12 of 56 answered'), findsOneWidget);
  });

  testWidgets('assessment uses the branded question trail',
      (WidgetTester tester) async {
    await tester.pumpWidget(_shell(const AssessmentPage()));

    expect(find.text('ONE QUESTION AT A TIME'), findsOneWidget);
    expect(find.text('Question 1 of 56'), findsOneWidget);
    expect(find.text('QUESTION TRAIL'), findsOneWidget);
    expect(find.text('0 of 56 answered'), findsOneWidget);
  });

  testWidgets('auth return flow frames sign up before results',
      (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp.router(
      theme: buildGiftPathTheme(),
      routerConfig: _routerFor('/auth'),
    ));
    await tester.pumpAndSettle();

    expect(find.text('Create an account to view your results'), findsNothing);

    await tester.pumpWidget(MaterialApp.router(
      theme: buildGiftPathTheme(),
      routerConfig: _routerFor('/auth?returnTo=/results'),
    ));
    await tester.pumpAndSettle();

    expect(find.text('Create an account to view your results'), findsOneWidget);
    expect(
      find.text(
          'Your assessment is complete. Sign up, sign in, or continue as a guest to see your gift profile and career matches.'),
      findsOneWidget,
    );
  });

  testWidgets('completed assessment routes through account step before results',
      (WidgetTester tester) async {
    for (final question in assessmentQuestions) {
      appState.answer(question.id, 4);
    }

    await tester.pumpWidget(MaterialApp.router(
      theme: buildGiftPathTheme(),
      routerConfig: _routerFor('/assessment'),
    ));
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Reveal My Gifts'));
    await tester.tap(find.text('Reveal My Gifts'));
    await tester.pumpAndSettle();

    expect(find.text('Create an account to view your results'), findsOneWidget);
  });

  testWidgets('results gives the top gift a reveal treatment',
      (WidgetTester tester) async {
    appState.giftScores = const [
      GiftScore(gift: GiftKey.teaching, rawScore: 5, normalizedScore: 94),
      GiftScore(gift: GiftKey.encouragement, rawScore: 4, normalizedScore: 88),
      GiftScore(gift: GiftKey.serving, rawScore: 4, normalizedScore: 84),
    ];

    await tester.pumpWidget(_shell(const ResultsPage()));

    expect(find.text('YOUR GIFT PROFILE'), findsOneWidget);
    expect(find.text('TOP GIFT REVEAL'), findsOneWidget);
    expect(find.text('Teaching'), findsWidgets);
  });

  testWidgets('opportunities paywall opens without showing plan prices',
      (WidgetTester tester) async {
    appState.giftScores = const [
      GiftScore(gift: GiftKey.teaching, rawScore: 5, normalizedScore: 94),
    ];
    appState.careerMatches = [
      CareerMatch(
        career: careers.first,
        score: 94,
        strongestGifts: const [GiftKey.teaching],
        reason: 'Test match for the opportunities paywall.',
      ),
    ];

    await tester.pumpWidget(_shell(const OpportunitiesPage()));
    await tester.pumpAndSettle();

    expect(find.text('MATCHED OPPORTUNITIES'), findsOneWidget);
    expect(find.text('Unlock Full List'), findsOneWidget);
    expect(find.textContaining(r'$7.77'), findsNothing);
    expect(find.textContaining(r'$77.77'), findsNothing);
  });

  testWidgets('subscribe screen shows monthly and yearly choices',
      (WidgetTester tester) async {
    await tester.pumpWidget(_shell(const SubscribePage()));

    expect(find.text('FULL ACCESS'), findsOneWidget);
    expect(find.textContaining(r'$7.77'), findsOneWidget);
    expect(find.textContaining(r'$77.77'), findsOneWidget);
  });
}

Widget _shell(Widget child) {
  return MaterialApp(
    theme: buildGiftPathTheme(),
    home: Scaffold(body: SingleChildScrollView(child: child)),
  );
}

GoRouter _routerFor(String initialLocation) {
  return GoRouter(
    initialLocation: initialLocation,
    routes: [
      GoRoute(
        path: '/assessment',
        builder: (_, __) => const Scaffold(body: AssessmentPage()),
      ),
      GoRoute(
          path: '/auth', builder: (_, __) => const Scaffold(body: AuthPage())),
      GoRoute(
        path: '/results',
        builder: (_, __) => const Scaffold(body: Text('Results')),
      ),
    ],
  );
}

void _resetAppState() {
  appState.responses.clear();
  appState.giftScores = const [];
  appState.careerMatches = const [];
  appState.preference = const UserPreference();
  appState.savedCareers.clear();
  appState.savedJobs.clear();
  appState.savedResults = const [];
  appState.savedResult = const [];
  appState.hasActiveSubscription = false;
  appState.latestAssessmentId = null;
  appState.assessmentSaveError = null;
  appState.savedDataError = null;
}
