import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/env.dart';
import 'analytics_repository.dart';

class BillingCheckoutResult {
  const BillingCheckoutResult.success(this.url) : error = null;
  const BillingCheckoutResult.failure(this.error) : url = null;

  final String? url;
  final String? error;

  bool get isSuccess => url != null;
}

enum BillingPlan {
  monthly('monthly'),
  yearly('yearly');

  const BillingPlan(this.apiValue);

  final String apiValue;
}

class BillingService {
  Future<BillingCheckoutResult> createCheckoutSession({
    BillingPlan plan = BillingPlan.monthly,
  }) async {
    if (!Env.hasSupabase) {
      return const BillingCheckoutResult.failure(
        'Supabase must be configured before checkout can start.',
      );
    }

    final auth = Supabase.instance.client.auth;
    final user = auth.currentUser;
    if (user == null || user.isAnonymous) {
      return const BillingCheckoutResult.failure(
        'Create an account or sign in before subscribing.',
      );
    }

    try {
      await AnalyticsRepository().logEvent(
        'checkout_started',
        properties: {'plan': plan.apiValue},
      );
      final origin = Uri.base.origin;
      final response = await Supabase.instance.client.functions.invoke(
        'create-checkout-session',
        body: {
          'billingInterval': plan.apiValue,
          'successUrl': '$origin/billing/success',
          'cancelUrl': '$origin/subscribe',
        },
      );
      final data = response.data;
      if (data is Map && data['url'] is String) {
        return BillingCheckoutResult.success(data['url'] as String);
      }
      return const BillingCheckoutResult.failure(
        'Stripe did not return a checkout URL.',
      );
    } catch (error) {
      return BillingCheckoutResult.failure(error.toString());
    }
  }

  Future<BillingCheckoutResult> createBillingPortalSession() async {
    if (!Env.hasSupabase) {
      return const BillingCheckoutResult.failure(
        'Supabase must be configured before billing can be managed.',
      );
    }

    final auth = Supabase.instance.client.auth;
    final user = auth.currentUser;
    if (user == null || user.isAnonymous) {
      return const BillingCheckoutResult.failure(
        'Sign in before managing billing.',
      );
    }

    try {
      final origin = Uri.base.origin;
      final response = await Supabase.instance.client.functions.invoke(
        'create-billing-portal',
        body: {
          'returnUrl': '$origin/auth',
        },
      );
      final data = response.data;
      if (data is Map && data['url'] is String) {
        return BillingCheckoutResult.success(data['url'] as String);
      }
      return const BillingCheckoutResult.failure(
        'Stripe did not return a billing portal URL.',
      );
    } catch (error) {
      return BillingCheckoutResult.failure(error.toString());
    }
  }

  Future<bool> hasActiveSubscription() async {
    if (!Env.hasSupabase) return false;
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null || user.isAnonymous) return false;

    try {
      final rows = await Supabase.instance.client
          .from('billing_subscriptions')
          .select('status,current_period_end')
          .eq('user_id', user.id)
          .inFilter('status', ['active', 'trialing']).limit(1);
      return rows.isNotEmpty;
    } catch (_) {
      return false;
    }
  }
}
