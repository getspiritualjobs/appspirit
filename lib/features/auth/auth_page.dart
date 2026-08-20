import 'dart:async';

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/env.dart';
import '../../widgets/brand_mark.dart';
import '../../widgets/responsive.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

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
  bool resetPasswordMode = false;
  String message = '';

  @override
  void initState() {
    super.initState();
    if (Env.hasSupabase) {
      authSubscription =
          Supabase.instance.client.auth.onAuthStateChange.listen((state) {
        if (!mounted) return;
        setState(() {
          if (state.event == AuthChangeEvent.passwordRecovery) {
            resetPasswordMode = true;
            createMode = false;
            message = 'Choose a new password to finish resetting your account.';
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

    return SingleChildScrollView(
      child: PageBand(
        maxWidth: 620,
        child: InfoCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Save your results and opportunities',
                  style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 8),
              const Text(
                  'Account creation is optional and only needed when you want saved results, careers, jobs, and search preferences to persist across devices.'),
              const SizedBox(height: 18),
              if (!Env.hasSupabase)
                const _SetupNotice()
              else if (isRealAccount)
                if (resetPasswordMode)
                  _ResetPasswordPanel(
                    controller: resetPassword,
                    loading: loading,
                    message: message,
                    onSubmit: _updateRecoveredPassword,
                  )
                else
                  _AccountPanel(
                    email: user.email ?? 'Signed-in user',
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
                    child: InkWell(
                      borderRadius: BorderRadius.circular(6),
                      onTap: loading ? null : _sendPasswordReset,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 2, vertical: 6),
                        child: Text(
                          'Forgot password?',
                          style:
                              Theme.of(context).textTheme.labelLarge?.copyWith(
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                    fontWeight: FontWeight.w800,
                                    decoration: TextDecoration.underline,
                                  ),
                        ),
                      ),
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
                          ? 'Create Account'
                          : 'Sign In'),
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
                  child: const Text('Continue as guest'),
                ),
                if (message.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Text(message,
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.primary)),
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
      setState(() => message =
          create ? 'Check your email to confirm your account.' : 'Signed in.');
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
        redirectTo: '${Uri.base.origin}/auth',
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
      resetPassword.clear();
      setState(() {
        resetPasswordMode = false;
        message = 'Password updated. You are signed in.';
      });
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
        await auth.signOut();
      }
      await auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: Uri.base.origin,
      );
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
      setState(() => message =
          'Guest mode is on. Create an account later to save across devices.');
    } on AuthException catch (error) {
      setState(() => message = error.message);
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }
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
              label: 'Sign In',
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
    return const DecoratedBox(
      decoration: BoxDecoration(
          color: Color(0xFFFFF7E8),
          borderRadius: BorderRadius.all(Radius.circular(8))),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            IconBadge(Icons.person_outline, size: 38),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                  'You are using GiftPath as a guest. You can take the assessment now, but create an account to keep saved results across devices.'),
            ),
          ],
        ),
      ),
    );
  }
}

class _AccountPanel extends StatelessWidget {
  const _AccountPanel({required this.email, required this.onSignOut});

  final String email;
  final Future<void> Function() onSignOut;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
          color: Color(0xFFE7F0EA),
          borderRadius: BorderRadius.all(Radius.circular(8))),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const IconBadge(Icons.check_circle_outline, size: 38),
            const SizedBox(width: 12),
            Expanded(child: Text('Signed in as $email')),
            OutlinedButton(onPressed: onSignOut, child: const Text('Sign Out')),
          ],
        ),
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
    return DecoratedBox(
      decoration: const BoxDecoration(
          color: Color(0xFFE7F0EA),
          borderRadius: BorderRadius.all(Radius.circular(8))),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const IconBadge(Icons.lock_reset, size: 38),
                const SizedBox(width: 12),
                Expanded(
                  child: Text('Set a new password',
                      style: Theme.of(context).textTheme.titleMedium),
                ),
              ],
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
            FilledButton.icon(
              onPressed: loading ? null : onSubmit,
              icon: const Icon(Icons.check_circle_outline, size: 18),
              label: Text(loading ? 'Updating...' : 'Update Password'),
            ),
            if (message.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(message, style: TextStyle(color: scheme.primary)),
            ],
          ],
        ),
      ),
    );
  }
}

class _SetupNotice extends StatelessWidget {
  const _SetupNotice();

  @override
  Widget build(BuildContext context) {
    return const DecoratedBox(
      decoration: BoxDecoration(
          color: Color(0xFFE7F0EA),
          borderRadius: BorderRadius.all(Radius.circular(8))),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Text(
            'Supabase is not configured yet. Run Flutter with --dart-define=SUPABASE_URL=... and --dart-define=SUPABASE_ANON_KEY=... after creating your Supabase project.'),
      ),
    );
  }
}
