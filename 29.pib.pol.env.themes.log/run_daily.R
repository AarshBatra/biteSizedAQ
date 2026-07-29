# 29.pib.pol.env.themes.log/run_daily.R
#
# Daily entrypoint, triggered by the GitHub Actions cron. Pulls the latest
# English press releases from PIB's RSS feed, fetches each one's detail
# page, matches keywords against BOTH title and body, and writes matches
# to the Google Sheet (or a "No PIB" placeholder row if nothing matched).
#
# Body scanning: the RSS feed only carries ~20 recent releases, so
# fetching every detail page is ~20 requests per run — cheap. Matching on
# body as well as title catches releases whose headline is uninformative
# (e.g. a release titled only "PRESS NOTE" that is about air quality).
#
# Re-seeding: there is no separate seed step. Every run fetches the
# current feed, filters, and appends whatever is new (deduped by PRID
# against what's already in the sheet). So if the sheet is emptied, the
# next run simply repopulates from the current feed and the cron carries
# on from there — no special first-run logic needed.
#
# Run from the REPO ROOT (biteSizedAQ/):
#   Rscript 29.pib.pol.env.themes.log/run_daily.R

library(here)
library(httr)
library(xml2)
library(rvest)
library(purrr)
library(dplyr)
library(stringr)
library(yaml)
library(tibble)
library(googlesheets4)

source(here("R", "pib_pollution_log.R"))

sheet_id <- Sys.getenv("SHEET_ID")
if (sheet_id == "") stop("SHEET_ID environment variable is not set.")

cfg <- load_config(here("29.pib.pol.env.themes.log", "config", "keywords.yml"))
sheets_auth()

releases <- fetch_latest_releases()

if (nrow(releases) == 0) {
  message("RSS feed returned no items — PIB may be down or the endpoint changed.")
  log_results(sheet_id, cfg$sheet_tab, Sys.Date(), releases[0, ])
  quit(save = "no")
}

# Fetch every release's detail page once: gives date, ministry, and body
# text. ~20 requests per run.
details <- map(releases$prid, fetch_release_detail)
releases$ministry <- map_chr(details, ~ .x$ministry %||% NA_character_)
parsed_dates      <- map_chr(details, ~ .x$date %||% NA_character_)
releases$date     <- ifelse(is.na(parsed_dates), as.character(Sys.Date()), parsed_dates)
releases$body     <- map_chr(details, ~ .x$body %||% "")

# Match keywords against title OR body. Titles are passed for the
# exclusion layer (omnibus releases are dropped regardless of body).
hit <- match_keywords(releases$title, cfg, title_text = releases$title) |
  match_keywords(releases$body,  cfg, title_text = releases$title)
matches <- releases[hit, ]

# Loose "potential category" label for each kept release.
if (nrow(matches) > 0) {
  matches$`potential category` <- categorize(matches$title, matches$body, cfg)
}

# Drop the body column before writing — it's only needed for matching.
matches$body <- NULL

log_results(sheet_id, cfg$sheet_tab, Sys.Date(), matches)
