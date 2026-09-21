---
name: job-search
description: |
  Search for new Senior/Staff+ engineering job postings matching Melissa's resume and stack,
  compare each against her resume for overlaps and gaps, dedupe against previously-seen
  postings, and email a digest. Use when: running the weekly job search, checking for new
  postings on demand. Keywords: job search, job hunt, job postings, career watchlist,
  resume comparison, job digest, weekly job scan.
allowed-tools: Bash, Read, Write, WebFetch, WebSearch
user-invocable: true
---

# Job Search

Finds new Senior/Staff+ engineering postings from a fixed company watchlist plus general web
search, filters them against comp/location/seniority criteria, compares each surviving posting
against Melissa's resume (explicit overlaps and gaps), dedupes against previously-seen postings,
and emails a digest. LinkedIn and Indeed are deliberately excluded as sources — neither offers a
usable public job-search API and scraping either violates their ToS.

## Usage

```
/job-search
/job-search --dry-run
```

`--dry-run` prints the digest to chat instead of sending email or updating dedup state. Use it to
test changes to the watchlist or filter criteria without spamming the inbox or burning dedup state.

## Prerequisites

Abort with a clear message if any of these aren't met:

1. Resume file exists at `~/code/junk-drawer/resume-light.html`.
2. `python3` is on PATH.
3. The macOS Keychain item for email sending is provisioned (see Manual Setup below). Only check
   this before an actual (non-dry-run) send — don't block a dry run on it.
4. `${CLAUDE_PLUGIN_ROOT}/skills/job-search/config/companies.json` exists and is a non-empty array.

## Pipeline

1. **Read the resume** at `~/code/junk-drawer/resume-light.html`. Build a mental profile of
   current title, seniority, tech stack, and years of experience per skill area.
2. **Load the watchlist**: `${CLAUDE_PLUGIN_ROOT}/skills/job-search/config/companies.json`.
3. **Fetch each company's postings**: for each entry, use `WebFetch` on `careers_url` (or
   `Bash`/`curl` on `fetch_url` if it's set) and extract current Senior/Staff+ engineering
   openings. Several of these career pages are JS single-page apps that `WebFetch` can't render
   (it converts raw HTML to markdown, no JS execution) — if a fetch comes back as an empty shell
   with no actual listings, note that in your response and move on rather than fabricating
   postings. Entries whose `notes` field says `OPEN` haven't been verified yet; if you find a
   working ATS JSON endpoint for one, tell the user so `fetch_url` can be filled in.
4. **Web search pass**: run `WebSearch` for qualifying postings outside the watchlist (e.g.
   "Staff AI Engineer remote", "Senior Staff backend engineer $200k remote").
5. **Apply filter criteria** (see table below) to everything found so far.
6. **Dedupe**: read `~/.local/state/job-search/seen.json` (treat as `{}` if missing — first
   run). Drop any posting whose canonical URL is already a key.
7. **Compare surviving new postings against the resume**: for each one, `WebFetch` the actual JD
   text and write two bullet lists — **Overlaps** (skills/experience she has that match what the
   posting wants) and **Gaps** (things the posting wants that aren't evidenced in the resume).
   This is a judgment call each run, not a keyword-matching script — read both documents and
   reason about them.
8. **If nothing new survives**: report "no new postings this run" in chat and stop. Do not send
   an email. Do not touch `seen.json`.
9. **Otherwise, compose and send**:
   - Write the digest (see format below) to `~/.local/state/job-search/digest-<YYYY-MM-DD>.txt`.
   - If `--dry-run`: print the digest to chat and stop here.
   - Otherwise: run
     `python3 ${CLAUDE_PLUGIN_ROOT}/skills/job-search/scripts/send-email.py --subject "Job Search: N new postings (<date>)" --body-file ~/.local/state/job-search/digest-<date>.txt`
   - On success (exit 0): merge the new postings into `seen.json` and write it back.
   - On failure (nonzero exit): surface the script's stderr to the user. Do **not** update
     `seen.json` — leave the postings undeduped so they're retried next run.

## Filter criteria

| Dimension | Rule |
|---|---|
| Title/seniority | Senior or Staff+ (or higher). Prefer AI/ML/backend roles matching her stack: Elixir/Phoenix, Python, TypeScript/React, PostgreSQL, AWS, Kubernetes, LiveKit, RAG/LLM/voice pipelines. |
| Remote roles | Comp floor $200k. If comp is undisclosed, keep it and mark comp as `unknown` — don't drop for missing data. |
| Onsite/non-remote roles | Comp floor $240k. Same undisclosed-comp handling as above. |
| Exclusion | Only exclude a posting when comp is *disclosed* and clearly below the applicable floor. |

## Company watchlist

Lives at `${CLAUDE_PLUGIN_ROOT}/skills/job-search/config/companies.json`, a flat JSON array:

```json
{ "name": "Sierra", "careers_url": "https://...", "fetch_url": null, "notes": "" }
```

- `careers_url`: the page to `WebFetch` by default.
- `fetch_url`: optional. If set, `Bash`/`curl` this instead and treat the response as JSON (used
  once a real ATS API endpoint — e.g. a Greenhouse `boards-api.greenhouse.io` or Workday CXS
  endpoint — has been identified for a company whose public page is a JS SPA).
- `notes`: free text; `OPEN: ...` flags entries that haven't been verified yet.

To add a company, append an entry with `fetch_url: null` and empty notes — it'll be tried via
plain `WebFetch` first.

## Seen-postings state

Lives at `~/.local/state/job-search/seen.json`, outside the git repo (personal runtime data, not
config). Format:

```json
{
  "https://sierra.ai/careers/abc123": {
    "company": "Sierra",
    "title": "Senior AI Engineer, Voice Platform",
    "first_seen": "2026-07-22",
    "last_notified": "2026-07-22"
  }
}
```

- Key: the posting's canonical apply-page URL with tracking params (`utm_*`, `gh_src`, session
  tokens) stripped. If a posting has no stable URL, fall back to `"company::normalized-title"`.
- Run `mkdir -p ~/.local/state/job-search` at the start of every real run (idempotent).
- Write the merged dict back only after a successful (non-dry-run) email send — see Pipeline
  step 9.

## Digest format

Plain text, one section per new posting, ordered strongest-fit first:

```
<Company> — <Title> (<Location>) [Comp: <disclosed value or "unknown">]
<posting URL>

Overlaps:
- ...

Gaps:
- ...

Fit: Strong / Possible / Stretch — one-line rationale
```

## Manual setup (one-time, done by Melissa — not automated by this skill)

1. Generate a Gmail App Password: Google Account → Security → 2-Step Verification → App
   Passwords.
2. Store it in the macOS Keychain:
   ```
   security add-generic-password -a "melissa.patterson.va@gmail.com" -s "job-search-gmail-app-password" -w "<app-password>" -A
   ```
   The `-A` flag matters: without it, the first unattended `security find-generic-password` call
   from a cron/launchd context (no Window Server session) can hang on a Keychain
   access-confirmation dialog with nowhere to display it.
3. Test the sender directly before wiring up cron:
   ```
   python3 ~/.dot/claude/skills/job-search/scripts/send-email.py --subject "test" --body-file <(echo "hello")
   ```

## Scheduling (weekly, unattended)

`CronCreate` is the wrong tool here — its jobs are session-only (in-memory, gone when the Claude
session ends) and auto-expire after 7 days, so it can't run "every week whether or not I have a
session open." Use a plain crontab entry invoking `claude -p` headless instead:

```
0 8 * * 1 /opt/homebrew/bin/claude -p "/job-search" --permission-mode bypassPermissions >> ~/.local/state/job-search/last-run.log 2>&1
```

Monday 8am local. Output is logged since there's no interactive terminal watching a cron-launched
process — `last-run.log` is the only failure-diagnosis path. If the machine is asleep at the
scheduled time, cron just skips that run.

Before adding this to crontab, run the exact command by hand once to confirm the headless
invocation actually completes and sends.
