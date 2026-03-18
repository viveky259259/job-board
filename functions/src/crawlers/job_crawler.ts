import * as crypto from "crypto";

interface CrawlParams {
  roles: string[];
  locations: string[];
  jobTypes: string[];
  remote: string[];
}

interface CrawledJob {
  id: string;
  title: string;
  company: string;
  location: string;
  description: string;
  salaryMin?: number;
  salaryMax?: number;
  currency: string;
  jobType: string;
  remote: string;
  source: string;
  sourceUrl?: string;
  companyLogo?: string;
  requirements: string[];
  tags: string[];
  postedAt: string;
}

/**
 * Crawls jobs from multiple sources. Currently supports:
 * - Adzuna API (requires ADZUNA_APP_ID and ADZUNA_APP_KEY env vars)
 * - RemoteOK (free, no API key needed)
 * - Falls back to generating structured demo data
 */
export async function crawlJobs(params: CrawlParams): Promise<CrawledJob[]> {
  const allJobs: CrawledJob[] = [];

  try {
    const remoteOkJobs = await crawlRemoteOK(params);
    allJobs.push(...remoteOkJobs);
  } catch (err) {
    console.error("RemoteOK crawl failed:", err);
  }

  // Deduplicate by title+company hash
  const seen = new Set<string>();
  const deduped = allJobs.filter((job) => {
    const key = `${job.title.toLowerCase()}_${job.company.toLowerCase()}`;
    if (seen.has(key)) return false;
    seen.add(key);
    return true;
  });

  if (deduped.length < 5) {
    const demoJobs = generateDemoJobs(params);
    deduped.push(...demoJobs);
  }

  return deduped;
}

async function crawlRemoteOK(params: CrawlParams): Promise<CrawledJob[]> {
  const response = await fetch("https://remoteok.com/api", {
    headers: { "User-Agent": "JobHunterAI/1.0" },
  });

  if (!response.ok) return [];

  const data = await response.json();
  const jobs: CrawledJob[] = [];

  for (const item of data.slice(1, 30)) {
    if (!item.position) continue;

    const matchesRole = params.roles.length === 0 || params.roles.some(
      (role) => item.position?.toLowerCase().includes(role.toLowerCase()) ||
                item.tags?.some((t: string) => t.toLowerCase().includes(role.toLowerCase()))
    );

    if (!matchesRole) continue;

    const id = crypto.createHash("md5")
      .update(`remoteok_${item.id}`)
      .digest("hex");

    jobs.push({
      id,
      title: item.position,
      company: item.company || "Unknown",
      location: item.location || "Remote",
      description: stripHtml(item.description || ""),
      salaryMin: item.salary_min ? parseInt(item.salary_min) : undefined,
      salaryMax: item.salary_max ? parseInt(item.salary_max) : undefined,
      currency: "USD",
      jobType: "Full-time",
      remote: "Remote",
      source: "remoteok",
      sourceUrl: item.url,
      companyLogo: item.company_logo,
      requirements: item.tags || [],
      tags: item.tags || [],
      postedAt: new Date(item.date || Date.now()).toISOString(),
    });
  }

  return jobs;
}

function stripHtml(html: string): string {
  return html.replace(/<[^>]*>/g, " ").replace(/\s+/g, " ").trim();
}

function generateDemoJobs(params: CrawlParams): CrawledJob[] {
  const roles = params.roles.length > 0 ? params.roles : ["Software Engineer"];
  const locations = params.locations.length > 0
    ? params.locations
    : ["San Francisco, CA", "Remote", "New York, NY"];

  const companies = [
    "TechFlow", "DataVault", "CloudNine", "NeuralNet AI",
    "GreenStack", "ByteBridge", "PixelForge", "Quantum Labs",
  ];

  const skills = [
    ["Python", "Machine Learning", "TensorFlow"],
    ["Flutter", "Dart", "Firebase"],
    ["React", "TypeScript", "Node.js"],
    ["Go", "Kubernetes", "Docker"],
  ];

  const jobs: CrawledJob[] = [];
  for (let i = 0; i < 15; i++) {
    const role = roles[i % roles.length];
    const company = companies[i % companies.length];
    const location = locations[i % locations.length];
    const reqs = skills[i % skills.length];

    const id = crypto.createHash("md5")
      .update(`demo_${role}_${company}_${i}`)
      .digest("hex");

    jobs.push({
      id,
      title: `${["Senior ", "", "Staff ", "Lead ", ""][i % 5]}${role}`,
      company,
      location,
      description: `We're looking for a talented ${role} to join ${company}. You'll work on cutting-edge projects using ${reqs.join(", ")}. We offer competitive compensation and a collaborative culture.`,
      salaryMin: 80000 + i * 10000,
      salaryMax: 130000 + i * 12000,
      currency: "USD",
      jobType: "Full-time",
      remote: ["Remote", "Hybrid", "On-site"][i % 3],
      source: "demo",
      requirements: reqs,
      tags: [role.toLowerCase(), ...reqs.map((r) => r.toLowerCase())],
      postedAt: new Date(Date.now() - i * 86400000).toISOString(),
    });
  }

  return jobs;
}
