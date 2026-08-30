import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:spiritual_gifts_career_discovery/core/app_state.dart';
import 'package:spiritual_gifts_career_discovery/core/models.dart';
import 'package:spiritual_gifts_career_discovery/core/theme.dart';
import 'package:spiritual_gifts_career_discovery/data/seed_data.dart';
import 'package:spiritual_gifts_career_discovery/features/assessment/assessment_page.dart';
import 'package:spiritual_gifts_career_discovery/features/auth/auth_page.dart';
import 'package:spiritual_gifts_career_discovery/features/blog/blog_page.dart';
import 'package:spiritual_gifts_career_discovery/features/billing/subscribe_page.dart';
import 'package:spiritual_gifts_career_discovery/features/legal/confirm_account_page.dart';
import 'package:spiritual_gifts_career_discovery/features/legal/legal_page.dart';
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
    expect(find.text('BEFORE YOU BEGIN'), findsOneWidget);
    expect(find.text('Assessment data notice'), findsOneWidget);

    await tester.ensureVisible(find.byType(Checkbox));
    await tester.tap(find.byType(Checkbox));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Start assessment'));
    await tester.tap(find.text('Start assessment'));
    await tester.pumpAndSettle();

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

    expect(find.text('Your results are ready'), findsNothing);

    await tester.pumpWidget(MaterialApp.router(
      theme: buildGiftPathTheme(),
      routerConfig: _routerFor('/auth?returnTo=/results'),
    ));
    await tester.pumpAndSettle();

    expect(find.text('Your results are ready'), findsOneWidget);
    expect(
      find.text(
          'Create an account to keep your gift profile, sign in if you already have one, or continue as a guest on this device.'),
      findsOneWidget,
    );
  });

  testWidgets('reset password route opens the new password page',
      (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp.router(
      theme: buildGiftPathTheme(),
      routerConfig: _routerFor('/reset-password'),
    ));
    await tester.pumpAndSettle();

    expect(find.text('Reset your password'), findsOneWidget);
    expect(find.text('PRIVATE SAVING'), findsNothing);
  });

  testWidgets('confirm account route explains the email step',
      (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp.router(
      theme: buildGiftPathTheme(),
      routerConfig: _routerFor('/confirm-account?returnTo=/results'),
    ));
    await tester.pumpAndSettle();

    expect(find.text('Confirm your account'), findsOneWidget);
    expect(find.text('View results'), findsOneWidget);
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

    expect(find.text('Your results are ready'), findsOneWidget);
  });

  testWidgets('assessment page recognizes completed results and can retake',
      (WidgetTester tester) async {
    appState.giftScores = const [
      GiftScore(gift: GiftKey.teaching, rawScore: 5, normalizedScore: 94),
    ];
    appState.careerMatches = [
      CareerMatch(
        career: careers.first,
        score: 94,
        strongestGifts: const [GiftKey.teaching],
        reason: 'Test match.',
      ),
    ];

    await tester.pumpWidget(MaterialApp.router(
      theme: buildGiftPathTheme(),
      routerConfig: _routerFor('/assessment'),
    ));
    await tester.pumpAndSettle();

    expect(find.text('You have already taken the quiz.'), findsOneWidget);
    expect(find.text('View results'), findsOneWidget);

    await tester.tap(find.text('Retake assessment'));
    await tester.pumpAndSettle();

    expect(find.text('BEFORE YOU BEGIN'), findsOneWidget);
    expect(find.text('Start assessment'), findsOneWidget);
    expect(appState.hasResults, isFalse);
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
    expect(find.text('Career lanes'), findsWidgets);
    expect(find.text('Refine'), findsWidgets);
    expect(find.text('Live jobs'), findsWidgets);
    expect(find.text('Unlock Full List'), findsNothing);

    await tester.ensureVisible(find.text('Refine work preferences'));
    await tester.tap(find.text('Refine work preferences'));
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('See suggested jobs'));
    await tester.tap(find.text('See suggested jobs'));
    await tester.pumpAndSettle();

    expect(find.text('Suggested live matches'), findsOneWidget);
    expect(find.text('How job match works'), findsOneWidget);
    expect(find.text('Unlock Full List'), findsOneWidget);
    expect(find.textContaining(r'$7.77'), findsNothing);
    expect(find.textContaining(r'$77.77'), findsNothing);
  });

  testWidgets('opportunities progression renders on mobile width',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(390, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    appState.giftScores = const [
      GiftScore(gift: GiftKey.teaching, rawScore: 5, normalizedScore: 94),
    ];
    appState.careerMatches = [
      CareerMatch(
        career: careers.first,
        score: 94,
        strongestGifts: const [GiftKey.teaching],
        reason: 'Test match for mobile opportunities.',
      ),
    ];

    await tester.pumpWidget(_shell(const OpportunitiesPage()));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('Career lanes'), findsWidgets);
    expect(find.text('Refine'), findsWidgets);
    expect(find.text('Live jobs'), findsWidgets);
  });

  testWidgets('subscribe screen shows monthly and yearly choices',
      (WidgetTester tester) async {
    await tester.pumpWidget(_shell(const SubscribePage()));

    expect(find.text('FULL ACCESS'), findsOneWidget);
    expect(find.textContaining(r'$7.77'), findsOneWidget);
    expect(find.textContaining(r'$77.77'), findsOneWidget);
  });

  testWidgets('legal pages include launch policy drafts',
      (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp.router(
      theme: buildGiftPathTheme(),
      routerConfig: _routerFor('/cancellation'),
    ));
    await tester.pumpAndSettle();

    expect(find.text('Cancellation policy'), findsOneWidget);
    expect(find.text('How to cancel'), findsOneWidget);
    expect(find.textContaining('Stripe billing portal'), findsOneWidget);
  });

  testWidgets('blog list and post routes render launch content',
      (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp.router(
      theme: buildGiftPathTheme(),
      routerConfig: _routerFor('/blog'),
    ));
    await tester.pumpAndSettle();

    expect(find.text('GIFTPATH JOURNAL'), findsOneWidget);
    expect(find.text('Notes on gifts, work, and next steps'), findsOneWidget);

    await tester.pumpWidget(MaterialApp.router(
      theme: buildGiftPathTheme(),
      routerConfig: _routerFor('/blog/spiritual-gifts-and-career-discernment'),
    ));
    await tester.pumpAndSettle();

    expect(find.text('How spiritual gifts can shape career discernment'),
        findsOneWidget);
    expect(find.text('Take the assessment'), findsOneWidget);
  });

  testWidgets('blog editor requires admin access', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp.router(
      theme: buildGiftPathTheme(),
      routerConfig: _routerFor('/blog/new'),
    ));
    await tester.pumpAndSettle();

    expect(find.text('Admin access needed'), findsOneWidget);
    expect(find.text('Write a blog post'), findsNothing);
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
        path: '/confirm-account',
        builder: (_, __) => const Scaffold(body: ConfirmAccountPage()),
      ),
      GoRoute(
        path: '/reset-password',
        builder: (_, __) =>
            const Scaffold(body: AuthPage(resetPasswordOnly: true)),
      ),
      GoRoute(
        path: '/terms',
        builder: (_, __) =>
            const Scaffold(body: LegalPage(document: LegalDocument.terms)),
      ),
      GoRoute(
        path: '/privacy',
        builder: (_, __) =>
            const Scaffold(body: LegalPage(document: LegalDocument.privacy)),
      ),
      GoRoute(
        path: '/cancellation',
        builder: (_, __) => const Scaffold(
            body: LegalPage(document: LegalDocument.cancellation)),
      ),
      GoRoute(
        path: '/results',
        builder: (_, __) => const Scaffold(body: Text('Results')),
      ),
      GoRoute(
        path: '/blog',
        builder: (_, __) => const Scaffold(body: BlogPage()),
      ),
      GoRoute(
        path: '/blog/new',
        builder: (_, __) => const Scaffold(body: BlogEditorPage()),
      ),
      GoRoute(
        path: '/blog/:slug/edit',
        builder: (_, state) => Scaffold(
          body: BlogEditorPage(slug: state.pathParameters['slug']),
        ),
      ),
      GoRoute(
        path: '/blog/:slug',
        builder: (_, state) => Scaffold(
          body: BlogPostPage(slug: state.pathParameters['slug'] ?? ''),
        ),
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
  appState.assessmentConsentAccepted = false;
}
