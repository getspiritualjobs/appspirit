import 'dart:async';

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/env.dart';
import '../../widgets/responsive.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final email = TextEditingController();
  final password = TextEditingController();
  StreamSubscription<AuthState>? authSubscription;
  bool createMode = true;
  bool loading = false;
  String message = '';

  @override
  void initState() {
    super.initState();
    if (Env.hasSupabase) {
      authSubscription =
          Supabase.instance.client.auth.onAuthStateChange.listen((_) {
        if (mounted) setState(() {});
      });
    }
  }

  @override
  void dispose() {
    authSubscription?.cancel();
    email.dispose();
    password.dispose();
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
                SegmentedButton<bool>(
                  segments: const [
                    ButtonSegment(
                        value: true,
                        label: Text('Create Account'),
                        icon: Icon(Icons.person_add_alt_1)),
                    ButtonSegment(
                        value: false,
                        label: Text('Sign In'),
                        icon: Icon(Icons.login)),
                  ],
                  selected: {createMode},
                  onSelectionChanged: loading
                      ? null
                      : (value) => setState(() => createMode = value.first),
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
                OutlinedButton.icon(
                  onPressed: loading ? null : _google,
                  icon: const Icon(Icons.login),
                  label: const Text('Continue with Google'),
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
            Icon(Icons.person_outline),
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
            const Icon(Icons.check_circle_outline),
            const SizedBox(width: 12),
            Expanded(child: Text('Signed in as $email')),
            OutlinedButton(onPressed: onSignOut, child: const Text('Sign Out')),
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
