# Coach Pipeline — n8n automation for fitness coaches

An end-to-end client pipeline for a 1:1 online fitness coach or small gym, built as seven importable n8n workflows. Claude qualifies leads, screens for health red flags, writes every email, analyses weekly check-ins and sends the coach a Monday digest. Google Sheets is the database, Gmail sends email, and Telegram pings the coach.

```
Application form / website ──► 01 Lead intake ──► Claude scores + writes reply ──► Leads sheet ──► email applicant
                                                                                     └─► Telegram: hot lead / health flag
Cal.com / Calendly ─────────► 02 Booking sync ──► update lead ──► prep email ──► Telegram pre-call brief
Stripe checkout paid ───────► 03 Onboarding ────► Claude welcome pack ──► Clients sheet ──► welcome email ──► Telegram
Sunday 9am ─────────────────► 04 Check-in reminders ──► personal form link to every active client
Check-in form ──────────────► 05 Analysis ──────► Claude triage (green/amber/red) ──► CheckIns sheet
                                                    ├─► green/amber: reply emailed automatically
                                                    └─► red / health mention: Telegram to coach with a draft (never auto-sent)
Daily 10am ─────────────────► 06 Follow-ups ────► 3-step Claude follow-ups for unbooked leads + "quiet clients" alert
Monday 8am ─────────────────► 07 Digest ────────► Claude weekly summary + content idea ──► coach inbox
```

## What's in this folder

| Path | What it is |
|---|---|
| `workflows/01_lead_intake.json` | Hosted application form + website webhook → Claude qualification → Leads sheet → first reply email → Telegram alert for hot leads and health flags |
| `workflows/02_booking_sync.json` | Cal.com / Calendly / generic booking webhook → lead status → prep or rebooking email → coach pre-call brief |
| `workflows/03_client_onboarding.json` | Stripe `checkout.session.completed` → Claude welcome email + week-one focus → Clients sheet → lead marked won |
| `workflows/04_checkin_reminders.json` | Sunday schedule → personal check-in link to each active client |
| `workflows/05_checkin_analysis.json` | Hosted weekly check-in form → Claude triage against history → auto-reply or coach review |
| `workflows/06_daily_followups.json` | Daily schedule → follow-up emails 2, 4 and 7 days after the last contact → coach alert for clients who have gone quiet |
| `workflows/07_coach_digest.json` | Monday schedule → funnel + retention stats → Claude digest email to the coach |
| `sheets/*.csv` | Header rows for the three Google Sheet tabs |

## Setup (about 30 minutes)

### 1. Google Sheet
1. Create a new Google Sheet with three tabs named exactly **Leads**, **Clients** and **CheckIns**.
2. Paste the header row from the matching file in `sheets/` into row 1 of each tab (or use File → Import → Upload, one tab at a time, with "Replace current sheet").
3. Copy the sheet ID from its URL: `https://docs.google.com/spreadsheets/d/`**`THIS_PART`**`/edit`.

### 2. Credentials in n8n Cloud
Create these under **Credentials → Add credential**:

| Credential | Used by | Notes |
|---|---|---|
| **Anthropic** | every `Claude:` node | API key from console.anthropic.com. The HTTP nodes use it through *Predefined credential type → Anthropic*. |
| **Google Sheets OAuth2** | every sheet node | One-click OAuth on n8n Cloud. |
| **Gmail OAuth2** | every email node | Sends from the connected Google account. |
| **Telegram** | coach alerts | Create a bot with @BotFather, send it a message, then get your chat ID from `https://api.telegram.org/bot<TOKEN>/getUpdates`. |
| **Stripe** | 03 only | Secret key; n8n registers the Stripe webhook automatically when the workflow is activated. |

### 3. Import and configure
1. In n8n: **Workflows → Import from File**, once per JSON file in `workflows/`.
2. Open each workflow's **Config** node and fill in the same values in all seven:

| Field | Example | Meaning |
|---|---|---|
| `businessName` | Forge Coaching | Used in emails and prompts |
| `coachName` | Alex | Email sign-off and sender name |
| `coachEmail` | alex@forgecoaching.com | Reply-to address and digest recipient |
| `programName` / `programPrice` | 12-Week Transformation / $249 | Lets Claude judge budget fit |
| `bookingUrl` | https://cal.com/alex/consult | Consult booking link used in emails |
| `checkinFormUrl` | https://you.app.n8n.cloud/form/weekly-checkin | Production URL of the form in workflow 05 |
| `sheetId` | 1AbC… | From step 1 |
| `telegramChatId` | 123456789 | Where coach alerts go |
| `timezone` | America/New_York | For times shown in emails |
| `claudeModel` | claude-opus-5 | Model for every AI step |
| `autoReplyClients` | true | `false` sends every check-in reply to the coach for approval instead |
| `missedCheckinDays` | 10 | When a quiet client gets flagged |

3. Open every node that shows a credential warning and pick the credential you created.
4. In each workflow's **Settings**, set the timezone to yours so the schedules fire at local time.

### 4. Connect the outside world
- **Lead form:** activate workflow 01 and share the **Application Form** production URL (`/form/coach-apply`), or POST JSON from your site to the **Website Webhook** URL (`/webhook/coach-lead`) with any of: `name, email, phone, goal, goal_details, experience, days_per_week, timeline, budget, health_notes, source`.
- **Bookings:** add the **Booking Webhook** production URL (`/webhook/coach-booking`) to Cal.com (Settings → Developer → Webhooks: Booking Created / Rescheduled / Cancelled) or Calendly (webhook subscription for `invitee.created` and `invitee.canceled`). Other tools can POST `{ email, name, start_time, status }`.
- **Payments:** sell through Stripe Checkout or a Payment Link. Optionally add metadata `plan` to name the plan.
- **Check-ins:** activate workflow 05 and copy the **Check-in Form** production URL into `checkinFormUrl`.

### 5. Test, then activate
Run each workflow once with **Test workflow** using your own email address, check the sheet rows and the emails, then flip **Active** on all seven.

## How the AI steps work

Every `Claude:` node is a plain HTTP Request to the Anthropic Messages API, not a LangChain node. That gives full control of the request:

- **Structured outputs** (`output_config.format` with a JSON schema): every response is valid JSON matching the schema, so there's no fragile text parsing.
- **Effort**: `medium` for qualification, onboarding, analysis and the digest, and `low` for follow-up emails.
- **Refusal fallback** (`fallbacks: "default"`, beta header `server-side-fallback-2026-07-01`): if a safety classifier declines a request, Anthropic re-runs it on a fallback model instead of failing. The Parse nodes still check `stop_reason` and fail loudly on a refusal or truncation, so nothing half-written is ever emailed.
- **Retries**: each Claude node retries 3 times, 5 s apart, on network or rate-limit errors.

The request is built in the `Build … Prompt` Code node just before each Claude node. Edit the system prompt there to change the tone, the rules or the scoring rubric.

**Cost:** each call uses roughly 1–3k input tokens and 1–3k output tokens, a few cents per call at Claude Opus 5 pricing ($5 / $25 per million tokens). A client costs about 4 check-in analyses a month. To cut cost, set `claudeModel` to `claude-sonnet-5`.

## Health-safety guardrails

This is a health niche, so the pipeline treats "the AI said something medical" as the main failure to design against:

- Every prompt forbids diagnosis, medical advice, calorie or body-fat targets, supplements, medication and comments on body shape.
- **Intake** flags heart conditions, chest pain, fainting, diabetes, pregnancy, recent surgery, current injuries, eating-disorder history and heart-rate or blood-sugar medication as `medical_clearance: required`, and alerts the coach.
- **Check-ins** that mention pain, injury, illness, new medication, disordered-eating signals, very low mood or wanting to quit are forced to **red**. Claude drafts the reply, but it goes only to the coach on Telegram; it is never auto-sent.
- Check-ins from an email that isn't in Clients also go to the coach instead of getting an automatic reply.
- Follow-up emails never mention a health condition, and each one carries a "reply stop" line. Set the lead's status to `unsubscribed` or `lost` to stop further emails.

## Lead and client statuses

| Sheet | Status | Set by |
|---|---|---|
| Leads | `new` | 01 on application |
| Leads | `booked` / `cancelled` | 02 from the scheduler |
| Leads | `won` | 03 on payment |
| Leads | `nurture_done` | 06 after the third follow-up |
| Leads | `lost` / `unsubscribed` | You, by hand |
| Clients | `active` | 03 on payment; set to `paused` or `ended` by hand to stop reminders |
| Clients | `unmatched` | 05, when a check-in arrives from an unknown email |

## Customising

- **Slack instead of Telegram:** replace each Telegram node with a Slack node that posts `{{ ... .coach_alert }}` to a channel.
- **Airtable or Postgres instead of Sheets:** swap the sheet nodes; the Code nodes only read plain fields such as `email` and `status`.
- **WhatsApp reminders:** add a WhatsApp Business Cloud node after `Build Reminders` in 04 alongside the Gmail node.
- **Different cadence:** follow-up spacing is `CADENCE_DAYS` in the *Pick Follow-ups* node of 06; the schedules are cron expressions on each trigger.
