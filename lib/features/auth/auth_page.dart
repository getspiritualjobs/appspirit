import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/app_state.dart';
import '../../core/env.dart';
import '../../core/theme.dart';
import '../../data/billing_service.dart';
import '../../widgets/brand_components.dart';
import '../../widgets/brand_mark.dart';
import '../../widgets/responsive.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({this.resetPasswordOnly = false, super.key});

  final bool resetPasswordOnly;

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final email = TextEditingController();
  final password = TextEditingController();
  final resetPassword = TextEditingController();
  StreamSubscription<AuthState>? authSubscription;
  bool createMode = true;
  bool loading = false;
  bool forgotPasswordMode = false;
  bool resetPasswordMode = false;
  String message = '';

  String? get _safeReturnTo {
    final value = GoRouterState.of(context).uri.queryParameters['returnTo'];
    return switch (value) {
      '/results' || '/opportunities' || '/saved' => value,
      _ => null,
    };
  }

  bool get _returningToResults => _safeReturnTo == '/results';

  @override
  void initState() {
    super.initState();
    if (widget.resetPasswordOnly) {
      resetPasswordMode = true;
      createMode = false;
    }
    if (Env.hasSupabase) {
      authSubscription =
          Supabase.instance.client.auth.onAuthStateChange.listen((state) {
        if (!mounted) return;
        setState(() {
          if (state.event == AuthChangeEvent.passwordRecovery) {
            resetPasswordMode = true;
            createMode = false;
            message = '';
          }
        });
      });
    }
  }

  @override
  void dispose() {
    authSubscription?.cancel();
    email.dispose();
    password.dispose();
    resetPassword.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final session =
        Env.hasSupabase ? Supabase.instance.client.auth.currentSession : null;
    final user = session?.user;
    final isGuest = user?.isAnonymous ?? false;
    final isRealAccount = user != null && !isGuest;
    final returnTo = _safeReturnTo;
    final returningToResults = _returningToResults;
    final resettingPassword = widget.resetPasswordOnly || resetPasswordMode;

    return SingleChildScrollView(
      child: PageBand(
        maxWidth: 620,
        child: InfoCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!resettingPassword) ...[
                const BrandEyebrow('Private saving'),
                const SizedBox(height: 10),
              ],
              Text(
                resettingPassword
                    ? 'Reset your password'
                    : returningToResults
                        ? 'Your results are ready'
                        : 'Save your results and opportunities',
                style: resettingPassword
                    ? Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                        )
                    : Theme.of(context).textTheme.headlineMedium,
              ),
              if (!resettingPassword) ...[
                const SizedBox(height: 8),
                Text(returningToResults
                    ? 'Create an account to keep your gift profile, sign in if you already have one, or continue as a guest on this device.'
                    : 'Create an account when you want your results, career matches, saved jobs, and search preferences to follow you across devices.'),
              ],
              if (returningToResults && !resettingPassword) ...[
                const SizedBox(height: 18),
                const _ResultsHandoffTrail(),
              ],
              const SizedBox(height: 18),
              if (!Env.hasSupabase)
                const _SetupNotice()
              else if (resettingPassword)
                _ResetPasswordPanel(
                  controller: resetPassword,
                  loading: loading,
                  message: message,
                  onSubmit: _updateRecoveredPassword,
                )
              else if (forgotPasswordMode)
                _ForgotPasswordPanel(
                  controller: email,
                  loading: loading,
                  message: message,
                  onBack: () => setState(() {
                    forgotPasswordMode = false;
                    createMode = false;
                    message = '';
                  }),
                  onSubmit: _sendPasswordReset,
                )
              else if (isRealAccount)
                _AccountPanel(
                  email: user.email ?? 'Signed-in user',
                  returnTo: returnTo,
                  loading: loading,
                  hasActiveSubscription: appState.hasActiveSubscription,
                  onManageBilling: _manageBilling,
                  onSignOut: () async {
                    await Supabase.instance.client.auth.signOut();
                    if (mounted) setState(() => message = 'Signed out.');
                  },
                )
              else ...[
                if (isGuest) const _GuestPanel(),
                if (isGuest) const SizedBox(height: 16),
                _AuthModeToggle(
                  createMode: createMode,
                  enabled: !loading,
                  onChanged: (value) => setState(() => createMode = value),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: email,
                  enabled: !loading,
                  keyboardType: TextInputType.emailAddress,
                  autofillHints: const [AutofillHints.email],
                  decoration: const InputDecoration(labelText: 'Email'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: password,
                  enabled: !loading,
                  obscureText: true,
                  autofillHints: const [AutofillHints.password],
                  decoration: InputDecoration(
                      labelText: createMode ? 'Create a password' : 'Password'),
                ),
                if (!createMode) ...[
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton.icon(
                      onPressed: loading
                          ? null
                          : () => setState(() {
                                forgotPasswordMode = true;
                                message = '';
                              }),
                      icon: const Icon(Icons.lock_reset, size: 18),
                      label: const Text('Forgot password?'),
                    ),
                  ),
                ],
                const SizedBox(height: 14),
                FilledButton(
                  onPressed:
                      loading ? null : () => _emailAuth(create: createMode),
                  child: Text(loading
                      ? 'Working...'
                      : createMode
                          ? 'Create account'
                          : 'Sign in'),
                ),
                const SizedBox(height: 10),
                OutlinedButton(
                  onPressed: loading ? null : _google,
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      GoogleMark(size: 18),
                      SizedBox(width: 10),
                      Text('Continue with Google'),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                TextButton(
                  onPressed: loading || isGuest ? null : _continueAsGuest,
                  child: Text(returningToResults
                      ? 'View results as guest'
                      : 'Continue as guest'),
                ),
                if (message.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Text(message,
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.primary)),
                ],
                if (returnTo != null && message.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: () => context.go(returnTo),
                    icon: const Icon(Icons.arrow_forward),
                    label: Text(
                        returningToResults ? 'View My Results' : 'Continue'),
                  ),
                ],
              ],
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _emailAuth({required bool create}) async {
    final trimmedEmail = email.text.trim();
    final enteredPassword = password.text;
    if (trimmedEmail.isEmpty || enteredPassword.isEmpty) {
      setState(() => message = 'Enter an email and password first.');
      return;
    }
    if (enteredPassword.length < 6) {
      setState(() => message = 'Use at least 6 characters for your password.');
      return;
    }

    setState(() {
      loading = true;
      message = '';
    });

    try {
      final auth = Supabase.instance.client.auth;
      final currentUser = auth.currentUser;
      if (create) {
        if (currentUser?.isAnonymous ?? false) {
          await auth.updateUser(
            UserAttributes(email: trimmedEmail, password: enteredPassword),
            emailRedirectTo: Uri.base.origin,
          );
        } else {
          await auth.signUp(
            email: trimmedEmail,
            password: enteredPassword,
            emailRedirectTo: Uri.base.origin,
          );
        }
      } else {
        if (currentUser?.isAnonymous ?? false) {
          await auth.signOut();
        }
        await auth.signInWithPassword(
            email: trimmedEmail, password: enteredPassword);
      }
      await appState.refreshSavedData();
      await appState.refreshSubscription();
      final returnTo = _safeReturnTo;
      if (!create && returnTo != null) {
        if (mounted) context.go(returnTo);
        return;
      }
      if (create) {
        final confirmationPath = Uri(
          path: '/confirm-account',
          queryParameters: {
            if (returnTo != null) 'returnTo': returnTo,
          },
        ).toString();
        if (mounted) context.go(confirmationPath);
        return;
      }
      setState(() => message = create
          ? 'Check your email to confirm your account. You can view your results now on this device.'
          : 'Signed in.');
    } on AuthException catch (error) {
      setState(() => message = error.message);
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  Future<void> _sendPasswordReset() async {
    final trimmedEmail = email.text.trim();
    if (trimmedEmail.isEmpty) {
      setState(() => message = 'Enter your email, then tap Forgot password.');
      return;
    }

    setState(() {
      loading = true;
      message = '';
    });

    try {
      await Supabase.instance.client.auth.resetPasswordForEmail(
        trimmedEmail,
        redirectTo: _passwordResetRedirectUrl,
      );
      setState(() => message =
          'Check your email for a password reset link from GiftPath.');
    } on AuthException catch (error) {
      setState(() => message = error.message);
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  Future<void> _updateRecoveredPassword() async {
    final newPassword = resetPassword.text;
    if (newPassword.length < 6) {
      setState(() => message = 'Use at least 6 characters for your password.');
      return;
    }

    setState(() {
      loading = true;
      message = '';
    });

    try {
      await Supabase.instance.client.auth.updateUser(
        UserAttributes(password: newPassword),
      );
      await appState.refreshSavedData();
      resetPassword.clear();
      setState(() {
        resetPasswordMode = false;
        message = 'Password updated. You are signed in.';
      });
      if (widget.resetPasswordOnly && mounted) {
        context.go('/auth');
      }
    } on AuthException catch (error) {
      setState(() => message = error.message);
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  Future<void> _google() async {
    setState(() {
      loading = true;
      message = '';
    });
    try {
      final auth = Supabase.instance.client.auth;
      if (auth.currentUser?.isAnonymous ?? false) {
        await auth.linkIdentity(
          OAuthProvider.google,
          redirectTo: _authRedirectUrl,
        );
        return;
      } else {
        await auth.signInWithOAuth(
          OAuthProvider.google,
          redirectTo: _authRedirectUrl,
        );
      }
    } on AuthException catch (error) {
      setState(() => message = error.message);
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  Future<void> _continueAsGuest() async {
    setState(() {
      loading = true;
      message = '';
    });
    try {
      await Supabase.instance.client.auth.signInAnonymously();
      await appState.refreshSavedData();
      final returnTo = _safeReturnTo;
      if (returnTo != null) {
        if (mounted) context.go(returnTo);
        return;
      }
      setState(() => message =
          'Guest mode is on. Create an account later to save across devices.');
    } on AuthException catch (error) {
      setState(() => message = error.message);
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  Future<void> _manageBilling() async {
    setState(() {
      loading = true;
      message = '';
    });
    final result = await BillingService().createBillingPortalSession();
    if (!mounted) return;
    setState(() => loading = false);

    if (!result.isSuccess) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result.error ?? 'Billing management is unavailable.'),
          action: SnackBarAction(
            label: 'Subscribe',
            onPressed: () => context.go('/subscribe'),
          ),
        ),
      );
      return;
    }

    await launchUrl(Uri.parse(result.url!), webOnlyWindowName: '_self');
  }

  String get _authRedirectUrl {
    final returnTo = _safeReturnTo;
    if (returnTo == null) return '${Uri.base.origin}/auth';
    return Uri(
      path: '/auth',
      queryParameters: {'returnTo': returnTo},
    )
        .replace(
            scheme: Uri.base.scheme, host: Uri.base.host, port: Uri.base.port)
        .toString();
  }

  String get _passwordResetRedirectUrl {
    return Uri(
      path: '/',
      queryParameters: {'reset-password': '1'},
    )
        .replace(
            scheme: Uri.base.scheme, host: Uri.base.host, port: Uri.base.port)
        .toString();
  }
}

class _ResultsHandoffTrail extends StatelessWidget {
  const _ResultsHandoffTrail();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: BrandTokens.cream.withValues(alpha: .64),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: BrandTokens.gold.withValues(alpha: .24)),
      ),
      child: const Padding(
        padding: EdgeInsets.fromLTRB(16, 14, 16, 12),
        child: Column(
          children: [
            SizedBox(
              height: 24,
              width: double.infinity,
              child: CustomPaint(painter: _ResultsHandoffPainter()),
            ),
            SizedBox(height: 8),
            Row(
              children: [
                Expanded(child: _TrailLabel('Quiz complete', active: true)),
                Expanded(child: _TrailLabel('Save choice', active: true)),
                Expanded(child: _TrailLabel('Results')),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _TrailLabel extends StatelessWidget {
  const _TrailLabel(this.label, {this.active = false});

  final String label;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      textAlign: TextAlign.center,
      style: TextStyle(
        color: active ? BrandTokens.forest : BrandTokens.moss,
        fontSize: 12,
        fontWeight: FontWeight.w900,
      ),
    );
  }
}

class _ResultsHandoffPainter extends CustomPainter {
  const _ResultsHandoffPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final y = size.height / 2;
    final path = Path()
      ..moveTo(size.width * .08, y)
      ..cubicTo(size.width * .25, y - 18, size.width * .37, y + 18,
          size.width * .50, y)
      ..cubicTo(size.width * .63, y - 18, size.width * .75, y + 18,
          size.width * .92, y);
    final paint = Paint()
      ..color = BrandTokens.gold.withValues(alpha: .58)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    for (final metric in path.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        canvas.drawPath(
          metric.extractPath(distance, (distance + 11).clamp(0, metric.length)),
          paint,
        );
        distance += 20;
      }
    }
    for (final x in [size.width * .08, size.width * .50, size.width * .92]) {
      canvas.drawCircle(Offset(x, y), 8,
          Paint()..color = BrandTokens.gold.withValues(alpha: .20));
      canvas.drawCircle(Offset(x, y), 5, Paint()..color = BrandTokens.gold);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _AuthModeToggle extends StatelessWidget {
  const _AuthModeToggle({
    required this.createMode,
    required this.enabled,
    required this.onChanged,
  });

  final bool createMode;
  final bool enabled;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).colorScheme.outline),
        borderRadius: BorderRadius.circular(999),
      ),
      child: SizedBox(
        width: 260,
        height: 42,
        child: Row(
          children: [
            _AuthModeButton(
              label: 'Create',
              selected: createMode,
              enabled: enabled,
              onTap: () => onChanged(true),
            ),
            _AuthModeButton(
              label: 'Sign in',
              selected: !createMode,
              enabled: enabled,
              onTap: () => onChanged(false),
            ),
          ],
        ),
      ),
    );
  }
}

class _AuthModeButton extends StatelessWidget {
  const _AuthModeButton({
    required this.label,
    required this.selected,
    required this.enabled,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: enabled ? onTap : null,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? scheme.primary.withValues(alpha: .14) : null,
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: selected ? scheme.primary : scheme.onSurface,
              fontWeight: selected ? FontWeight.w800 : FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}

class _GuestPanel extends StatelessWidget {
  const _GuestPanel();

  @override
  Widget build(BuildContext context) {
    return const BrandNotice(
      icon: Icons.person_outline,
      accent: true,
      child: Text(
        'Guest mode lets you take the assessment now. Create an account when you want to keep saved results across devices.',
      ),
    );
  }
}

class _AccountPanel extends StatelessWidget {
  const _AccountPanel({
    required this.email,
    required this.loading,
    required this.hasActiveSubscription,
    required this.onManageBilling,
    required this.onSignOut,
    this.returnTo,
  });

  final String email;
  final bool loading;
  final bool hasActiveSubscription;
  final Future<void> Function() onManageBilling;
  final Future<void> Function() onSignOut;
  final String? returnTo;

  @override
  Widget build(BuildContext context) {
    return BrandNotice(
      icon: Icons.check_circle_outline,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Signed in as $email'),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              if (returnTo != null)
                FilledButton(
                  onPressed: () => context.go(returnTo!),
                  child: const Text('Continue'),
                ),
              OutlinedButton.icon(
                onPressed: loading ? null : onManageBilling,
                icon: Icon(hasActiveSubscription
                    ? Icons.manage_accounts_outlined
                    : Icons.credit_card_outlined),
                label: Text(hasActiveSubscription
                    ? 'Manage subscription'
                    : 'Billing portal'),
              ),
              OutlinedButton(
                  onPressed: loading ? null : onSignOut,
                  child: const Text('Sign out')),
            ],
          ),
        ],
      ),
    );
  }
}

class _ForgotPasswordPanel extends StatelessWidget {
  const _ForgotPasswordPanel({
    required this.controller,
    required this.loading,
    required this.message,
    required this.onBack,
    required this.onSubmit,
  });

  final TextEditingController controller;
  final bool loading;
  final String message;
  final VoidCallback onBack;
  final Future<void> Function() onSubmit;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return BrandNotice(
      icon: Icons.lock_reset,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Reset your password',
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 4),
          const Text(
              'Enter your email and GiftPath will send a secure reset link.'),
          const SizedBox(height: 14),
          TextField(
            controller: controller,
            enabled: !loading,
            keyboardType: TextInputType.emailAddress,
            autofillHints: const [AutofillHints.email],
            decoration: const InputDecoration(labelText: 'Email'),
            onSubmitted: (_) => loading ? null : onSubmit(),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              FilledButton.icon(
                onPressed: loading ? null : onSubmit,
                icon: const Icon(Icons.mail_outline, size: 18),
                label: Text(loading ? 'Sending...' : 'Send reset link'),
              ),
              TextButton.icon(
                onPressed: loading ? null : onBack,
                icon: const Icon(Icons.arrow_back, size: 18),
                label: const Text('Back to sign in'),
              ),
            ],
          ),
          if (message.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(message, style: TextStyle(color: scheme.primary)),
          ],
        ],
      ),
    );
  }
}

class _ResetPasswordPanel extends StatelessWidget {
  const _ResetPasswordPanel({
    required this.controller,
    required this.loading,
    required this.message,
    required this.onSubmit,
  });

  final TextEditingController controller;
  final bool loading;
  final String message;
  final Future<void> Function() onSubmit;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Enter a new password for your GiftPath account.',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        const SizedBox(height: 14),
        TextField(
          controller: controller,
          enabled: !loading,
          obscureText: true,
          autofillHints: const [AutofillHints.newPassword],
          decoration: const InputDecoration(labelText: 'New password'),
        ),
        const SizedBox(height: 14),
        FilledButton(
          onPressed: loading ? null : onSubmit,
          child: Text(loading ? 'Updating...' : 'Update password'),
        ),
        if (message.isNotEmpty) ...[
          const SizedBox(height: 12),
          Text(message, style: TextStyle(color: scheme.primary)),
        ],
      ],
    );
  }
}

class _SetupNotice extends StatelessWidget {
  const _SetupNotice();

  @override
  Widget build(BuildContext context) {
    return const BrandNotice(
      icon: Icons.settings_outlined,
      child: Text(
        'Supabase is not configured yet. Run Flutter with --dart-define=SUPABASE_URL=... and --dart-define=SUPABASE_ANON_KEY=... after creating your Supabase project.',
      ),
    );
  }
}
