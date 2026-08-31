import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

type SearchRequest = {
  titles?: string[];
  location?: string;
  remote?: boolean;
  salaryMin?: number;
  employmentType?: string;
};

type NormalizedJob = {
  id: string;
  provider: string;
  matchedQuery?: string;
  title: string;
  company: string;
  location: string;
  description: string;
  salaryMin: number | null;
  salaryMax: number | null;
  employmentType: string;
  remote: boolean;
  postedDate: string | null;
  applicationUrl: string;
};

type UsageLog = {
  provider: string;
  query?: string;
  location?: string;
  remote?: boolean;
  salary_min?: number;
  employment_type?: string;
  cache_hit?: boolean;
  http_status?: number;
  result_count?: number;
  deduped_count?: number;
  duration_ms?: number;
  error?: string;
};

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
};
const maxJobAgeDays = 45;
const freeJobAllowance = 1;

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") return new Response("ok", { headers: corsHeaders });

  try {
    const body = (await req.json()) as SearchRequest;
    const titles = body.titles?.length ? body.titles : ["Learning and Development Specialist"];
    const [adzuna, usajobs] = await Promise.all([
      searchAdzuna(titles, body),
      searchUsaJobs(titles, body),
    ]);
    const rawJobs = filterCurrentJobs([...adzuna, ...usajobs]);
    const matched = dedupeJobs(rawJobs).slice(0, 50);
    // The opportunity list is the paid product, so the free allowance is
    // enforced here rather than trimmed in the client: an unentitled caller
    // never receives the locked listings in the first place.
    const entitled = await hasActiveSubscription(req);
    const jobs = entitled ? matched : matched.slice(0, freeJobAllowance);
    const providers = [...new Set(jobs.map((job) => job.provider))];
    await logJobApiUsage({
      provider: "combined",
      query: titles.slice(0, 5).join(", "),
      location: body.location || "United States",
      remote: body.remote === true,
      salary_min: body.salaryMin,
      employment_type: body.employmentType,
      result_count: rawJobs.length,
      deduped_count: matched.length,
    });

    return Response.json(
      {
        jobs,
        providers,
        entitled,
        matchedCount: matched.length,
        demo: jobs.length === 0,
        usage: { rawCount: rawJobs.length, dedupedCount: matched.length },
      },
      { headers: corsHeaders },
    );
  } catch (error) {
    return Response.json({ error: error instanceof Error ? error.message : "Unknown error" }, { status: 500, headers: corsHeaders });
  }
});

async function searchAdzuna(titles: string[], req: SearchRequest): Promise<NormalizedJob[]> {
  const appId = Deno.env.get("ADZUNA_APP_ID");
  const appKey = Deno.env.get("ADZUNA_APP_KEY");
  if (!appId || !appKey) return [];

  const queries = [...new Set(titles.slice(0, 5).map(normalizeCareerQuery).filter(Boolean))];
  const results = await Promise.all(queries.map((query) => searchAdzunaQuery(query, req, appId, appKey)));
  return results.flat();
}

async function searchAdzunaQuery(
  query: string,
  req: SearchRequest,
  appId: string,
  appKey: string,
): Promise<NormalizedJob[]> {
  const startedAt = Date.now();
  const cacheKey = cacheKeyFor("adzuna", query, req);
  const cached = await readJobCache(cacheKey);
  if (cached) {
    await logJobApiUsage({
      provider: "adzuna",
      query,
      location: req.location || "United States",
      remote: req.remote === true,
      salary_min: req.salaryMin,
      employment_type: req.employmentType,
      cache_hit: true,
      result_count: cached.length,
      duration_ms: Date.now() - startedAt,
    });
    return cached;
  }

  const params = new URLSearchParams({
    app_id: appId,
    app_key: appKey,
    results_per_page: "12",
    what: query,
    where: req.location || "United States",
    "content-type": "application/json",
  });
  if (req.salaryMin) params.set("salary_min", String(req.salaryMin));
  if (req.employmentType === "full_time") params.set("full_time", "1");
  if (req.remote) params.set("what_or", "remote");

  const url = `https://api.adzuna.com/v1/api/jobs/us/search/1?${params}`;
  const response = await fetch(url);
  if (!response.ok) {
    await logJobApiUsage({
      provider: "adzuna",
      query,
      location: req.location || "United States",
      remote: req.remote === true,
      salary_min: req.salaryMin,
      employment_type: req.employmentType,
      http_status: response.status,
      result_count: 0,
      duration_ms: Date.now() - startedAt,
      error: await safeResponseText(response),
    });
    return [];
  }

  const data = await response.json();
  const results = Array.isArray(data.results) ? data.results : [];
  const jobs = filterCurrentJobs(results.map((job: Record<string, any>): NormalizedJob => ({
    id: String(job.id),
    provider: "adzuna",
    matchedQuery: query,
    title: String(job.title ?? ""),
    company: String(job.company?.display_name ?? ""),
    location: String(job.location?.display_name ?? ""),
    description: cleanDescription(job.description),
    salaryMin: typeof job.salary_min === "number" ? Math.round(job.salary_min) : null,
    salaryMax: typeof job.salary_max === "number" ? Math.round(job.salary_max) : null,
    employmentType: String(job.contract_time ?? "Not specified"),
    remote: /remote/i.test(`${job.title} ${job.description} ${job.location?.display_name}`),
    postedDate: typeof job.created === "string" ? job.created : null,
    applicationUrl: String(job.redirect_url ?? ""),
  })));
  await writeJobCache(cacheKey, "adzuna", jobs);
  await logJobApiUsage({
    provider: "adzuna",
    query,
    location: req.location || "United States",
    remote: req.remote === true,
    salary_min: req.salaryMin,
    employment_type: req.employmentType,
    cache_hit: false,
    http_status: response.status,
    result_count: jobs.length,
    duration_ms: Date.now() - startedAt,
  });
  return jobs;
}

function normalizeCareerQuery(title: string) {
  return title
    .replace(/\b(Specialist|Manager|Coordinator|Director|Consultant)\b/gi, "")
    .replace(/\s+/g, " ")
    .trim() || title.trim();
}

async function searchUsaJobs(titles: string[], req: SearchRequest): Promise<NormalizedJob[]> {
  const apiKey = Deno.env.get("USAJOBS_API_KEY");
  const userAgent = Deno.env.get("USAJOBS_USER_AGENT");
  if (!apiKey || !userAgent) return [];

  const startedAt = Date.now();
  const cacheKey = cacheKeyFor("usajobs", titles[0] ?? "", req);
  const cached = await readJobCache(cacheKey);
  if (cached) {
    await logJobApiUsage({
      provider: "usajobs",
      query: titles[0],
      location: req.location || "",
      remote: req.remote === true,
      salary_min: req.salaryMin,
      employment_type: req.employmentType,
      cache_hit: true,
      result_count: cached.length,
      duration_ms: Date.now() - startedAt,
    });
    return cached;
  }

  const keyword = encodeURIComponent(titles[0]);
  const location = encodeURIComponent(req.location || "");
  const url = `https://data.usajobs.gov/api/search?Keyword=${keyword}&LocationName=${location}&ResultsPerPage=20`;
  const response = await fetch(url, {
    headers: {
      "Authorization-Key": apiKey,
      "User-Agent": userAgent,
    },
  });
  if (!response.ok) {
    await logJobApiUsage({
      provider: "usajobs",
      query: titles[0],
      location: req.location || "",
      remote: req.remote === true,
      salary_min: req.salaryMin,
      employment_type: req.employmentType,
      http_status: response.status,
      result_count: 0,
      duration_ms: Date.now() - startedAt,
      error: await safeResponseText(response),
    });
    return [];
  }
  const data = await response.json();
  const items = Array.isArray(data.SearchResult?.SearchResultItems) ? data.SearchResult.SearchResultItems : [];

  const jobs = filterCurrentJobs(items.map((item: Record<string, any>): NormalizedJob => {
    const descriptor = item.MatchedObjectDescriptor ?? {};
    const remuneration = descriptor.PositionRemuneration?.[0] ?? {};
    return {
      id: String(descriptor.PositionID ?? item.MatchedObjectId),
      provider: "usajobs",
      matchedQuery: titles[0],
      title: String(descriptor.PositionTitle ?? ""),
      company: String(descriptor.OrganizationName ?? ""),
      location: String(descriptor.PositionLocationDisplay ?? ""),
      description: cleanDescription(descriptor.UserArea?.Details?.JobSummary),
      salaryMin: Number.isFinite(Number(remuneration.MinimumRange)) ? Math.round(Number(remuneration.MinimumRange)) : null,
      salaryMax: Number.isFinite(Number(remuneration.MaximumRange)) ? Math.round(Number(remuneration.MaximumRange)) : null,
      employmentType: String(descriptor.PositionSchedule?.[0]?.Name ?? "Not specified"),
      remote: /remote/i.test(`${descriptor.PositionTitle} ${descriptor.PositionLocationDisplay} ${descriptor.UserArea?.Details?.JobSummary}`),
      postedDate: typeof descriptor.PublicationStartDate === "string" ? descriptor.PublicationStartDate : null,
      applicationUrl: String(descriptor.PositionURI ?? ""),
    };
  }));
  await writeJobCache(cacheKey, "usajobs", jobs);
  await logJobApiUsage({
    provider: "usajobs",
    query: titles[0],
    location: req.location || "",
    remote: req.remote === true,
    salary_min: req.salaryMin,
    employment_type: req.employmentType,
    cache_hit: false,
    http_status: response.status,
    result_count: jobs.length,
    duration_ms: Date.now() - startedAt,
  });
  return jobs;
}

function dedupeJobs(jobs: NormalizedJob[]) {
  const seen = new Map<string, NormalizedJob>();
  const unique: NormalizedJob[] = [];
  for (const job of jobs) {
    const key = jobFingerprint(job);
    const existing = seen.get(key);
    if (existing) {
      if (fingerprintText(existing.location) !== fingerprintText(job.location)) {
        existing.location = "Multiple locations";
      }
      existing.remote = existing.remote || job.remote;
      if (!existing.salaryMin && job.salaryMin) existing.salaryMin = job.salaryMin;
      if (!existing.salaryMax && job.salaryMax) existing.salaryMax = job.salaryMax;
      if (!existing.applicationUrl && job.applicationUrl) existing.applicationUrl = job.applicationUrl;
      continue;
    }
    seen.set(key, job);
    unique.push(job);
  }
  return unique;
}

function filterCurrentJobs(jobs: NormalizedJob[]) {
  return jobs.filter((job) => isCurrentJob(job.postedDate));
}

function isCurrentJob(postedDate: string | null) {
  if (!postedDate) return true;
  const parsed = Date.parse(postedDate);
  if (!Number.isFinite(parsed)) return true;
  const cutoff = Date.now() - maxJobAgeDays * 24 * 60 * 60 * 1000;
  return parsed >= cutoff;
}

function jobFingerprint(job: NormalizedJob) {
  const title = fingerprintText(job.title)
    .replace(/\b(remote|hybrid|onsite|part|time|full|opening|grand|urgent|hiring)\b/g, " ")
    .replace(/\s+/g, " ")
    .trim();
  const company = fingerprintText(job.company);
  if (title && company) return `${job.provider}:${company}:${title}`;
  return `${job.provider}:${fingerprintText(job.applicationUrl)}:${title}`;
}

function fingerprintText(value: string) {
  return String(value ?? "")
    .toLowerCase()
    .replace(/[^a-z0-9]+/g, " ")
    .replace(/\s+/g, " ")
    .trim();
}

function cleanDescription(value: unknown) {
  return String(value ?? "")
    .replace(/<[^>]+>/g, " ")
    .replace(/&nbsp;/g, " ")
    .replace(/&amp;/g, "&")
    .replace(/\s+/g, " ")
    .trim();
}

function cacheKeyFor(provider: string, query: string, req: SearchRequest) {
  return [
    provider,
    query,
    req.location || "",
    req.remote === true ? "remote" : "any",
    req.salaryMin ?? "",
    req.employmentType ?? "",
  ]
    .map((value) => fingerprintText(String(value)))
    .join("|");
}

async function readJobCache(cacheKey: string): Promise<NormalizedJob[] | null> {
  const supabaseUrl = Deno.env.get("SUPABASE_URL");
  const serviceRoleKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY");
  if (!supabaseUrl || !serviceRoleKey) return null;

  try {
    const url = new URL(`${supabaseUrl}/rest/v1/cached_job_searches`);
    url.searchParams.set("select", "response");
    url.searchParams.set("cache_key", `eq.${cacheKey}`);
    url.searchParams.set("expires_at", `gt.${new Date().toISOString()}`);
    url.searchParams.set("limit", "1");
    const response = await fetch(url, {
      headers: {
        apikey: serviceRoleKey,
        Authorization: `Bearer ${serviceRoleKey}`,
      },
    });
    if (!response.ok) return null;
    const rows = await response.json();
    const cached = Array.isArray(rows) ? rows[0]?.response : null;
    if (!Array.isArray(cached)) return null;
    const current = filterCurrentJobs(cached as NormalizedJob[]);
    return current.length > 0 ? current : null;
  } catch (_) {
    return null;
  }
}

async function writeJobCache(cacheKey: string, provider: string, jobs: NormalizedJob[]) {
  const supabaseUrl = Deno.env.get("SUPABASE_URL");
  const serviceRoleKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY");
  if (!supabaseUrl || !serviceRoleKey) return;

  const expiresAt = new Date(Date.now() + 30 * 60 * 1000).toISOString();
  await fetch(`${supabaseUrl}/rest/v1/cached_job_searches?on_conflict=cache_key`, {
    method: "POST",
    headers: {
      apikey: serviceRoleKey,
      Authorization: `Bearer ${serviceRoleKey}`,
      "Content-Type": "application/json",
      Prefer: "resolution=merge-duplicates",
    },
    body: JSON.stringify({
      provider,
      cache_key: cacheKey,
      response: jobs,
      expires_at: expiresAt,
    }),
  }).catch(() => undefined);
}

async function hasActiveSubscription(req: Request): Promise<boolean> {
  const authHeader = req.headers.get("authorization");
  if (!authHeader) return false;

  const supabaseUrl = Deno.env.get("SUPABASE_URL");
  const serviceRoleKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY");
  if (!supabaseUrl || !serviceRoleKey) return false;

  try {
    const supabase = createClient(supabaseUrl, serviceRoleKey, {
      auth: { persistSession: false },
    });
    const token = authHeader.replace(/^Bearer\s+/i, "");
    const { data, error } = await supabase.auth.getUser(token);
    const user = data?.user;
    if (error || !user || user.is_anonymous) return false;

    const { data: rows } = await supabase
      .from("billing_subscriptions")
      .select("status")
      .eq("user_id", user.id)
      .in("status", ["active", "trialing"])
      .limit(1);
    return Array.isArray(rows) && rows.length > 0;
  } catch (_) {
    return false;
  }
}

async function logJobApiUsage(log: UsageLog) {
  const supabaseUrl = Deno.env.get("SUPABASE_URL");
  const serviceRoleKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY");
  if (!supabaseUrl || !serviceRoleKey) return;

  await fetch(`${supabaseUrl}/rest/v1/job_api_usage`, {
    method: "POST",
    headers: {
      apikey: serviceRoleKey,
      Authorization: `Bearer ${serviceRoleKey}`,
      "Content-Type": "application/json",
    },
    body: JSON.stringify(log),
  }).catch(() => undefined);
}

async function safeResponseText(response: Response) {
  const text = await response.text().catch(() => "");
  return text.slice(0, 500);
}
