# R/pib_pollution_log.R
#
# Helper functions for the "29.pib.pol.env.themes.log" project.
# One file per project, per biteSizedAQ convention.
#
# Package conventions used here:
#   * Dependencies are declared via @importFrom (and DESCRIPTION Imports),
#     NOT library() calls — library() in a package R/ file is flagged by
#     R CMD check and has no effect once the package is installed.
#   * Functions carry @export so document() populates NAMESPACE.
#
# PIB QUIRKS — verified empirically against the live site. Do not "tidy"
# these away; each one was a real bug:
#   * Language is controlled by LOWERCASE `lang` (1 = English, 2 = Hindi)
#     and `reg` (3 = National). The capitalised `Lang`/`Regid` params that
#     PIB's own RSS listing page advertises are IGNORED and yield Hindi.
#   * Do NOT use a persistent httr handle/session. Establishing a session
#     causes PIB to pin the language to Hindi and override `lang=1`.
#     Every request here is a fresh, cookie-free GET on purpose.
#   * PIB issues SEPARATE PRIDs for the English and Hindi versions of the
#     same release. Staying on lang=1 keeps PRIDs stable for dedup.
#   * On a release page, the ministry sits on the first non-empty line,
#     ABOVE the headline. Its form varies: sometimes a short code
#     ("AYUSH"), sometimes the full name ("Ministry of Environment,
#     Forest and Climate Change"). Don't assume either.
#   * The date byline also varies in shape between releases:
#     "17 JUL 2026 10:22PM by PIB Delhi" vs
#     "Posted On:\r 23 JUL 2026 7:44PM by PIB Delhi". Match the date
#     stamp anywhere in the line, never anchored to its start.

PIB_BASE <- "https://pib.gov.in"

#' Default-if-missing helper
#'
#' @param a Value to test.
#' @param b Fallback used when `a` is NULL, zero-length, or NA.
#' @return `a`, or `b` if `a` is missing/empty.
#' @export
`%||%` <- function(a, b) {
  if (is.null(a) || length(a) == 0) return(b)
  if (length(a) == 1 && is.na(a)) return(b)
  a
}

#' Parse a PIB date string into an ISO date
#'
#' PIB renders dates like "17 JUL 2026" (uppercase month abbreviation).
#' Parsing that with `%b` depends on the system locale and fails on some
#' runners, so month names are mapped explicitly here.
#'
#' @param x A date string such as "17 JUL 2026 10:22PM by PIB Delhi".
#' @return An ISO date string ("2026-07-17"), or NA_character_ if unparseable.
#' @examples
#' parse_pib_date("17 JUL 2026 10:22PM by PIB Delhi")
#' @importFrom stringr str_match
#' @export
parse_pib_date <- function(x) {
  if (is.null(x) || length(x) == 0 || is.na(x)) return(NA_character_)
  m <- str_match(x, "^(\\d{1,2})\\s+([A-Za-z]{3,})\\s+(\\d{4})")
  if (is.na(m[1, 1])) return(NA_character_)
  months <- c(JAN = 1, FEB = 2, MAR = 3, APR = 4, MAY = 5, JUN = 6,
              JUL = 7, AUG = 8, SEP = 9, OCT = 10, NOV = 11, DEC = 12)
  mon <- months[toupper(substr(m[1, 3], 1, 3))]
  if (is.na(mon)) return(NA_character_)
  sprintf("%04d-%02d-%02d", as.integer(m[1, 4]), mon, as.integer(m[1, 2]))
}

# ---- Scraping ----------------------------------------------------------

#' Fetch PIB's latest press releases via RSS
#'
#' Returns the ~20 most recent releases across all ministries, in English.
#' Uses a fresh cookie-free GET with lowercase `lang`/`reg` params — see
#' the PIB QUIRKS note at the top of this file before changing either.
#'
#' @param lang Language: 1 = English (default), 2 = Hindi.
#' @param reg Region: 3 = National (default).
#' @return A tibble with `title`, `link`, `prid`. Empty tibble if the feed
#'   returns nothing.
#' @examples
#' \dontrun{
#' releases <- fetch_latest_releases()
#' }
#' @importFrom httr GET content stop_for_status
#' @importFrom xml2 read_xml xml_find_all xml_find_first xml_text
#' @importFrom tibble tibble
#' @importFrom dplyr mutate %>%
#' @importFrom stringr str_extract
#' @export
fetch_latest_releases <- function(lang = 1, reg = 3) {
  resp <- GET(
    url = paste0(PIB_BASE, "/RssMain.aspx"),
    query = list(ModId = 6, lang = lang, reg = reg)
  )
  stop_for_status(resp)

  doc <- read_xml(content(resp, as = "text", encoding = "UTF-8"))
  items <- xml_find_all(doc, ".//item")
  if (length(items) == 0) {
    return(tibble(title = character(), link = character(), prid = character()))
  }

  tibble(
    title = xml_text(xml_find_first(items, ".//title")),
    link  = xml_text(xml_find_first(items, ".//link"))
  ) %>%
    mutate(prid = str_extract(link, "(?<=PRID=)\\d+"))
}

#' Fetch a release's published date and ministry
#'
#' Hits the lightweight iframe content page for a single PRID. The title is
#' NOT taken from here — the RSS feed's title is authoritative and already
#' English.
#'
#' Ministry is read from the first non-empty line of the page, which is
#' where PIB puts the short ministry code (e.g. "AYUSH"). Date is parsed
#' from the byline (e.g. "17 JUL 2026 10:22PM by PIB Delhi") into ISO form.
#' Both are best-effort and may return NA; callers should fall back.
#'
#' @param prid Press release ID, from [fetch_latest_releases()].
#' @param lang Language: 1 = English (default).
#' @param reg Region: 3 = National (default).
#' @return A list with `date` (ISO string), `ministry`, and `body` (the
#'   release's full plain text), each possibly NA/empty.
#' @examples
#' \dontrun{
#' fetch_release_detail("2286000")
#' }
#' @importFrom httr GET content http_error
#' @importFrom rvest read_html html_text2
#' @importFrom stringr str_split str_trim str_detect str_c
#' @importFrom purrr discard
#' @importFrom dplyr %>%
#' @export
fetch_release_detail <- function(prid, lang = 1, reg = 3) {
  resp <- GET(
    url = paste0(PIB_BASE, "/PressReleaseIframePage.aspx"),
    query = list(PRID = prid, lang = lang, reg = reg)
  )
  if (http_error(resp)) {
    return(list(date = NA_character_, ministry = NA_character_, body = ""))
  }

  page <- read_html(content(resp, as = "text", encoding = "UTF-8"))
  lines <- str_split(html_text2(page), "\n")[[1]] %>%
    str_trim() %>%
    discard(~ .x == "")

  if (length(lines) == 0) {
    return(list(date = NA_character_, ministry = NA_character_, body = ""))
  }

  # The byline carries the date, but its shape varies between releases:
  #   "17 JUL 2026 10:22PM by PIB Delhi"            (bare)
  #   "Posted On:\r 23 JUL 2026 7:44PM by PIB Delhi" (prefixed)
  # So don't anchor to the start of the line. Prefer a line carrying a
  # byline marker; fall back to the first line containing a date stamp.
  stamp_re  <- "\\d{1,2}\\s+[A-Za-z]{3,}\\s+\\d{4}"
  byline    <- lines[str_detect(lines, "(?i)posted\\s*on|by\\s+PIB") &
                       str_detect(lines, stamp_re)][1]
  if (is.na(byline)) byline <- lines[str_detect(lines, stamp_re)][1]
  date_clean <- parse_pib_date(str_extract(byline, stamp_re))

  # Ministry sits on the first non-empty line, above the headline — either
  # a short code ("AYUSH") or a full name ("Ministry of Environment,
  # Forest and Climate Change"). Guard against pages that don't follow
  # that layout: anything this long is almost certainly body text.
  ministry <- lines[1]
  if (is.na(ministry) || nchar(ministry) > 120) ministry <- NA_character_

  list(date = date_clean %||% NA_character_,
       ministry = ministry %||% NA_character_,
       body = str_c(lines, collapse = " "))
}

#' Load keyword config
#'
#' @param path Path to the project's YAML config (see config/keywords.yml).
#' @return A list with `keywords` (lowercased), `ministries`, `sheet_tab`.
#' @examples
#' \dontrun{
#' cfg <- load_config(here::here("29.pib.pol.env.themes.log", "config", "keywords.yml"))
#' }
#' @importFrom yaml read_yaml
#' @export
load_config <- function(path) {
  cfg <- read_yaml(path)
  cfg$keywords <- tolower(cfg$keywords)
  if (!is.null(cfg$contextual_keywords)) {
    cfg$contextual_keywords <- tolower(cfg$contextual_keywords)
  }
  if (!is.null(cfg$anchors)) cfg$anchors <- tolower(cfg$anchors)
  if (!is.null(cfg$contextual_pairs)) {
    cfg$contextual_pairs <- lapply(cfg$contextual_pairs, function(p) {
      p$terms   <- tolower(p$terms %||% character())
      p$anchors <- tolower(p$anchors %||% character())
      p
    })
  }
  if (!is.null(cfg$categories)) {
    cfg$categories <- lapply(cfg$categories, function(cat) {
      cat$match <- tolower(cat$match %||% character())
      cat
    })
  }
  cfg
}

#' Escape regex metacharacters in a string
#'
#' Keywords from the config are user-supplied plain text (e.g. "PM2.5"),
#' so any regex metacharacters must be escaped before the keywords are
#' combined into a matching pattern.
#'
#' `perl = TRUE` is required. In POSIX bracket expressions (R's default
#' engine) a backslash is a literal character rather than an escape, so
#' the class below terminates early and the trailing `{}` is misread as
#' an interval quantifier.
#'
#' @param x Character vector to escape.
#' @return `x` with regex metacharacters backslash-escaped.
#' @examples
#' escape_regex("PM2.5")
#' @export
escape_regex <- function(x) {
  gsub("([.|()\\[\\]{}^$*+?\\\\])", "\\\\\\1", x, perl = TRUE)
}

#' Build the keyword-matching regex from a config
#'
#' Compiles the config's keyword vector into a single case-insensitive
#' pattern. Behaviours, all driven by real PIB output:
#' * Word-bounded, not plain substring — without this, short acronyms
#'   match inside unrelated words ("GRAP" hit "demoGRAPhic").
#' * A space in a keyword matches a space OR a hyphen/dash, because PIB
#'   hyphenates inconsistently ("ETHANOL-BLENDED" vs "Ethanol Blended").
#' * An optional trailing "s" is allowed, so a singular keyword also
#'   matches its plural: "emission" catches "emissions", "pollutant"
#'   catches "pollutants". This is a cheap recall win; it won't handle
#'   irregular plurals (add those explicitly) and may occasionally
#'   over-match, which is acceptable for a deliberately wide list.
#'
#' @param cfg Config list from [load_config()].
#' @return A single regex string, or `NA` if there are no keywords.
#' @examples
#' \dontrun{
#' keyword_pattern(load_config("config/keywords.yml"))
#' }
#' @importFrom stringr str_c
#' @export
keyword_pattern <- function(cfg) {
  if (length(cfg$keywords) == 0) return(NA_character_)
  sep <- "[[:space:]\u2010-\u2015-]+"
  kw  <- gsub(" ", sep, escape_regex(cfg$keywords), fixed = TRUE)
  # Optional trailing "s" for plurals, but only when the keyword ends in a
  # letter (so "PM2.5" or "E20" aren't given a nonsensical "s").
  kw  <- ifelse(grepl("[[:alpha:]]$", kw), paste0(kw, "s?"), kw)
  str_c("\\b(", str_c(kw, collapse = "|"), ")\\b")
}

#' Build a proximity regex for contextual keywords
#'
#' Some words are only meaningful near an environmental anchor: "water"
#' matters in "water pollution" but not "water taxi". This builds a regex
#' that matches a contextual word only when an anchor word appears within
#' `window` words on either side.
#'
#' @param words Character vector of contextual keywords.
#' @param anchors Character vector of anchor words.
#' @param window Max number of words allowed between the term and an
#'   anchor (default 6).
#' @return A single regex string, or `NA` if either input is empty.
#' @importFrom stringr str_c
#' @export
contextual_pattern <- function(words, anchors, window = 6) {
  if (length(words) == 0 || length(anchors) == 0) return(NA_character_)
  esc_words   <- escape_regex(tolower(words))
  esc_anchors <- escape_regex(tolower(anchors))
  w <- str_c("(?:", str_c(esc_words, collapse = "|"), ")")
  a <- str_c("(?:", str_c(esc_anchors, collapse = "|"), ")")
  gap <- sprintf("(?:\\W+\\w+){0,%d}\\W+", window)   # up to `window` words between
  # Match term-before-anchor OR anchor-before-term.
  str_c("\\b(?:", w, gap, a, "|", a, gap, w, ")\\b")
}

#' Test whether text matches any configured keyword
#'
#' Combines several match layers and one guarded exclusion layer:
#' * `cfg$keywords` — strong terms, matched standalone.
#' * `cfg$contextual_keywords` + `cfg$anchors` — vague terms (e.g.
#'   "water", "green") matched only when near an anchor. Kept for
#'   backward compatibility.
#' * `cfg$contextual_pairs` — a general list of \{terms, anchors\} groups.
#'   Each group's terms match only when near that group's anchors. This
#'   is how, e.g., health words ("asthma", "respiratory") are required to
#'   co-occur with a pollution word, so "childhood asthma from vehicular
#'   emissions" matches but "new asthma drug approved" does not.
#' * `cfg$exclude_title_patterns` — structural non-topical titles dropped
#'   UNLESS the title itself carries a strong keyword (guard).
#'
#' Missing config fields are skipped, so older configs keep working.
#'
#' @param text Character vector to test (title or body).
#' @param cfg Config list from [load_config()].
#' @param title_text Optional titles, same length as `text`, for the
#'   exclusion layer and its strong-keyword guard.
#' @return Logical vector, same length as `text`.
#' @examples
#' \dontrun{
#' match_keywords(releases$body, cfg, title_text = releases$title)
#' }
#' @importFrom stringr str_detect str_to_lower
#' @export
match_keywords <- function(text, cfg, title_text = NULL) {
  text[is.na(text)] <- ""
  lc <- str_to_lower(text)
  hit <- rep(FALSE, length(text))

  strong <- keyword_pattern(cfg)
  if (!is.na(strong)) hit <- hit | str_detect(lc, strong)

  # Legacy single contextual list (contextual_keywords + anchors).
  if (length(cfg$contextual_keywords) > 0 && length(cfg$anchors) > 0) {
    ctx <- contextual_pattern(cfg$contextual_keywords, cfg$anchors)
    if (!is.na(ctx)) hit <- hit | str_detect(lc, ctx)
  }

  # General named pairs: each has its own terms + anchors.
  if (length(cfg$contextual_pairs) > 0) {
    for (pair in cfg$contextual_pairs) {
      cp <- contextual_pattern(pair$terms, pair$anchors)
      if (!is.na(cp)) hit <- hit | str_detect(lc, cp)
    }
  }

  # Guarded exclusion.
  if (!is.null(title_text) && length(cfg$exclude_title_patterns) > 0) {
    tt <- str_to_lower(title_text); tt[is.na(tt)] <- ""
    excluded <- rep(FALSE, length(tt))
    for (p in cfg$exclude_title_patterns) {
      excluded <- excluded | str_detect(tt, str_to_lower(p))
    }
    title_strong <- if (!is.na(strong)) str_detect(tt, strong) else rep(FALSE, length(tt))
    hit <- hit & !(excluded & !title_strong)
  }

  hit[is.na(hit)] <- FALSE
  hit
}

#' Assign a loose "potential category" label to each release
#'
#' For each release, walks `cfg$categories` in order and returns the name
#' of the FIRST category whose `match` words appear in the title or body
#' (same matching rules as elsewhere: case-insensitive, word-bounded,
#' hyphen-tolerant, auto-plural). Anything matching no category gets the
#' fallback category (the one with an empty `match` list, e.g.
#' "Other env/pollution").
#'
#' This is a rough guide for browsing, not a hard classification — hence
#' the sheet column is named "potential category".
#'
#' @param title Character vector of titles.
#' @param body Character vector of bodies, same length as `title`.
#' @param cfg Config list from [load_config()], with a `categories` block.
#' @return Character vector of category names, same length as `title`.
#' @examples
#' \dontrun{
#' categorize(releases$title, releases$body, cfg)
#' }
#' @importFrom stringr str_detect str_to_lower
#' @export
categorize <- function(title, body, cfg) {
  n <- length(title)
  if (length(cfg$categories) == 0) return(rep(NA_character_, n))

  title[is.na(title)] <- ""; body[is.na(body)] <- ""
  txt <- str_to_lower(paste(title, body))
  out <- rep(NA_character_, n)

  for (cat in cfg$categories) {
    if (length(cat$match) == 0) next          # fallback category: skip matching
    pat <- keyword_pattern(list(keywords = cat$match))
    if (is.na(pat)) next
    take <- is.na(out) & str_detect(txt, pat)
    out[take] <- cat$name
  }

  # Fallback = the category with an empty match list, else the last one.
  empties <- Filter(function(c) length(c$match) == 0, cfg$categories)
  fallback <- if (length(empties) > 0) empties[[length(empties)]]$name
  else cfg$categories[[length(cfg$categories)]]$name

  out[is.na(out)] <- fallback
  out
}

#' Filter releases by keyword match on title
#'
#' Convenience wrapper over [match_keywords()] for the title column. Rows
#' with NA titles are dropped first. For title+body matching, call
#' [match_keywords()] directly on each field (see `run_daily.R`).
#'
#' @param releases Tibble with a `title` column.
#' @param cfg Config list from [load_config()].
#' @return Filtered tibble.
#' @examples
#' \dontrun{
#' filter_by_keywords(releases, cfg)
#' }
#' @export
filter_by_keywords <- function(releases, cfg) {
  if (nrow(releases) == 0) return(releases)
  releases <- releases[!is.na(releases$title), ]
  if (nrow(releases) == 0) return(releases)
  releases[match_keywords(releases$title, cfg), ]
}

# ---- Google Sheets I/O ---------------------------------------------------

#' Authenticate to Google Sheets with a service account key
#'
#' @param key_path Path to the JSON key. Defaults to the GCP_SA_KEY_PATH
#'   env var, or "sa_key.json".
#' @return Invisibly, the result of [googlesheets4::gs4_auth()].
#' @examples
#' \dontrun{
#' sheets_auth()
#' }
#' @importFrom googlesheets4 gs4_auth
#' @export
sheets_auth <- function(key_path = Sys.getenv("GCP_SA_KEY_PATH", "sa_key.json")) {
  gs4_auth(path = key_path)
}

#' Get PRIDs already present in the sheet
#'
#' Returns an empty vector if the tab doesn't exist yet (normal on a
#' first run). If the tab exists but has no `prid` column, that's a
#' malformed sheet — usually a header row that never got written — and
#' it warns rather than failing silently, because the consequence is
#' that deduplication stops working and every run appends duplicates.
#'
#' @param sheet_id Google Sheet ID.
#' @param tab Worksheet name.
#' @return Character vector of logged PRIDs; empty if none/tab missing.
#' @examples
#' \dontrun{
#' get_logged_prids("sheet-id", "Log")
#' }
#' @importFrom googlesheets4 read_sheet
#' @export
get_logged_prids <- function(sheet_id, tab) {
  existing <- tryCatch(read_sheet(sheet_id, sheet = tab, col_types = "c"),
                       error = function(e) NULL)
  if (is.null(existing)) return(character())
  if (nrow(existing) == 0 && !"prid" %in% names(existing)) return(character())
  if (!"prid" %in% names(existing)) {
    warning("Sheet tab '", tab, "' has no 'prid' column — deduplication is ",
            "disabled and rows may be duplicated. The header row is probably ",
            "missing; delete the tab and re-run to recreate it.", call. = FALSE)
    return(character())
  }
  existing$prid
}

#' Ensure the target tab exists AND has a header row
#'
#' Writes the header via [googlesheets4::sheet_write()] (which writes
#' column names for an empty tibble, unlike `sheet_append()`) in two
#' cases: the tab doesn't exist, or it exists but is empty. The second
#' case matters because a user who creates the tab by hand leaves it
#' headerless — and without a `prid` header, deduplication silently
#' breaks. Checking for emptiness rather than mere existence covers both.
#'
#' @param sheet_id Google Sheet ID.
#' @param tab Worksheet name.
#' @return Invisibly NULL.
#' @examples
#' \dontrun{
#' ensure_sheet_tab("sheet-id", "Log")
#' }
#' @importFrom googlesheets4 sheet_names sheet_add sheet_write read_sheet
#' @importFrom tibble tibble
#' @export
ensure_sheet_tab <- function(sheet_id, tab) {
  header <- tibble(
    date = character(), `potential category` = character(),
    ministry = character(), title = character(),
    link = character(), prid = character()
  )

  if (!tab %in% sheet_names(sheet_id)) {
    sheet_add(sheet_id, sheet = tab)
    sheet_write(header, ss = sheet_id, sheet = tab)
    return(invisible(NULL))
  }

  # Tab exists — write the header only if it's empty (e.g. a hand-created
  # tab), so we never clobber existing logged data.
  existing <- tryCatch(read_sheet(sheet_id, sheet = tab, col_types = "c"),
                       error = function(e) NULL)
  if (is.null(existing) || nrow(existing) == 0) {
    sheet_write(header, ss = sheet_id, sheet = tab)
  }
  invisible(NULL)
}

#' Append matches to the sheet, or a "No PIB" placeholder
#'
#' Dedupes real releases against PRIDs already logged. The placeholder
#' logic is day-aware, which matters when the job runs several times a
#' day (e.g. every 4 hours):
#' * A `"No PIB"` row is written at most ONCE per day — later empty runs
#'   the same day do nothing, so a quiet day leaves one placeholder, not
#'   one per run.
#' * If a later run the same day finds a real match, any `"No PIB"` row
#'   already written for today is removed first, so the day isn't
#'   simultaneously marked empty and non-empty.
#'
#' @param sheet_id Google Sheet ID.
#' @param tab Worksheet name.
#' @param run_date Date of this run (Date or character).
#' @param matches Tibble with `date`, `ministry`, `title`, `link`, `prid`.
#' @return Invisibly NULL; called for its side effect.
#' @examples
#' \dontrun{
#' log_results("sheet-id", "Log", Sys.Date(), matches)
#' }
#' @importFrom googlesheets4 sheet_append read_sheet range_write
#' @importFrom tibble tibble
#' @export
log_results <- function(sheet_id, tab, run_date, matches) {
  ensure_sheet_tab(sheet_id, tab)
  today <- as.character(run_date)

  existing <- tryCatch(read_sheet(sheet_id, sheet = tab, col_types = "c"),
                       error = function(e) NULL)
  already_logged <- if (!is.null(existing) && "prid" %in% names(existing)) {
    existing$prid
  } else character()

  # --- No matches this run ---
  if (nrow(matches) == 0) {
    # Write a placeholder only if today has no row at all yet.
    todays_rows <- if (!is.null(existing) && "date" %in% names(existing)) {
      sum(existing$date == today, na.rm = TRUE)
    } else 0
    if (todays_rows > 0) {
      message("No new matches for ", today, " (today already has ",
              todays_rows, " row(s)); nothing written.")
      return(invisible(NULL))
    }
    sheet_append(sheet_id, tibble(
      date = today, `potential category` = "", ministry = "No PIB",
      title = "", link = "", prid = ""
    ), sheet = tab)
    message("No matching releases for ", today, " — logged placeholder row.")
    return(invisible(NULL))
  }

  # --- Have matches: drop any not already logged ---
  new_rows <- matches[!matches$prid %in% already_logged, ]
  if (nrow(new_rows) == 0) {
    message("All matched releases for ", today, " were already logged.")
    return(invisible(NULL))
  }

  # If today has a "No PIB" placeholder from an earlier run, remove it —
  # the day now has real content. (Rewrites the whole tab, which is fine
  # at this data scale.)
  if (!is.null(existing) &&
      any(existing$date == today & existing$ministry == "No PIB", na.rm = TRUE)) {
    kept <- existing[!(existing$date == today & existing$ministry == "No PIB"), ]
    range_write(sheet_id, data = kept, sheet = tab, range = "A1", reformat = FALSE)
    message("Cleared stale 'No PIB' placeholder for ", today, ".")
  }

  sheet_append(sheet_id, tibble(
    date                 = as.character(new_rows$date),
    `potential category` = as.character(new_rows$`potential category`),
    ministry             = as.character(new_rows$ministry),
    title                = as.character(new_rows$title),
    link                 = as.character(new_rows$link),
    prid                 = as.character(new_rows$prid)
  ), sheet = tab)
  message("Logged ", nrow(new_rows), " new release(s) for ", today, ".")
  invisible(NULL)
}
