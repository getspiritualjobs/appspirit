import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const stripeVersion = "2026-02-25.preview";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type",
};

type CheckoutBody = {
  successUrl?: string;
  cancelUrl?: string;
};

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }
  if (req.method !== "POST") {
    return json({ error: "Method not allowed" }, 405);
  }

  try {
    const stripeSecretKey = mustGetEnv("STRIPE_SECRET_KEY");
    const priceId = mustGetEnv("STRIPE_PRICE_ID");
    const supabaseUrl = mustGetEnv("SUPABASE_URL");
    const serviceRoleKey = mustGetEnv("SUPABASE_SERVICE_ROLE_KEY");
    const origin = req.headers.get("origin") ?? "https://giftpath.app";
    const body = (await req.json().catch(() => ({}))) as CheckoutBody;

    const authHeader = req.headers.get("authorization");
    if (!authHeader) return json({ error: "Sign in before checkout." }, 401);

    const supabase = createClient(supabaseUrl, serviceRoleKey, {
      auth: { persistSession: false },
    });
    const token = authHeader.replace(/^Bearer\s+/i, "");
    const { data: userData, error: userError } =
      await supabase.auth.getUser(token);
    if (userError || !userData.user) {
      return json({ error: "Invalid auth session." }, 401);
    }

    const user = userData.user;
    if (user.is_anonymous) {
      return json({ error: "Create an account before subscribing." }, 403);
    }

    const customerId = await getOrCreateCustomer({
      supabase,
      stripeSecretKey,
      userId: user.id,
      email: user.email ?? undefined,
    });

    const successUrl =
      body.successUrl ?? `${origin.replace(/\/$/, "")}/billing/success`;
    const cancelUrl =
      body.cancelUrl ?? `${origin.replace(/\/$/, "")}/opportunities`;

    const checkout = await stripeRequest(stripeSecretKey, "/v1/checkout/sessions", {
      mode: "subscription",
      customer: customerId,
      "line_items[0][price]": priceId,
      "line_items[0][quantity]": "1",
      success_url: successUrl,
      cancel_url: cancelUrl,
      client_reference_id: user.id,
      "metadata[user_id]": user.id,
      "subscription_data[metadata][user_id]": user.id,
      "managed_payments[enabled]": "true",
    });

    return json({ url: checkout.url });
  } catch (error) {
    return json(
      { error: error instanceof Error ? error.message : "Unknown error" },
      500,
    );
  }
});

async function getOrCreateCustomer({
  supabase,
  stripeSecretKey,
  userId,
  email,
}: {
  supabase: ReturnType<typeof createClient>;
  stripeSecretKey: string;
  userId: string;
  email?: string;
}) {
  const { data: existing, error } = await supabase
    .from("billing_customers")
    .select("stripe_customer_id")
    .eq("user_id", userId)
    .maybeSingle();
  if (error) throw error;
  if (existing?.stripe_customer_id) return existing.stripe_customer_id;

  const customer = await stripeRequest(stripeSecretKey, "/v1/customers", {
    ...(email ? { email } : {}),
    "metadata[user_id]": userId,
  });

  const { error: upsertError } = await supabase
    .from("billing_customers")
    .upsert({
      user_id: userId,
      stripe_customer_id: customer.id,
      email: email ?? null,
      updated_at: new Date().toISOString(),
    });
  if (upsertError) throw upsertError;

  return String(customer.id);
}

async function stripeRequest(
  secretKey: string,
  path: string,
  params: Record<string, string>,
) {
  const response = await fetch(`https://api.stripe.com${path}`, {
    method: "POST",
    headers: {
      authorization: `Bearer ${secretKey}`,
      "content-type": "application/x-www-form-urlencoded",
      "stripe-version": stripeVersion,
    },
    body: new URLSearchParams(params),
  });
  const data = await response.json();
  if (!response.ok) {
    throw new Error(data?.error?.message ?? "Stripe request failed.");
  }
  return data;
}

function mustGetEnv(name: string) {
  const value = Deno.env.get(name);
  if (!value) throw new Error(`Missing ${name}.`);
  return value;
}

function json(body: unknown, status = 200) {
  return Response.json(body, { status, headers: corsHeaders });
}
