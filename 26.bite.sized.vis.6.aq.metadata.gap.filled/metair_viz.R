# ═══════════════════════════════════════════════════════════════════════════════
#  METAIR — Two choropleth maps
#    Plot 1: share of stations officially type-classified by agencies
#    Plot 2: share of stations officially area-classified by agencies
#  Color: grey (0% agency) → deep teal (100% agency)
# ═══════════════════════════════════════════════════════════════════════════════

# ── Packages ──────────────────────────────────────────────────────────────────
pkgs <- c("tidyverse", "sf", "rnaturalearth", "rnaturalearthdata", "scales", "showtext", "ggtext")
for (p in pkgs) if (!requireNamespace(p, quietly = TRUE)) install.packages(p, repos = "https://cloud.r-project.org")

library(tidyverse)
library(sf)
library(rnaturalearth)
library(rnaturalearthdata)
library(scales)
library(showtext)
library(ggtext)

# ── Fonts ─────────────────────────────────────────────────────────────────────
font_add_google("IBM Plex Sans", "ibmplex")
showtext_auto()
showtext_opts(dpi = 300)

# ── Colors ────────────────────────────────────────────────────────────────────
col_ocean  <- "#FAFAFA"
col_nodata <- "#D9D9D9"  # standard grey — universal "no data" convention
col_border <- "white"
col_bg     <- "#FAFAFA"

# Light yellow (no/minimal official classification) → deep teal (fully agency-classified)
sequential_pal <- c(
  "#D8CC6E",  # 0%   — muted straw yellow  (fully model-estimated)
  "#BBDA88",  # ~12% — muted yellow-green
  "#AEDA94",  # ~25% — light green
  "#7EC48E",  # ~37% — green
  "#50AC87",  # ~50% — green-teal
  "#2E9480",  # ~62% — teal-green
  "#167B72",  # ~75% — teal
  "#086464",  # ~87% — dark teal
  "#00695C"   # 100% — deep teal (fully agency-classified)
)

# ── Data ──────────────────────────────────────────────────────────────────────
df <- read_csv("global_aq_mon_metadata/dataset/dataset_v_1.csv", show_col_types = FALSE)

make_summary <- function(data, flag_col) {
  data |>
    mutate(iso = str_to_upper(iso)) |>
    group_by(iso) |>
    summarise(
      n_total     = n(),
      n_labeled   = sum(.data[[flag_col]] == 1, na.rm = TRUE),
      pct_labeled = (n_labeled / n_total) * 100,
      .groups     = "drop"
    )
}

country_summary_type <- make_summary(df, "labeled_type")
country_summary_area <- make_summary(df, "labeled_area")

n_total_global <- nrow(df)

# Gap percentages computed fresh (not derived from pct_labeled)
pct_type_gap <- round(sum(df$labeled_type == 0, na.rm = TRUE) / n_total_global * 100)
pct_area_gap <- round(sum(df$labeled_area == 0, na.rm = TRUE) / n_total_global * 100)

# Country-level distribution: how many countries are fully yellow
# (pct_labeled == 0 → institutional agency recorded nothing, paper did all the work)
n_countries      <- n_distinct(df$iso)
n_yellow_type    <- sum(country_summary_type$pct_labeled == 0)
n_yellow_area    <- sum(country_summary_area$pct_labeled == 0)

fix_kosovo <- function(s) mutate(s, iso = if_else(iso == "XKK", "KOS", iso))
summary_type_fixed <- fix_kosovo(country_summary_type)
summary_area_fixed <- fix_kosovo(country_summary_area)

# ── World map base ────────────────────────────────────────────────────────────
world_base <- ne_countries(scale = "medium", returnclass = "sf")

world_type <- world_base |> left_join(summary_type_fixed, by = c("adm0_a3" = "iso"))
world_area <- world_base |> left_join(summary_area_fixed, by = c("adm0_a3" = "iso"))

# ── Annotation helpers ────────────────────────────────────────────────────────
robin_pt <- function(lon, lat) {
  p  <- st_as_sf(data.frame(lon = lon, lat = lat), coords = c("lon", "lat"), crs = 4326)
  co <- st_coordinates(st_transform(p, crs = "+proj=robin"))
  list(x = co[1, 1], y = co[1, 2])
}

edge_pt <- function(lx, ly, ax, ay, offset = 1.6e6) {
  dx <- ax - lx; dy <- ay - ly
  d  <- sqrt(dx^2 + dy^2)
  list(x = lx + dx / d * offset, y = ly + dy / d * offset)
}

get_pct <- function(summary, iso_code) {
  val <- summary |> filter(iso == iso_code) |> pull(pct_labeled)
  if (length(val) == 0 || is.na(val[1])) return("N/A")
  paste0(round(val[1]), "%")
}

eur_isos <- c("DEU", "FRA", "ITA", "ESP", "POL", "GBR", "NLD", "BEL", "AUT", "CHE")
get_eur_pct <- function(summary) {
  vals <- summary |> filter(iso %in% eur_isos) |> pull(pct_labeled)
  paste0("~", round(median(vals, na.rm = TRUE)), "%")
}

get_paper_pct <- function(summary, iso_code) {
  val <- summary |> filter(iso == iso_code) |> pull(pct_labeled)
  if (length(val) == 0 || is.na(val[1])) return("N/A")
  paste0(round(100 - val[1]), "%")
}

get_eur_paper_pct <- function(summary) {
  vals <- summary |> filter(iso %in% eur_isos) |> pull(pct_labeled)
  paste0("~", round(100 - median(vals, na.rm = TRUE)), "%")
}

# ── Annotation coordinates (shared across both plots) ─────────────────────────
ind_a  <- robin_pt(78,    22)
us_a   <- robin_pt(-100,  40)
za_a   <- robin_pt(25,   -30)
nga_a  <- robin_pt(8,      9)
eur_a  <- robin_pt(15,    50)
jp_a   <- robin_pt(138,   37)
can_a  <- robin_pt(-105,  60)
bra_a  <- robin_pt(-53,  -10)

ind_l  <- robin_pt(76,   -12)
us_l   <- robin_pt(-148,  17)
za_l   <- robin_pt(48,   -46)
nga_l  <- robin_pt(-15,   -7)
eur_l  <- robin_pt(-30,   51)
jp_l   <- robin_pt(172,   45)
can_l  <- robin_pt(-165,  46)
bra_l  <- robin_pt(-22,  -36)

ind_e  <- edge_pt(ind_l$x, ind_l$y, ind_a$x, ind_a$y, offset = 1.1e6)
us_e   <- edge_pt(us_l$x,  us_l$y,  us_a$x,  us_a$y)
za_e   <- edge_pt(za_l$x,  za_l$y,  za_a$x,  za_a$y)
nga_e  <- edge_pt(nga_l$x, nga_l$y, nga_a$x, nga_a$y)
eur_e  <- edge_pt(eur_l$x, eur_l$y, eur_a$x, eur_a$y)
jp_e   <- edge_pt(jp_l$x,  jp_l$y,  jp_a$x,  jp_a$y)
can_e  <- edge_pt(can_l$x, can_l$y, can_a$x, can_a$y)
bra_e  <- edge_pt(bra_l$x, bra_l$y, bra_a$x, bra_a$y)

# ── Shared caption ────────────────────────────────────────────────────────────
plot_caption <- paste0(
  "Data: METAIR dataset  ·  Renna et al. (2026)  ·  Scientific Data  ·  ",
  "doi.org/10.1038/s41597-026-06797-0  ·  Visual: github.com/AarshBatra/biteSizedAQ"
)

# ── Plot builder ──────────────────────────────────────────────────────────────
build_map <- function(world_sf, ann_labels, title, subtitle, filename) {

  p <- ggplot(world_sf) +
    geom_sf(aes(fill = pct_labeled), colour = col_border, linewidth = 0.12) +
    scale_fill_gradientn(
      colors   = sequential_pal,
      trans    = "sqrt",
      limits   = c(0, 100),
      breaks   = c(0, 10, 25, 50, 75, 100),
      labels   = paste0(c(0, 10, 25, 50, 75, 100), "%"),
      na.value = col_nodata,
      name     = "Share of stations officially classified by a government agency",
      guide    = guide_colorbar(
        barwidth       = unit(16, "cm"),
        barheight      = unit(0.55, "cm"),
        title.position = "top",
        title.hjust    = 0.5,
        ticks.colour   = "white",
        frame.colour   = NA
      )
    ) +
    # Leader lines
    annotate("segment", x=ind_e$x, y=ind_e$y, xend=ind_a$x, yend=ind_a$y, color="#888888", linewidth=0.28) +
    annotate("segment", x=us_e$x,  y=us_e$y,  xend=us_a$x,  yend=us_a$y,  color="#888888", linewidth=0.28) +
    annotate("segment", x=za_e$x,  y=za_e$y,  xend=za_a$x,  yend=za_a$y,  color="#888888", linewidth=0.28) +
    annotate("segment", x=nga_e$x, y=nga_e$y, xend=nga_a$x, yend=nga_a$y, color="#888888", linewidth=0.28) +
    annotate("segment", x=eur_e$x, y=eur_e$y, xend=eur_a$x, yend=eur_a$y, color="#888888", linewidth=0.28) +
    annotate("segment", x=jp_e$x,  y=jp_e$y,  xend=jp_a$x,  yend=jp_a$y,  color="#888888", linewidth=0.28) +
    annotate("segment", x=can_e$x, y=can_e$y, xend=can_a$x, yend=can_a$y, color="#888888", linewidth=0.28) +
    annotate("segment", x=bra_e$x, y=bra_e$y, xend=bra_a$x, yend=bra_a$y, color="#888888", linewidth=0.28) +
    # Labels
    annotate("label", x=ind_l$x, y=ind_l$y, label=ann_labels[["ind"]],
             size=2.55, family="ibmplex", fill=alpha("#FAFAFA",0.6),
             label.size=0, label.r=unit(5,"pt"), color="#111111", lineheight=1.3) +
    annotate("label", x=us_l$x,  y=us_l$y,  label=ann_labels[["us"]],
             size=2.55, family="ibmplex", fill=alpha("#FAFAFA",0.6),
             label.size=0, label.r=unit(5,"pt"), color="#111111", lineheight=1.3) +
    annotate("label", x=za_l$x,  y=za_l$y,  label=ann_labels[["za"]],
             size=2.55, family="ibmplex", fill=alpha("#FAFAFA",0.6),
             label.size=0, label.r=unit(5,"pt"), color="#111111", lineheight=1.3) +
    annotate("label", x=nga_l$x, y=nga_l$y, label=ann_labels[["nga"]],
             size=2.55, family="ibmplex", fill=alpha("#FAFAFA",0.6),
             label.size=0, label.r=unit(5,"pt"), color="#111111", lineheight=1.3) +
    annotate("label", x=eur_l$x, y=eur_l$y, label=ann_labels[["eur"]],
             size=2.55, family="ibmplex", fill=alpha("#FAFAFA",0.6),
             label.size=0, label.r=unit(5,"pt"), color="#111111", lineheight=1.3) +
    annotate("label", x=jp_l$x,  y=jp_l$y,  label=ann_labels[["jp"]],
             size=2.55, family="ibmplex", fill=alpha("#FAFAFA",0.6),
             label.size=0, label.r=unit(5,"pt"), color="#111111", lineheight=1.3) +
    annotate("label", x=can_l$x, y=can_l$y, label=ann_labels[["can"]],
             size=2.55, family="ibmplex", fill=alpha("#FAFAFA",0.6),
             label.size=0, label.r=unit(5,"pt"), color="#111111", lineheight=1.3) +
    annotate("label", x=bra_l$x, y=bra_l$y, label=ann_labels[["bra"]],
             size=2.55, family="ibmplex", fill=alpha("#FAFAFA",0.6),
             label.size=0, label.r=unit(5,"pt"), color="#111111", lineheight=1.3) +
    coord_sf(crs = "+proj=robin", expand = FALSE) +
    labs(title = title, subtitle = subtitle, caption = plot_caption) +
    theme_void(base_family = "ibmplex", base_size = 13) +
    theme(
      plot.background  = element_rect(fill = col_bg,    color = NA),
      panel.background = element_rect(fill = col_ocean, color = NA),
      plot.title = element_textbox_simple(
        face = "bold", size = 19, color = "#1A1A2E",
        margin = margin(b = 35), family = "ibmplex"
      ),
      plot.subtitle = element_textbox_simple(
        size = 9.5, color = "#52526A", lineheight = 1.55,
        margin = margin(b = 50), family = "ibmplex"
      ),
      plot.caption = element_text(
        size = 8.5, hjust = 0.5, color = "#777777",
        margin = margin(t = 10), family = "ibmplex"
      ),
      plot.margin       = margin(22, 22, 14, 22),
      legend.position   = "bottom",
      legend.title      = element_text(size = 9, color = "#444455", face = "bold", family = "ibmplex"),
      legend.text       = element_text(size = 8.5, color = "#666677", family = "ibmplex"),
      legend.margin     = margin(t = 22),
      legend.box.margin = margin(t = 0, b = 14)
    )

  ggsave(filename = filename, plot = p, width = 8.5, height = 8, dpi = 300, bg = col_bg)
  cat("Saved:", filename, "\n")
}

# ── Plot 1: labeled_type ──────────────────────────────────────────────────────
ann_type <- list(
  ind = paste0("India\n",        get_pct(summary_type_fixed, "IND"), " official\n", get_paper_pct(summary_type_fixed, "IND"), " by paper"),
  us  = paste0("USA\n",          get_pct(summary_type_fixed, "USA"), " official\n", get_paper_pct(summary_type_fixed, "USA"), " by paper"),
  za  = paste0("South Africa\n", get_pct(summary_type_fixed, "ZAF"), " official\n", get_paper_pct(summary_type_fixed, "ZAF"), " by paper"),
  nga = paste0("Nigeria\n",      get_pct(summary_type_fixed, "NGA"), " official\n", get_paper_pct(summary_type_fixed, "NGA"), " by paper"),
  eur = paste0("Most of Europe\n", get_eur_pct(summary_type_fixed), " official\n", get_eur_paper_pct(summary_type_fixed), " by paper"),
  jp  = paste0("Japan\n",        get_pct(summary_type_fixed, "JPN"), " official\n", get_paper_pct(summary_type_fixed, "JPN"), " by paper"),
  can = paste0("Canada\n",       get_pct(summary_type_fixed, "CAN"), " official\n", get_paper_pct(summary_type_fixed, "CAN"), " by paper"),
  bra = paste0("Brazil\n",       get_pct(summary_type_fixed, "BRA"), " official\n", get_paper_pct(summary_type_fixed, "BRA"), " by paper")
)

title_type <- paste0(
  pct_type_gap, "% of global PM stations had no official type label. This paper fixed that."
)

subtitle_type <- paste0(
  "A station's type — background or non-background — tells you what it is measuring. ",
  "Background stations capture the air most people breathe day-to-day; non-background stations sit near roads or industrial sites. ",
  "Each country is shaded by the share of its governmental  PM stations officially type-classified by an institutional agency such as a governmental air quality network. ",
  "**Deep teal means an institutional agency classified all of them; Dark yellow means this paper's model classified all of them — no institutional agency had recorded anything. ",
  "Countries with shades in between had a mix: some stations officially labeled, the rest filled in by the model.",
  "Of the ", n_countries, " countries in the dataset, ", n_yellow_type, " (", round(n_yellow_type / n_countries * 100), "%) had zero official type classifications — this paper's model did all the work.** ",
  "Each label shows official % and paper's %. Grey = no stations in this paper's compiled dataset."
)

build_map(
  world_sf   = world_type,
  ann_labels = ann_type,
  title      = title_type,
  subtitle   = subtitle_type,
  filename   = "metair_labeled_type.png"
)

# ── Plot 2: labeled_area ──────────────────────────────────────────────────────
ann_area <- list(
  ind = paste0("India\n",        get_pct(summary_area_fixed, "IND"), " official\n", get_paper_pct(summary_area_fixed, "IND"), " by paper"),
  us  = paste0("USA\n",          get_pct(summary_area_fixed, "USA"), " official\n", get_paper_pct(summary_area_fixed, "USA"), " by paper"),
  za  = paste0("South Africa\n", get_pct(summary_area_fixed, "ZAF"), " official\n", get_paper_pct(summary_area_fixed, "ZAF"), " by paper"),
  nga = paste0("Nigeria\n",      get_pct(summary_area_fixed, "NGA"), " official\n", get_paper_pct(summary_area_fixed, "NGA"), " by paper"),
  eur = paste0("Most of Europe\n", get_eur_pct(summary_area_fixed), " official\n", get_eur_paper_pct(summary_area_fixed), " by paper"),
  jp  = paste0("Japan\n",        get_pct(summary_area_fixed, "JPN"), " official\n", get_paper_pct(summary_area_fixed, "JPN"), " by paper"),
  can = paste0("Canada\n",       get_pct(summary_area_fixed, "CAN"), " official\n", get_paper_pct(summary_area_fixed, "CAN"), " by paper"),
  bra = paste0("Brazil\n",       get_pct(summary_area_fixed, "BRA"), " official\n", get_paper_pct(summary_area_fixed, "BRA"), " by paper")
)

title_area <- paste0(
  pct_area_gap, "% of global PM stations had no official area label. This paper fixed that."
)

subtitle_area <- paste0(
  "A station's area — urban or rural — describes the setting it monitors. ",
  "Urban stations represent air quality where most people live; rural stations capture cleaner background levels away from dense activity. ",
  "Each country is shaded by the share of its governmental  PM stations officially area-classified by an institutional agency such as a governmental air quality network. ",
  "**Deep teal means an institutional agency classified all of them; Dark yellow means this paper's model classified all of them — no institutional agency had recorded anything. ",
  "Countries with shades in between had a mix: some stations officially labeled, the rest filled in by the model.",
  "Of the ", n_countries, " countries in the dataset, ", n_yellow_area, " (", round(n_yellow_area / n_countries * 100), "%) had zero official area classifications — this paper's model did all the work.** ",
  "Each label shows official % and paper's %. Grey = no stations in this paper's compiled dataset."
)

build_map(
  world_sf   = world_area,
  ann_labels = ann_area,
  title      = title_area,
  subtitle   = subtitle_area,
  filename   = "metair_labeled_area.png"
)
