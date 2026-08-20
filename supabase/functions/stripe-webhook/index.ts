import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const stripeVersion = "2026-02-25.preview";

Deno.serve(async (req) => {
  if (req.method !== "POST") {
    return new Response("Method not allowed", { status: 405 });
  }

  try {
    const webhookSecret = mustGetEnv("STRIPE_WEBHOOK_SECRET");
    const payload = await req.text();
    const signature = req.headers.get("stripe-signature") ?? "";
    await verifyStripeSignature(payload, signature, webhookSecret);

    const event = JSON.parse(payload);
    if (event.type === "checkout.session.completed") {
      await handleCheckoutCompleted(event.data.object);
    } else if (
      event.type === "customer.subscription.created" ||
      event.type === "customer.subscription.updated"
    ) {
      await handleSubscriptionUpsert(event.data.object);
    } else if (event.type === "customer.subscription.deleted") {
      await handleSubscriptionDeleted(event.data.object);
    } else if (event.type === "invoice.payment_failed") {
      await handleInvoicePaymentFailed(event.data.object);
    }

    return Response.json({ received: true });
  } catch (error) {
    return Response.json(
      { error: error instanceof Error ? error.message : "Unknown error" },
      { status: 400 },
    );
  }
});

async function handleCheckoutCompleted(session: Record<string, unknown>) {
  const userId =
    asString(session.client_reference_id) ??
    asString((session.metadata as Record<string, unknown> | undefined)?.user_id);
  const customerId = asString(session.customer);
  const subscriptionId = asString(session.subscription);
  if (!userId || !customerId || !subscriptionId) {
    throw new Error("Checkout session is missing billing identifiers.");
  }

  const subscription = await stripeGet(
    mustGetEnv("STRIPE_SECRET_KEY"),
    `/v1/subscriptions/${subscriptionId}`,
  );

  await upsertCustomer(userId, customerId);
  await upsertSubscription({ userId, customerId, subscriptionId, subscription });
}

async function handleSubscriptionUpsert(subscription: Record<string, unknown>) {
  const subscriptionId = asString(subscription.id);
  const customerId = asString(subscription.customer);
  const userId =
    asString(
      (subscription.metadata as Record<string, unknown> | undefined)?.user_id,
    ) ?? (customerId ? await findUserIdForCustomer(customerId) : null);

  if (!userId || !customerId || !subscriptionId) {
    throw new Error("Subscription event is missing billing identifiers.");
  }

  await upsertCustomer(userId, customerId);
  await upsertSubscription({ userId, customerId, subscriptionId, subscription });
}

async function handleSubscriptionDeleted(subscription: Record<string, unknown>) {
  const subscriptionId = asString(subscription.id);
  if (!subscriptionId) throw new Error("Deleted subscription is missing an id.");

  const { error } = await serviceClient()
    .from("billing_subscriptions")
    .update({
      status: String(subscription.status ?? "canceled"),
      current_period_end: currentPeriodEnd(subscription),
      updated_at: new Date().toISOString(),
    })
    .eq("stripe_subscription_id", subscriptionId);
  if (error) throw error;
}

async function handleInvoicePaymentFailed(invoice: Record<string, unknown>) {
  const parent = invoice.parent as Record<string, unknown> | undefined;
  const details = parent?.subscription_details as
    | Record<string, unknown>
    | undefined;
  const subscriptionId =
    asString(invoice.subscription) ?? asString(details?.subscription);
  if (!subscriptionId) return;

  const { error } = await serviceClient()
    .from("billing_subscriptions")
    .update({
      status: "past_due",
      updated_at: new Date().toISOString(),
    })
    .eq("stripe_subscription_id", subscriptionId);
  if (error) throw error;
}

async function upsertCustomer(userId: string, customerId: string) {
  const { error } = await serviceClient().from("billing_customers").upsert({
    user_id: userId,
    stripe_customer_id: customerId,
    updated_at: new Date().toISOString(),
  });
  if (error) throw error;
}

async function upsertSubscription({
  userId,
  customerId,
  subscriptionId,
  subscription,
}: {
  userId: string;
  customerId: string;
  subscriptionId: string;
  subscription: Record<string, any>;
}) {
  const item = subscription.items?.data?.[0];
  const { error } = await serviceClient()
    .from("billing_subscriptions")
    .upsert(
      {
        user_id: userId,
        stripe_customer_id: customerId,
        stripe_subscription_id: subscriptionId,
        stripe_price_id: item?.price?.id ?? null,
        status: String(subscription.status ?? "unknown"),
        current_period_end: currentPeriodEnd(subscription),
        updated_at: new Date().toISOString(),
      },
      { onConflict: "stripe_subscription_id" },
    );
  if (error) throw error;
}

async function findUserIdForCustomer(customerId: string) {
  const { data, error } = await serviceClient()
    .from("billing_customers")
    .select("user_id")
    .eq("stripe_customer_id", customerId)
    .maybeSingle();
  if (error) throw error;
  return asString(data?.user_id);
}

async function stripeGet(secretKey: string, path: string) {
  const response = await fetch(`https://api.stripe.com${path}`, {
    headers: {
      authorization: `Bearer ${secretKey}`,
      "stripe-version": stripeVersion,
    },
  });
  const data = await response.json();
  if (!response.ok) {
    throw new Error(data?.error?.message ?? "Stripe request failed.");
  }
  return data;
}

async function verifyStripeSignature(
  payload: string,
  signatureHeader: string,
  secret: string,
) {
  const timestamp = signatureHeader
    .split(",")
    .find((part) => part.startsWith("t="))
    ?.slice(2);
  const signatures = signatureHeader
    .split(",")
    .filter((part) => part.startsWith("v1="))
    .map((part) => part.slice(3));
  if (!timestamp || signatures.length === 0) {
    throw new Error("Missing Stripe signature.");
  }

  const signedPayload = `${timestamp}.${payload}`;
  const key = await crypto.subtle.importKey(
    "raw",
    new TextEncoder().encode(secret),
    { name: "HMAC", hash: "SHA-256" },
    false,
    ["sign"],
  );
  const digest = await crypto.subtle.sign(
    "HMAC",
    key,
    new TextEncoder().encode(signedPayload),
  );
  const expected = [...new Uint8Array(digest)]
    .map((byte) => byte.toString(16).padStart(2, "0"))
    .join("");
  if (!signatures.some((signature) => timingSafeEqual(signature, expected))) {
    throw new Error("Invalid Stripe signature.");
  }
}

function currentPeriodEnd(subscription: Record<string, any>) {
  return subscription.current_period_end
    ? new Date(Number(subscription.current_period_end) * 1000).toISOString()
    : null;
}

function serviceClient() {
  return createClient(
    mustGetEnv("SUPABASE_URL"),
    mustGetEnv("SUPABASE_SERVICE_ROLE_KEY"),
    { auth: { persistSession: false } },
  );
}

function timingSafeEqual(a: string, b: string) {
  if (a.length !== b.length) return false;
  let result = 0;
  for (let index = 0; index < a.length; index += 1) {
    result |= a.charCodeAt(index) ^ b.charCodeAt(index);
  }
  return result === 0;
}

function asString(value: unknown) {
  return typeof value === "string" && value.length > 0 ? value : null;
}

function mustGetEnv(name: string) {
  const value = Deno.env.get(name);
  if (!value) throw new Error(`Missing ${name}.`);
  return value;
}
