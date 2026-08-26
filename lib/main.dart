import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app.dart';
import 'core/app_state.dart';
import 'core/env.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  usePathUrlStrategy();

  if (Env.supabaseUrl.isNotEmpty && Env.supabaseAnonKey.isNotEmpty) {
    await Supabase.initialize(
      url: Env.supabaseUrl,
      publishableKey: Env.supabaseAnonKey,
    );
    Supabase.instance.client.auth.onAuthStateChange.listen((_) {
      appState.refreshSavedData();
      appState.refreshSubscription();
    });
  }

  String? initialLocation;
  if (Uri.base.queryParameters['reset-password'] == '1' ||
      Uri.base.queryParameters['mode'] == 'reset-password') {
    initialLocation = '/reset-password';
  }
  if (kDebugMode && Uri.base.queryParameters['demo'] == 'results') {
    appState.loadDemoAssessment();
    if (Uri.base.queryParameters['go'] == 'opportunities') {
      initialLocation = '/opportunities';
    } else if (Uri.base.queryParameters['go'] == 'results') {
      initialLocation = '/results';
    } else if (Uri.base.queryParameters['go'] == 'signup') {
      initialLocation = '/auth?returnTo=/results';
    }
  }

  runApp(GiftPathApp(initialLocation: initialLocation));
}
