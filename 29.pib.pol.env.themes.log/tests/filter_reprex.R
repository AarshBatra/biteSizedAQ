# 29.pib.pol.env.themes.log/tests/filter_reprex.R
#
# A labelled test harness for the keyword filter. Each case has a title, a
# short body, and `expected` (TRUE = should be logged, FALSE = should not).
# Run the whole file to get a pass/fail table and an accuracy summary.
#
# Use it to tune config/keywords.yml: change the config, re-run, watch the
# numbers. Cases marked "borderline" in `note` are judgement calls — decide
# per your own scope and flip their `expected` to match your intent.
#
#   Rscript 29.pib.pol.env.themes.log/tests/filter_reprex.R
# or, interactively:
#   source(here::here("29.pib.pol.env.themes.log","tests","filter_reprex.R"))

library(here)
library(tibble)
source(here("R", "pib_pollution_log.R"))

cfg <- load_config(here("29.pib.pol.env.themes.log", "config", "keywords.yml"))

cases <- tribble(
  ~expected, ~note,          ~title, ~body,

  # ---- Clear TRUE: core pollution, should always match ----
  TRUE,  "core",   "CAQM invokes GRAP Stage III as Delhi AQI turns severe",
  "The Commission for Air Quality Management directed agencies to enforce dust control as PM2.5 levels spiked.",
  TRUE,  "core",   "CPCB flags 12 industrial units for effluent violations",
  "The Central Pollution Control Board found untreated effluent discharge into the river.",
  TRUE,  "core",   "National Clean Air Programme review meeting held",
  "Cities reported progress on reducing particulate matter under NCAP.",
  TRUE,  "core",   "Ban on single-use plastic takes effect from October",
  "The environment ministry notified rules phasing out identified single-use plastic items.",
  TRUE,  "core",   "Stubble burning cases rise sharply across Punjab",
  "Satellite data shows a surge in paddy straw fires contributing to smog over the capital.",
  TRUE,  "core",   "New emission norms notified for thermal power plants",
  "Coal-fired stations must install flue gas desulphurisation units to cut sulphur dioxide.",

  # ---- TRUE via body only (uninformative title) ----
  TRUE,  "body",   "PRESS NOTE",
  "The government reviewed ambient air quality monitoring data showing elevated ozone and nitrogen dioxide.",
  TRUE,  "body",   "PARLIAMENT QUESTION: URBAN INFRASTRUCTURE",
  "In reply, the minister detailed steps to curb vehicular emissions and expand electric vehicle charging.",

  # ---- TRUE via contextual (vague word NEAR anchor) ----
  TRUE,  "context","State launches river cleaning drive",
  "The programme targets severe water pollution and industrial contamination along the stretch.",
  TRUE,  "context","Green push in new industrial policy",
  "Incentives focus on clean energy adoption and lower carbon emissions.",

  # ---- Clear FALSE: unrelated, should never match ----
  FALSE, "unrelated","Prime Minister addresses World Junior Squash Championship",
  "The PM congratulated the team on a historic win at the tournament.",
  FALSE, "unrelated","eCourts Phase III implemented across district courts",
  "The judiciary expanded e-filing to reduce case pendency nationwide.",
  FALSE, "unrelated","Naval ship departs Boston on goodwill visit",
  "INS Sudarshini continued its overseas deployment as part of a training cruise.",
  FALSE, "unrelated","ECI revises electoral rolls in phases",
  "Multiple safeguards protect eligible voters during the special intensive revision.",

  # ---- FALSE: contextual word present but NO anchor nearby ----
  FALSE, "context-neg","Bharat Taxi water service launched in Jaipur",
  "The chief minister flagged off a fleet offering drinking water to passengers.",
  FALSE, "context-neg","Green channel cleared at airport customs",
  "Passengers used the green channel for faster baggage clearance.",
  FALSE, "context-neg","Forest lodge tourism promoted in the state",
  "New eco-tourism cabins near the forest aim to boost local livelihoods.",

  # ---- BORDERLINE: decide per your scope, then set expected ----
  TRUE,  "borderline","Cabinet approves National Green Hydrogen Mission outlay",
  "The scheme supports green hydrogen production and energy transition.",
  FALSE, "borderline","Minister takes charge of Ministry, lists past portfolios",
  "The minister previously held renewable energy and steel portfolios.",
  FALSE, "borderline","English rendering of PM's Mann Ki Baat address",
  "The PM touched on clean air, plastic waste, water conservation, sports, and education.",
  TRUE,  "borderline","Rajnandgaon readies to Catch the Rain this monsoon",
  "The district scaled up water conservation under Mission Jal Shakti.",

  # ---- EXCLUSION GUARD: admin/omnibus phrasing BUT genuinely on-topic ----
  # These share the excluded phrasing ("takes charge", "Mann Ki Baat") yet
  # carry a real topic keyword IN THE TITLE, so must survive exclusion.
  TRUE,  "guard",    "New Environment Secretary takes charge, prioritises air pollution control",
  "The officer assumed charge and outlined the agenda.",
  TRUE,  "guard",    "Minister assumes charge, vows action on stubble burning",
  "The minister listed priorities after taking over the portfolio.",
  TRUE,  "guard",    "PM's Mann Ki Baat focuses on National Clean Air Programme",
  "The address centred on NCAP and city-level particulate reduction.",

  # ---- HEALTH x POLLUTION: health word counts ONLY near a pollution word ----
  TRUE,  "health+",  "Study links childhood asthma to vehicular emissions",
  "Researchers found higher respiratory illness where PM2.5 exposure was greatest.",
  TRUE,  "health+",  "Report estimates disease burden from air pollution in cities",
  "Premature deaths and hospitalisation rose with particulate levels.",
  TRUE,  "health+",  "Study warns of rising heat-related mortality under climate change",
  "Premature deaths from extreme heat are projected to climb in Indian cities.",
  FALSE, "health-",  "New asthma inhaler approved by drug regulator",
  "The medicine improves treatment for chronic respiratory patients.",
  FALSE, "health-",  "Public health campaign on diabetes awareness launched",
  "The drive targets lifestyle disease and morbidity in rural areas.",
  FALSE, "health-",  "Alignment of Academics with Employment Opportunities",
  "Programmes give students direct industrial exposure and vocational training in various sectors.",

  # ---- ACRONYM COLLISIONS: must NOT match common-word lookalikes ----
  FALSE, "acronym-", "Young scientist rises to fame after national award",
  "The researcher's work brought fame and recognition in the field.",
  FALSE, "acronym-", "Bharat NCAP awards five-star crash safety rating to new SUV",
  "The New Car Assessment Programme tested the vehicle for occupant protection.",

  # ---- WATER SCHEMES: name alone is NOT pollution, needs a quality anchor ----
  FALSE, "water-scheme","PM lauds work of Viksit Vibrant Village Programme participants",
  "Villages advanced under Jal Jeevan Mission with new tap water connections.",
  FALSE, "water-scheme","Har Ghar Jal milestone reached in the state",
  "The Jal Shakti department reported piped water supply to every household.",
  TRUE,  "water-scheme","Jal Shakti Ministry acts on groundwater contamination",
  "The programme addresses arsenic and fluoride pollution in drinking water sources.",
  TRUE,  "water-scheme","Catch the Rain drive tackles polluted urban water bodies",
  "The campaign includes cleaning sewage-contaminated ponds and lakes.",

  # ---- PHENOMENA: vivid problem-word near a water/air/land anchor ----
  TRUE,  "phenom+",  "Toxic froth returns to the Yamuna ahead of festival",
  "Thick foam covered the river surface as pollution levels rose.",
  TRUE,  "phenom+",  "Mass fish kill reported in Bellandur lake",
  "Residents complained of stench as dead fish surfaced in the lake.",
  FALSE, "phenom-",  "Cricket team's batting collapse in the final",
  "A dramatic foam party followed the celebrations at the stadium.",

  # ---- ENFORCEMENT: action language near a source ----
  TRUE,  "enforce+", "NGT imposes environmental compensation on tannery cluster",
  "The industrial units faced a closure notice for effluent violations.",
  TRUE,  "enforce+", "CPCB issues show-cause to polluting factories",
  "Several plants were sealed for hazardous waste discharge.",
  FALSE, "enforce-", "Bank imposes penalty on defaulting borrowers",
  "The lender issued show-cause notices over loan non-compliance.",

  # ---- EXCEEDANCE: limit language near a pollution anchor ----
  TRUE,  "exceed+",  "City AQI exceeds permissible limits for third day",
  "PM2.5 stayed in the severe category across monitoring stations.",
  TRUE,  "exceed+",  "Effluent samples breach standards near industrial zone",
  "Contamination was found above permissible limits in the water quality tests.",
  FALSE, "exceed-",  "Budget deficit exceeds permissible limits set by board",
  "The committee flagged non-compliance with fiscal targets.",

  # ---- COLLISION GUARDS: innocent everyday words that must NOT match ----
  FALSE, "collision", "Foam mattress industry seeks lower GST rate",
  "Manufacturers said foam and PU products face high taxation.",
  FALSE, "collision", "Traffic choked on city roads during festival rush",
  "Commuters faced clogged intersections and long delays.",
  FALSE, "collision", "Sealed bids invited for factory equipment tender",
  "The industrial procurement notice sought sealed financial bids.",
  FALSE, "collision", "Skilling programme gives students industrial exposure",
  "Vocational training offers direct exposure to factory settings."
)

run_reprex <- function(cases, cfg) {
  hit <- match_keywords(cases$title, cfg, title_text = cases$title) |
    match_keywords(cases$body,  cfg, title_text = cases$title)
  out <- cases
  out$matched <- hit
  out$ok <- hit == cases$expected
  out$category <- ifelse(hit, categorize(cases$title, cases$body, cfg), "")
  print(out[, c("ok", "expected", "matched", "category", "title")], n = nrow(out))

  cat("\n--- summary ---\n")
  cat("cases:      ", nrow(out), "\n")
  cat("correct:    ", sum(out$ok), "/", nrow(out),
      sprintf(" (%.0f%%)\n", 100 * mean(out$ok)))
  fp <- out[!out$expected & out$matched, ]
  fn <- out[ out$expected & !out$matched, ]
  cat("false positives (matched but shouldn't):", nrow(fp), "\n")
  if (nrow(fp)) cat("  -", paste(substr(fp$title, 1, 50), collapse = "\n  - "), "\n")
  cat("false negatives (missed but should match):", nrow(fn), "\n")
  if (nrow(fn)) cat("  -", paste(substr(fn$title, 1, 50), collapse = "\n  - "), "\n")
  invisible(out)
}

run_reprex(cases, cfg)
