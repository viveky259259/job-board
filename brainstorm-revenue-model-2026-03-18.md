# Brainstorm: JobHunter AI Revenue Model
**Date**: 2026-03-18
**Type**: Revenue strategy + feature ideation

## The Pain (Why People Pay)

```
APPLICANT JOURNEY TODAY                    COST TO THE APPLICANT
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Write resume                               → 8-20 hours
Search for jobs (daily)                     → 1-2 hours/day × 150 days
Tailor each cover letter                    → 30-60 min each × 50+
Apply (fill forms, upload, submit)          → 15-30 min each × 50+
Wait... hear nothing... ghosted...          → Anxiety, 0 feedback
Get interview, no prep tools                → Wing it, hope for best
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Total: ~300-500 hours over 5 months         → $0 revenue for us
Average cost of unemployment: $3,000/month  → $15,000 lost per searcher
```

**Core insight**: A tool that cuts job search time from 5 months to 2 months saves the applicant ~$9,000 in lost wages. Charging $15-30/month is a no-brainer if it works.

## Revenue Architecture

```
                    ┌────────────────────────────────────────┐
                    │         REVENUE FLYWHEEL                │
                    │                                        │
                    │   Free Users (Acquisition)             │
                    │       │                                │
                    │       ▼ Hit usage limits               │
                    │   Paywall (Conversion)                 │
                    │       │                                │
                    │       ▼ See value, upgrade             │
                    │   Pro Users ($14.99/mo)                │
                    │       │                                │
                    │       ▼ Get hired, tell friends        │
                    │   Referrals (Viral Loop)               │
                    │       │                                │
                    │       ▼ New free users                 │
                    │   ┌───┘                                │
                    │   │ Some power users upgrade           │
                    │   ▼                                    │
                    │   Premium Users ($29.99/mo)            │
                    └────────────────────────────────────────┘
```

## Subscription Tiers

### Free — "Get Started"
**Purpose**: Acquisition. Let them feel the magic, then hit a wall.

| Feature | Limit |
|---------|-------|
| Job browsing & matching | Unlimited |
| AI cover letters | 3 per month |
| AI intro messages | 5 per month |
| Application tracker | Up to 10 active |
| Basic gamification | Full |
| Profile completeness | Full |
| Job match scores | Basic (no breakdown) |

**Conversion triggers**:
- "You've used 3/3 cover letters this month" → paywall
- "Upgrade to see why this job scored 87%" → paywall
- "Resume analyzer available on Pro" → paywall
- "Interview prep unlocked on Pro" → paywall

### Pro — "Get Hired Faster" ($14.99/month)
**Purpose**: Core revenue. Tangible time savings.

| Feature | Included |
|---------|----------|
| Everything in Free | Unlimited |
| AI cover letters | Unlimited |
| AI intro messages | Unlimited |
| Application tracker | Unlimited |
| Resume Analyzer | Score + keyword suggestions |
| Interview Prep | AI questions per job |
| Salary Insights | Market data per role/location |
| Match Score Breakdown | Detailed per-category scores |
| Advanced Analytics | Funnel, response rate, trends |
| Weekly Email Digest | Personalized job summary |
| CSV Export | Applications export |
| Priority Crawling | New jobs 2 hours earlier |

### Premium — "Your AI Career Agent" ($29.99/month)
**Purpose**: High-value power users. Maximum margin.

| Feature | Included |
|---------|----------|
| Everything in Pro | ✓ |
| AI Resume Tailoring | Per-job resume optimization |
| Company Research Briefs | AI-generated company intel |
| Follow-up Reminders | Smart automation |
| Multiple Resume Versions | Up to 5 |
| Priority Support | 24-hour response |
| Exclusive Job Sources | Premium API access |

## Revenue Projections (Conservative)

```
Month 1-3 (Launch):
  1,000 free users → 5% convert to Pro = 50 × $14.99 = $749/mo
  
Month 6:
  10,000 free → 7% Pro (700) + 2% Premium (200)
  = $700 × $14.99 + $200 × $29.99
  = $10,493 + $5,998 = $16,491/mo

Month 12:
  50,000 free → 8% Pro (4,000) + 3% Premium (1,500)
  = $59,960 + $44,985 = $104,945/mo → $1.26M ARR
```

## Conversion Psychology

1. **Value-first**: Let them generate 3 amazing cover letters. They KNOW the tool works.
2. **Scarcity**: "3/3 used" creates urgency without being annoying.
3. **Social proof**: Show "87% of Pro users report faster response rates"
4. **Loss aversion**: "Your streak will freeze without Pro" (streak protection)
5. **Anchoring**: Show Premium first ($29.99) to make Pro ($14.99) feel cheap.

## Implementation Priority

1. Subscription model + paywall (gates revenue)
2. Usage tracking (enables conversion triggers)
3. Resume Analyzer (highest perceived value)
4. Interview Prep (second highest value)
5. Salary Insights (data moat)
6. Advanced Analytics (retention driver)
7. Settings + subscription management

## Key Metrics to Track

- **Free → Pro conversion rate** (target: 5-8%)
- **Pro → Premium upgrade rate** (target: 15-20%)
- **Churn rate** (target: <5% monthly)
- **Paywall impression → conversion** (target: 10-15%)
- **Feature usage by tier** (which features drive conversion)
- **Time-to-conversion** (avg days from signup to Pro)
