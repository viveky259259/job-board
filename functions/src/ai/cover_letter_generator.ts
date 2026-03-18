interface CoverLetterInput {
  jobTitle: string;
  jobCompany: string;
  jobDescription: string;
  jobRequirements: string[];
  userName: string;
  userHeadline: string;
  userSummary: string;
  userSkills: string[];
  userExperience: Array<{ title: string; company: string; description?: string }>;
  tone: "professional" | "enthusiastic" | "casual";
}

interface CoverLetterOutput {
  content: string;
  atsScore: number;
}

/**
 * Generates a tailored cover letter. When a Gemini API key is configured,
 * uses the AI model. Falls back to template-based generation.
 */
export async function generateCoverLetter(
  input: CoverLetterInput
): Promise<CoverLetterOutput> {
  // Template-based generation (replace with Gemini API call when key is set)
  const content = buildFromTemplate(input);
  const atsScore = calculateAtsScore(input);

  return { content, atsScore };
}

function buildFromTemplate(input: CoverLetterInput): string {
  const { jobTitle, jobCompany, userName, userHeadline, userSkills, userExperience, jobRequirements, tone } = input;

  const name = userName || "the applicant";
  const headline = userHeadline || "a professional";
  const skills = userSkills.length > 0 ? userSkills.slice(0, 5).join(", ") : "various technical skills";

  let greeting: string;
  let closing: string;

  switch (tone) {
    case "enthusiastic":
      greeting = `I'm thrilled to apply for the ${jobTitle} position at ${jobCompany}! This role perfectly aligns with my passion and expertise.`;
      closing = `I'm incredibly excited about this opportunity and eager to bring my energy, skills, and dedication to your team. I would welcome the chance to discuss how I can contribute to ${jobCompany}'s success!`;
      break;
    case "casual":
      greeting = `I came across the ${jobTitle} role at ${jobCompany} and it really caught my attention — it looks like a fantastic fit for my background.`;
      closing = `I'd love to chat more about this role and how my experience could benefit your team. Looking forward to connecting!`;
      break;
    default:
      greeting = `I am writing to express my strong interest in the ${jobTitle} position at ${jobCompany}. With my background as ${headline}, I am confident in my ability to make meaningful contributions to your team.`;
      closing = `Thank you for considering my application. I look forward to the opportunity to discuss how my experience and skills align with the needs of your team at ${jobCompany}.`;
  }

  const expSection = userExperience.length > 0
    ? `\n\nIn my most recent role as ${userExperience[0].title} at ${userExperience[0].company}, I honed my expertise in ${skills}. ${userExperience[0].description || "I consistently delivered high-quality results and contributed to team success."}`
    : `\n\nWith strong expertise in ${skills}, I have built a solid foundation that directly aligns with the requirements of this role.`;

  const reqMatch = jobRequirements.length > 0
    ? `\n\nYour listing highlights the need for experience with ${jobRequirements.slice(0, 3).join(", ")}. I bring hands-on experience with these technologies and am ready to contribute from day one.`
    : "";

  return `Dear Hiring Manager,

${greeting}${expSection}${reqMatch}

${closing}

Best regards,
${name}`;
}

function calculateAtsScore(input: CoverLetterInput): number {
  if (input.jobRequirements.length === 0) return 75;

  const matchedKeywords = input.jobRequirements.filter((req) =>
    input.userSkills.some((skill) =>
      req.toLowerCase().includes(skill.toLowerCase()) ||
      skill.toLowerCase().includes(req.toLowerCase())
    )
  );

  const ratio = matchedKeywords.length / input.jobRequirements.length;
  return Math.round(Math.min(ratio * 100 + 20, 100));
}
