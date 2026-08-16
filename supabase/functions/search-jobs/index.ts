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

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
};

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") return new Response("ok", { headers: corsHeaders });

  try {
    const body = (await req.json()) as SearchRequest;
    const titles = body.titles?.length ? body.titles : ["Learning and Development Specialist"];
    const [adzuna, usajobs] = await Promise.all([
      searchAdzuna(titles, body),
      searchUsaJobs(titles, body),
    ]);

    return Response.json(
      { jobs: [...adzuna, ...usajobs].slice(0, 50), demo: adzuna.length + usajobs.length === 0 },
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

  const query = encodeURIComponent(titles.slice(0, 3).join(" OR "));
  const where = encodeURIComponent(req.location || "United States");
  const params = new URLSearchParams({
    app_id: appId,
    app_key: appKey,
    results_per_page: "20",
    what: titles.slice(0, 3).join(" OR "),
    where: req.location || "United States",
    "content-type": "application/json",
  });
  if (req.salaryMin) params.set("salary_min", String(req.salaryMin));
  if (req.employmentType === "full_time") params.set("full_time", "1");
  if (req.remote) params.set("what_or", "remote");
  const url = `https://api.adzuna.com/v1/api/jobs/us/search/1?${params}`;
  const response = await fetch(url);
  if (!response.ok) return [];
  const data = await response.json();
  const results = Array.isArray(data.results) ? data.results : [];

  return results.map((job: Record<string, any>): NormalizedJob => ({
    id: String(job.id),
    provider: "adzuna",
    title: String(job.title ?? ""),
    company: String(job.company?.display_name ?? ""),
    location: String(job.location?.display_name ?? ""),
    description: String(job.description ?? ""),
    salaryMin: typeof job.salary_min === "number" ? Math.round(job.salary_min) : null,
    salaryMax: typeof job.salary_max === "number" ? Math.round(job.salary_max) : null,
    employmentType: String(job.contract_time ?? "Not specified"),
    remote: /remote/i.test(`${job.title} ${job.description} ${job.location?.display_name}`),
    postedDate: typeof job.created === "string" ? job.created : null,
    applicationUrl: String(job.redirect_url ?? ""),
  }));
}

async function searchUsaJobs(titles: string[], req: SearchRequest): Promise<NormalizedJob[]> {
  const apiKey = Deno.env.get("USAJOBS_API_KEY");
  const userAgent = Deno.env.get("USAJOBS_USER_AGENT");
  if (!apiKey || !userAgent) return [];

  const keyword = encodeURIComponent(titles[0]);
  const location = encodeURIComponent(req.location || "");
  const url = `https://data.usajobs.gov/api/search?Keyword=${keyword}&LocationName=${location}&ResultsPerPage=20`;
  const response = await fetch(url, {
    headers: {
      "Authorization-Key": apiKey,
      "User-Agent": userAgent,
    },
  });
  if (!response.ok) return [];
  const data = await response.json();
  const items = Array.isArray(data.SearchResult?.SearchResultItems) ? data.SearchResult.SearchResultItems : [];

  return items.map((item: Record<string, any>): NormalizedJob => {
    const descriptor = item.MatchedObjectDescriptor ?? {};
    const remuneration = descriptor.PositionRemuneration?.[0] ?? {};
    return {
      id: String(descriptor.PositionID ?? item.MatchedObjectId),
      provider: "usajobs",
      title: String(descriptor.PositionTitle ?? ""),
      company: String(descriptor.OrganizationName ?? ""),
      location: String(descriptor.PositionLocationDisplay ?? ""),
      description: String(descriptor.UserArea?.Details?.JobSummary ?? ""),
      salaryMin: Number.isFinite(Number(remuneration.MinimumRange)) ? Math.round(Number(remuneration.MinimumRange)) : null,
      salaryMax: Number.isFinite(Number(remuneration.MaximumRange)) ? Math.round(Number(remuneration.MaximumRange)) : null,
      employmentType: String(descriptor.PositionSchedule?.[0]?.Name ?? "Not specified"),
      remote: /remote/i.test(`${descriptor.PositionTitle} ${descriptor.PositionLocationDisplay} ${descriptor.UserArea?.Details?.JobSummary}`),
      postedDate: typeof descriptor.PublicationStartDate === "string" ? descriptor.PublicationStartDate : null,
      applicationUrl: String(descriptor.PositionURI ?? ""),
    };
  });
}
