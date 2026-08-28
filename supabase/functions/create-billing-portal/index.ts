import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const stripeVersion = "2026-02-25.preview";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type",
};

type PortalBody = {
  returnUrl?: string;
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
    const supabaseUrl = mustGetEnv("SUPABASE_URL");
    const serviceRoleKey = mustGetEnv("SUPABASE_SERVICE_ROLE_KEY");
    const origin = req.headers.get("origin") ?? "https://giftpath.app";
    const body = (await req.json().catch(() => ({}))) as PortalBody;

    const authHeader = req.headers.get("authorization");
    if (!authHeader) return json({ error: "Sign in to manage billing." }, 401);

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
      return json({ error: "Create an account before managing billing." }, 403);
    }

    const { data: customer, error: customerError } = await supabase
      .from("billing_customers")
      .select("stripe_customer_id")
      .eq("user_id", user.id)
      .maybeSingle();
    if (customerError) throw customerError;
    if (!customer?.stripe_customer_id) {
      return json({ error: "No Stripe customer found for this account." }, 404);
    }

    const returnUrl = body.returnUrl ?? `${origin.replace(/\/$/, "")}/auth`;
    const portal = await stripeRequest(
      stripeSecretKey,
      "/v1/billing_portal/sessions",
      {
        customer: customer.stripe_customer_id,
        return_url: returnUrl,
      },
    );

    return json({ url: portal.url });
  } catch (error) {
    return json(
      { error: error instanceof Error ? error.message : "Unknown error" },
      500,
    );
  }
});

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
