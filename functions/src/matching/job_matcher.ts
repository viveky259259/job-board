export function matchJobs(job: any, profile: any): number {
  let score = 0;
  let maxScore = 0;

  // Title match (30 points)
  maxScore += 30;
  const targetRoles = profile.preferences?.targetRoles || [];
  for (const role of targetRoles) {
    if (job.title?.toLowerCase().includes(role.toLowerCase())) {
      score += 30;
      break;
    }
  }

  // Skills match (30 points)
  maxScore += 30;
  const userSkills: string[] = profile.skills || [];
  const jobRequirements: string[] = job.requirements || [];
  if (userSkills.length > 0 && jobRequirements.length > 0) {
    const matched = userSkills.filter((skill: string) =>
      jobRequirements.some((req: string) =>
        req.toLowerCase().includes(skill.toLowerCase())
      )
    );
    score += Math.round((matched.length / userSkills.length) * 30);
  }

  // Location match (15 points)
  maxScore += 15;
  const prefLocations: string[] = profile.preferences?.locations || [];
  if (prefLocations.length === 0) {
    score += 15;
  } else {
    for (const loc of prefLocations) {
      if (job.location?.toLowerCase().includes(loc.toLowerCase())) {
        score += 15;
        break;
      }
    }
  }

  // Remote match (10 points)
  maxScore += 10;
  const remotePref: string[] = profile.preferences?.remotePreference || [];
  if (remotePref.length === 0 || remotePref.includes(job.remote)) {
    score += 10;
  }

  // Job type match (10 points)
  maxScore += 10;
  const jobTypePref: string[] = profile.preferences?.jobTypes || [];
  if (jobTypePref.length === 0 || jobTypePref.includes(job.jobType)) {
    score += 10;
  }

  // Salary match (5 points)
  maxScore += 5;
  const salaryMin = profile.preferences?.salaryMin;
  if (!salaryMin || !job.salaryMax || job.salaryMax >= salaryMin) {
    score += 5;
  }

  if (maxScore === 0) return 0;
  return Math.round((score / maxScore) * 100);
}
