PIB India Environmental Press Releases Log - Tracker
================

## What this is

A public, auto-updating log of India-related press releases (default:
pollution / environment / climate) issued by the Press Information
Bureau (PIB), written to a public Google Sheet by a scheduled GitHub
Actions job.

Here is the link to the Google Sheet ([PIB India Environmental Press
Releases Log -
Tracker](https://docs.google.com/spreadsheets/d/17l3TV2HKd0WfQz5OvB-bbIqGohB4Cs3LulZtjMYD3tU/edit?gid=1737040458#gid=1737040458))
where you’ll find the PIB log (English ones only for now) with the
following information:

- **Date:** Date of Release

- **Potential Category:** Potential category (note this is just for
  quick reference, actual post may cover items beyond the category
  label).

- **Ministry:** Ministry that issued the PIB

- **Title:** Title of the Press Release

- **Link:** Link to the Press Release

- **PR ID:** Press Release unique ID

**There are 2 ways to make use of this repo:**

- Simply refer the [PIB India Environmental Press Releases Log Tracker
  Google
  Sheet](https://docs.google.com/spreadsheets/d/17l3TV2HKd0WfQz5OvB-bbIqGohB4Cs3LulZtjMYD3tU/edit?gid=1737040458#gid=1737040458).
  It’s fully and forever free and open access.

  - To understand how this works, read details below on the specifics of
    the pipeline that helps fill in the Google Sheet.

- **Copy this project and edit `config/keywords.yml` to track a
  different topic** of your own choosing and make your own Google Sheet
  tracker for it — the helper script (`R/pib_pollution_log.R` at the
  repo root) doesn’t need to change. Instructions are pasted below for
  those interested.

## How it works

1.  A GitHub Actions workflow
    (`.github/workflows/pib-pollution-log.yml`) runs `run_daily.R` every
    2 hours
2.  It pulls PIB’s “latest releases” RSS feed (English) — the ~20 most
    recent releases
3.  For each, it fetches the release’s own page to get date, ministry,
    and full body text
4.  Keywords from `config/keywords.yml` are matched against title AND
    body
5.  Matches are appended to the Google Sheet, deduped by PRID
6.  If a day has no matches, one `"No PIB"` placeholder row is written
    for that day (once, not once per run) so the log has no silent gaps

The log started accumulating history from **29th July 2026**; there is
no automated backfill for now (see below). The sheet updates every 2
hours by design but GH actions timer is not always exact so practically
speaking it updates every 2 to 4 hours.

It will continue to do this forever until stopped. The idea is to review
it every few weeks \> catch bugs if any \> see if keyword bank needs
updating \> update if needed and let it run.

## Keyword matching (three tiers)

Configured entirely in `config/keywords.yml` and ***focuses on catching
broad environmental topics*** and then assigning them a potential
category.

- **`keywords`** — strong terms, matched standalone. Case-insensitive,
  word-bounded (so `GRAP` never matches `demo'grap'hic`),
  hyphen-tolerant (`clean air` finds `clean-air`), and auto-plural
  (`emission` also matches `emissions`).
- **`contextual_keywords`** — vague words like `water`, `green`,
  `carbon` that fire ONLY when an `anchor` word appears within ~6 words.
  This catches `water pollution` and `green hydrogen` without the false
  positives those words cause alone (`water taxi`, `green channel`).
- **`anchors`** — the environmental words a contextual term must be
  near.
- Ignores omnibus /administrative items (PM speeches, ministerial
  reshuffles) that graze many topics but are never about the
  environment. See keywords.yml file for more details.

Matching runs against both the title and the body text, so releases with
uninformative headlines are still caught. Of course, given the wide net
it casts - you can expect some false positives. Those can be reported
via opening an issue and can be resolved in a later keyword bank update.

## PIB site quirks (learned the hard way — recommend to keep this in mind, if you plan to adapt this repo to your own setting)

PIB India has no public API (as of July 31, 2026), so this reads its RSS
feed. Non-obvious behaviours found by testing the live site:

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
  parameter has no effect) spanning roughly a day. Running every 2 hours
  ensures nothing scrolls off unseen between runs.

## No automated backfill (for now)

In its current state, the feed can’t reach the past, and PIB’s
month-by-month listing page (`allRel.aspx`) sits behind Akamai bot
protection: query parameters and form POSTs are ignored, and headless
browsers are blocked with “Access Denied”. A normal browser is not
blocked.

To seed history manually: open the listing page in a browser (English,
National, all ministries), pick a month, save the page (Ctrl+S →
“Webpage, HTML Only”), and parse the saved HTML locally. For most
purposes the daily log might be enough on its own.

In future, I might find ways to automate backfill.

## Automation Setup

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
is. Nothing in the R code changes (unless you want to make specific
changes that cater to your needs).

## How Local development looked in my case

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
have no environmental releases. Depending on what your topic is, this
might differ.

## Support This Work: Give It a Star

If you found this project helpful, consider starring
[biteSizedAQ](https://github.com/AarshBatra/biteSizedAQ).

## Issues

If you find any issues or would like to suggest any improvements, feel
free to write to me at bitesizedaq@gmail.com.

## License and Reuse

All content under **biteSizedAQ** is shared under the **Creative Commons
Attribution 4.0 International (CC BY 4.0) license**. You are welcome to
use this material in your reports or news stories—just remember to give
appropriate credit and include a link back to the original work.

Every effort is made to ensure that only original or appropriately
licensed material is shared. If any copyrighted content has been used
inadvertently, please note that this is unintentional, and I will
promptly address it upon notification.

PIB press release content itself remains subject to the Government of
India’s own copyright/usage terms; this project only indexes titles and
links.

Thank you for respecting these terms!
