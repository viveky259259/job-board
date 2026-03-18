interface IntroMessageInput {
  jobTitle: string;
  jobCompany: string;
  jobDescription: string;
  userName: string;
  userHeadline: string;
  userSkills: string[];
  tone: "professional" | "enthusiastic" | "casual";
  platform: string;
}

interface IntroMessageOutput {
  content: string;
}

export async function generateIntroMessage(
  input: IntroMessageInput
): Promise<IntroMessageOutput> {
  const content = buildIntroMessage(input);
  return { content };
}

function buildIntroMessage(input: IntroMessageInput): string {
  const { jobTitle, jobCompany, userName, userHeadline, userSkills, tone, platform } = input;

  const name = userName || "there";
  const headline = userHeadline || "a professional";
  const topSkill = userSkills.length > 0 ? userSkills[0] : "software development";

  const maxLength = platform === "LinkedIn" ? 300 : 500;

  let message: string;

  switch (tone) {
    case "enthusiastic":
      message = `Hi! I'm ${name}, ${headline} with a deep passion for ${topSkill}. I just discovered the ${jobTitle} opening at ${jobCompany} and I'm genuinely excited about it! The role aligns perfectly with my experience and goals. Would you be open to a brief conversation about the position? I'd love to share how my background could add value to your team!`;
      break;
    case "casual":
      message = `Hey! I'm ${name} — ${headline}. Spotted the ${jobTitle} role at ${jobCompany} and thought my ${topSkill} background could be a great match. Would love to connect and learn more about what you're building!`;
      break;
    default:
      message = `Hello, I'm ${name}, ${headline}. I noticed the ${jobTitle} position at ${jobCompany} and believe my expertise in ${topSkill} aligns closely with your team's needs. I would welcome the opportunity to connect and discuss how my experience could contribute to your goals. Thank you for your time.`;
  }

  if (message.length > maxLength) {
    message = message.substring(0, maxLength - 3) + "...";
  }

  return message;
}
