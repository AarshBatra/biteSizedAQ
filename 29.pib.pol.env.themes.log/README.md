PIB India Pollution Press Release Log
================

## What this is

A public, auto-updating log of India-related press releases (default:
pollution / environment / climate) issued by the Press Information
Bureau (PIB), written to a public Google Sheet by a scheduled GitHub
Actions job.

**Copy this project and edit `config/keywords.yml` to track a different
topic** — the helper script (`R/pib_pollution_log.R` at the repo root)
doesn’t need to change.

## How it works

1.  A GitHub Actions workflow
    (`.github/workflows/pib-pollution-log.yml`) runs `run_daily.R` every
    4 hours
2.  It pulls PIB’s “latest releases” RSS feed (English) — the ~20 most
    recent releases
3.  For each, it fetches the release’s own page to get date, ministry,
    and full body text
4.  Keywords from `config/keywords.yml` are matched against title AND
    body
5.  Matches are appended to the Google Sheet, deduped by PRID
6.  If a day has no matches, one `"No PIB"` placeholder row is written
    for that day (once, not once per run) so the log has no silent gaps

The log accumulates history from whenever it starts running; there is no
automated backfill (see below).

## Keyword matching (three tiers)

Configured entirely in `config/keywords.yml`:

- **`keywords`** — strong terms, matched standalone. Case-insensitive,
  word-bounded (so `GRAP` never matches `demographic`), hyphen-tolerant
  (`clean air` finds `clean-air`), and auto-plural (`emission` also
  matches `emissions`).
- **`contextual_keywords`** — vague words like `water`, `green`,
  `carbon` that fire ONLY when an `anchor` word appears within ~6 words.
  This catches `water pollution` and `green hydrogen` without the false
  positives those words cause alone (`water taxi`, `green channel`).
- **`anchors`** — the environmental words a contextual term must be
  near.

Matching runs against both the title and the body text, so releases with
uninformative headlines are still caught.

## PIB site quirks (learned the hard way — don’t undo these)

PIB India has no public API, so this reads its RSS feed. Non-obvious
behaviours found by testing the live site:

- **Language is set by lowercase `lang=1&reg=3`.** The capitalised
  `Lang`/`Regid` parameters PIB’s own RSS page advertises are ignored
  and return Hindi.
- **No persistent session.** Opening one makes PIB pin the language to
  Hindi and override `lang=1`. Every request is a fresh, cookie-free
  GET.
- **English and Hindi versions of a release have different PRIDs.**
  Staying on `lang=1` keeps PRIDs stable for deduplication.
- **The RSS feed gives title + link only** — date, ministry, and body
  come from each release’s own page.
- **On a release page, the ministry** is the first non-empty line
  (sometimes a short code like `AYUSH`, sometimes a full name). The date
  byline varies: `17 JUL 2026 10:22PM by PIB Delhi` or `Posted On:` then
  the date.
- **The feed holds only ~20 items** (a hard server cap — a `count`
  parameter has no effect) spanning roughly a day. Running every 4 hours
  ensures nothing scrolls off unseen between runs.

## No automated backfill

The feed can’t reach the past, and PIB’s month-by-month listing page
(`allRel.aspx`) sits behind Akamai bot protection: query parameters and
form POSTs are ignored, and headless browsers are blocked with “Access
Denied”. A normal browser is not blocked.

To seed history manually: open the listing page in a browser (English,
National, all ministries), pick a month, save the page (Ctrl+S →
“Webpage, HTML Only”), and parse the saved HTML locally. For most
purposes the daily log is enough on its own.

## Setup

### 1. Create the Google Sheet

Create a new Google Sheet, share it as **Anyone with the link →
Viewer**.

### 2. Create a Google Cloud service account

Enable the **Google Sheets API** in a Google Cloud project, create a
**Service Account**, generate a JSON key, and share the Sheet with the
service account’s email as **Editor**.

### 3. Configure repo secrets

Repo Settings → Secrets and variables → Actions:

- `GCP_SA_KEY` — full contents of the service account JSON key
- `SHEET_ID` — the ID from the Sheet’s URL

### 4. Enable the workflow

Push, then trigger it manually once from the Actions tab
(`workflow_dispatch`) to confirm before relying on the schedule.

## Customizing for a different topic

Edit `config/keywords.yml`. Move a word between `keywords` (standalone)
and `contextual_keywords` (needs an anchor) depending on how noisy it
is. Nothing in the R code changes.

## Local development

``` r
devtools::load_all()

releases <- fetch_latest_releases()               # ~20 recent, English titles
details  <- purrr::map(releases$prid, fetch_release_detail)
releases$body <- purrr::map_chr(details, ~ .x$body %||% "")

cfg <- load_config(here::here("29.pib.pol.env.themes.log", "config", "keywords.yml"))
hit <- match_keywords(releases$title, cfg) | match_keywords(releases$body, cfg)
releases$title[hit]                               # what would be logged
```

Zero matches on a given run is normal — the feed is small and many days
have no environmental releases.

## Support This Work: Give It a Star

If you found this project helpful, consider starring
[biteSizedAQ](https://github.com/AarshBatra/biteSizedAQ).

## License and Reuse

Shared under the Creative Commons Attribution 4.0 International (CC BY
4.0) license, consistent with the rest of biteSizedAQ. PIB press release
content itself remains subject to the Government of India’s own
copyright/usage terms; this project only indexes titles and links.
