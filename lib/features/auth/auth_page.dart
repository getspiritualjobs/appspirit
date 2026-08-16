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
  String message = '';

  @override
  void dispose() {
    email.dispose();
    password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final session = Env.hasSupabase ? Supabase.instance.client.auth.currentSession : null;

    return SingleChildScrollView(
      child: PageBand(
        maxWidth: 620,
        child: InfoCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Save your results and opportunities', style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 8),
              const Text('Account creation is optional and only needed when you want saved results, careers, jobs, and search preferences to persist across devices.'),
              const SizedBox(height: 18),
              if (!Env.hasSupabase)
                const _SetupNotice()
              else if (session != null)
                _SignedInPanel(
                  email: session.user.email ?? 'Signed-in user',
                  onSignOut: () async {
                    await Supabase.instance.client.auth.signOut();
                    if (mounted) setState(() => message = 'Signed out.');
                  },
                )
              else ...[
                TextField(controller: email, decoration: const InputDecoration(labelText: 'Email')),
                const SizedBox(height: 12),
                TextField(controller: password, obscureText: true, decoration: const InputDecoration(labelText: 'Password')),
                const SizedBox(height: 14),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    FilledButton(onPressed: () => _signIn(false), child: const Text('Sign In')),
                    OutlinedButton(onPressed: () => _signIn(true), child: const Text('Create Account')),
                    OutlinedButton.icon(
                      onPressed: _google,
                      icon: const Icon(Icons.login),
                      label: const Text('Continue with Google'),
                    ),
                  ],
                ),
                if (message.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Text(message),
                ],
              ],
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _signIn(bool create) async {
    try {
      final auth = Supabase.instance.client.auth;
      if (create) {
        await auth.signUp(email: email.text.trim(), password: password.text);
      } else {
        await auth.signInWithPassword(email: email.text.trim(), password: password.text);
      }
      setState(() => message = create ? 'Check your email to confirm your account.' : 'Signed in.');
    } on AuthException catch (error) {
      setState(() => message = error.message);
    }
  }

  Future<void> _google() async {
    await Supabase.instance.client.auth.signInWithOAuth(
      OAuthProvider.google,
      redirectTo: Uri.base.origin,
    );
  }
}

class _SignedInPanel extends StatelessWidget {
  const _SignedInPanel({required this.email, required this.onSignOut});

  final String email;
  final Future<void> Function() onSignOut;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(color: Color(0xFFE7F0EA), borderRadius: BorderRadius.all(Radius.circular(8))),
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
      decoration: BoxDecoration(color: Color(0xFFE7F0EA), borderRadius: BorderRadius.all(Radius.circular(8))),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Text('Supabase is not configured yet. Run Flutter with --dart-define=SUPABASE_URL=... and --dart-define=SUPABASE_ANON_KEY=... after creating your Supabase project.'),
      ),
    );
  }
}
