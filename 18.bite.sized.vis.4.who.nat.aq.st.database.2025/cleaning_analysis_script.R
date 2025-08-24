# Load required libraries
library(dplyr)
library(ggplot2)
library(rnaturalearth)
library(rnaturalearthdata)
library(sf)
library(viridis)
library(patchwork)  # For combining plots
library(scales)
library(here)
library(tidyr)

# Load raw data
df <- read.csv(paste0(here(), "/18.bite.sized.vis.4.who.nat.aq.st.database.2025/raw.data.csv"), stringsAsFactors = FALSE) %>%
  as_tibble()

# Step 1: Calculate pollutant count per country
# First, get all unique countries to ensure none are excluded
all_countries <- df %>%
  distinct(country)

pollutant_counts <- df %>%
  # Create a flag for whether each row has a valid standard
  mutate(has_valid_standard = !is.na(aqs_numeric) & aqs_numeric != "NA") %>%
  # Group by country and pollutant to check if ANY row has a valid standard
  group_by(country, pollutant_name) %>%
  summarise(pollutant_has_standard = any(has_valid_standard), .groups = 'drop') %>%
  # Count pollutants with standards per country
  group_by(country) %>%
  summarise(pollutant_count = sum(pollutant_has_standard), .groups = 'drop')
# # Ensure all countries are included, even those with 0 standards
# right_join(all_countries, by = "country") %>%
# # Replace NA counts with 0 for countries with no standards
# mutate(pollutant_count = coalesce(pollutant_count, 0))

# Step 2: Load world map data
world <- ne_countries(scale = "medium", returnclass = "sf")

# Step 3: Country name mapping (adjust based on your data)
country_mapping <- c(
  # Major country name differences
  "Bolivia (Plurinational State of)" = "Bolivia",
  "Bosnia and Herzegovina" = "Bosnia and Herz.",
  "British Indian Ocean Territory" = "Br. Indian Ocean Ter.",
  "British Virgin Islands" = "British Virgin Is.",
  "Brunei Darussalam" = "Brunei",
  "Cabo Verde" = "Cape Verde",
  "Central African Republic" = "Central African Rep.",
  "China, Hong Kong SAR" = "Hong Kong",
  "China, Macao SAR" = "Macao",
  "Cook Islands" = "Cook Is.",
  "Czechia" = "Czech Rep.",
  "Democratic People's Republic of Korea" = "Dem. Rep. Korea",
  "Democratic Republic of the Congo" = "Dem. Rep. Congo",
  "Dominican Republic" = "Dominican Rep.",
  "Equatorial Guinea" = "Eq. Guinea",
  "Eswatini" = "Swaziland",
  "Falkland Islands (Malvinas)" = "Falkland Is.",
  "Faroe Islands" = "Faeroe Is.",
  "French Polynesia" = "Fr. Polynesia",
  "French Southern Territories" = "Fr. S. Antarctic Lands",
  "Heard Island and McDonald Islands" = "Heard I. and McDonald Is.",
  "Holy See" = "Vatican",
  "Iran (Islamic Republic of)" = "Iran",
  "Lao People's Democratic Republic" = "Lao PDR",
  "Marshall Islands" = "Marshall Is.",
  "Micronesia (Federated States of)" = "Micronesia",
  "Netherlands (Kingdom of the)" = "Netherlands",
  "North Macedonia" = "Macedonia",
  "Northern Mariana Islands" = "N. Mariana Is.",
  "occupied Palestinian territory, including east Jerusalem" = "Palestine",
  "Pitcairn" = "Pitcairn Is.",
  "Republic of Korea" = "Korea",
  "Republic of Moldova" = "Moldova",
  "Russian Federation" = "Russia",
  "Saint Barthélemy" = "St-Barthélemy",
  "Saint Kitts and Nevis" = "St. Kitts and Nevis",
  "Saint Martin (French part)" = "St-Martin",
  "Saint Pierre and Miquelon" = "St. Pierre and Miquelon",
  "Saint Vincent and the Grenadines" = "St. Vin. and Gren.",
  "Sao Tome and Principe" = "São Tomé and Principe",
  "Sint Maarten (Dutch part)" = "Sint Maarten",
  "Solomon Islands" = "Solomon Is.",
  "South Georgia and the South Sandwich Islands" = "S. Geo. and S. Sandw. Is.",
  "South Sudan" = "S. Sudan",
  "Syrian Arab Republic" = "Syria",
  "Taiwan, China" = "Taiwan",
  "Türkiye" = "Turkey",
  "Turks and Caicos Islands" = "Turks and Caicos Is.",
  "United Kingdom of Great Britain and Northern Ireland" = "United Kingdom",
  "United Republic of Tanzania" = "Tanzania",
  "United States of America" = "United States",
  "United States Virgin Islands" = "U.S. Virgin Is.",
  "Venezuela (Bolivarian Republic of)" = "Venezuela",
  "Viet Nam" = "Vietnam",
  "Wallis and Futuna" = "Wallis and Futuna Is.",
  "Western Sahara" = "W. Sahara",
  "Åland Islands" = "Aland",
  # Abbreviated country names
  "Antigua and Barbuda" = "Antigua and Barb.",
  "Cayman Islands" = "Cayman Is."
)

pollutant_counts$country_mapped <- ifelse(
  pollutant_counts$country %in% names(country_mapping),
  country_mapping[pollutant_counts$country],
  pollutant_counts$country
)

# Step 4: Join data with world map
world_data <- world %>%
  right_join(pollutant_counts, by = c("name" = "country_mapped"))

world_data$pollutant_count[is.na(world_data$pollutant_count)] <- 0


#### plot cleaned data

# Enhanced color palette for air quality theme
air_quality_colors <- c(
  "0" = "#e04038",  # Red (0 standards - poor regulatory coverage)
  "1" = "#f46d43",  # Orange-red (1 standard)
  "2" = "#fdae61",  # Orange (2 standards)
  "3" = "#fee08b",  # Yellow (3 standards)
  "4" = "#d9ef8b",  # Light green (4 standards)
  "5" = "#a6d96a",  # Green (5 standards)
  "6" = "#66bd63"   # Dark green (6 standards - excellent coverage)
)

# Dark theme color scheme that harmonizes with the air quality palette
bg_primary <- "#1e2329"      # Dark charcoal background
bg_secondary <- "#2a3038"    # Slightly lighter charcoal
text_primary <- "#e8f5e8"    # Light mint green (high contrast on dark)
text_secondary <- "#c8e6c9"  # Medium mint green
text_tertiary <- "#a5d6a7"   # Softer mint green
accent_color <- "#4a5568"    # Blue-gray accent

# 1. Create the map plot
map_plot <- ggplot(world_data, aes(fill = factor(pollutant_count))) +
  geom_sf(color = "#ffffff", linewidth = 0.1) +
  scale_fill_manual(
    values = air_quality_colors,
    name = "Number of Pollutants with Established AQ Standards",
    labels = c("Zero", "One", "Two", "Three",
               "Four", "Five", "Six"),
    guide = guide_legend(
      title.position = "top",
      title.hjust = 0.5,
      nrow = 1,
      override.aes = list(color = "white", linewidth = 0.3),
      keywidth = unit(2.4, "cm"),
      keyheight = unit(0.8, "cm"),
      label.position = "bottom",
      label.hjust = 0.5,
      byrow = TRUE
    )
  ) +
  theme_void() +
  theme(
    legend.position = "bottom",
    legend.direction = "horizontal",
    legend.title = element_text(
      size = 17,  # Increased from 15 to 17
      face = "bold",
      family = "Arial",
      color = text_primary
    ),
    legend.text = element_text(
      size = 13,  # Increased from 11 to 13
      family = "Arial",
      color = text_secondary,
      margin = margin(t = 8)
    ),
    legend.margin = margin(t = 20, b = 15),
    legend.box.margin = margin(t = 15),
    plot.margin = margin(0, 5, 5, 5),  # Reduced side margins to allow map to expand horizontally
    panel.background = element_rect(
      fill = "transparent",
      color = NA
    ),
    plot.background = element_rect(
      fill = "transparent",
      color = NA
    )
  )

# 2. Create the histogram plot
histogram_data <- pollutant_counts %>%
  count(pollutant_count) %>%
  complete(pollutant_count = 0:6, fill = list(n = 0)) %>%
  mutate(
    percentage = round(n / sum(n) * 100, 1),
    label_text = paste0(n, " countries\n(", percentage, "%)")
  )

hist_plot <- ggplot(histogram_data, aes(x = factor(pollutant_count), y = n)) +
  geom_col(
    aes(fill = factor(pollutant_count)),
    color = "white",
    linewidth = 0.5,
    alpha = 0.85,
    width = 0.3
  ) +
  scale_fill_manual(values = air_quality_colors, guide = "none") +
  scale_y_continuous(
    expand = expansion(mult = c(0, 0.25)),  # Increased top expansion from 0.15 to 0.25
    labels = number_format(accuracy = 1),
    breaks = seq(0, 120, by = 20)  # Custom breaks every 20 units: 0, 20, 40, 60, 80, 100, 120
  ) +
  scale_x_discrete(
    labels = c("Zero", "One", "Two", "Three", "Four", "Five", "Six")
  ) +
  labs(
    x = "Number of Pollutants with Established AQ Standards",
    y = "Number of Countries",
    subtitle = paste("Of the 251 countries and territories, 114 have no national air quality standards for any criteria pollutant,\n79 have standards for all six, and the remainder cover only a subset. This underscores the significant scope\nfor countries to introduce and/or expand official legal frameworks across a wider range of pollutants.")
  ) +
  theme_minimal() +
  theme(
    panel.grid.major.x = element_blank(),
    panel.grid.minor = element_blank(),
    panel.grid.major.y = element_line(color = "#3a4148", linewidth = 0.4),
    panel.background = element_rect(fill = "transparent", color = NA),
    plot.background = element_rect(fill = "transparent", color = NA),
    axis.title.x = element_text(
      size = 15,  # Increased from 13 to 15
      face = "bold",
      family = "Arial",
      color = text_primary,
      margin = margin(t = 15)
    ),
    axis.title.y = element_text(
      size = 15,  # Increased from 13 to 15
      face = "bold",
      family = "Arial",
      color = text_primary,
      margin = margin(r = 10)
    ),
    axis.text = element_text(
      size = 13,  # Increased from 11 to 13
      family = "Arial",
      color = text_secondary
    ),
    plot.subtitle = element_text(
      size = 16,  # Increased from 13 to 15
      hjust = 0.4,
      margin = margin(b = 1.2, unit = "cm"),  # Increased gap between histogram subtitle and plot
      family = "Arial",
      color = text_secondary,
      face = "italic"
    ),
    plot.margin = margin(10, 15, 15, 15)
  ) +
  geom_text(
    aes(label = label_text),
    vjust = -0.3,
    size = 5.5,  # Increased from 4.5 to 5.5
    fontface = "bold",
    family = "Arial",
    color = text_primary
  )

# 3. Create a dark, sophisticated background plot
background_plot <- ggplot() +
  # Dark primary background
  geom_rect(
    aes(xmin = -Inf, xmax = Inf, ymin = -Inf, ymax = Inf),
    fill = bg_primary
  ) +
  # Add a subtle dark overlay for depth
  geom_rect(
    aes(xmin = -Inf, xmax = Inf, ymin = -Inf, ymax = Inf),
    fill = bg_secondary,
    alpha = 0.3
  ) +
  theme_void()

# 4. Layer the map on top of the background using cowplot::ggdraw
map_with_background <- ggdraw() +
  draw_plot(background_plot) +
  draw_plot(map_plot)

# 5. Combine the layered map and the histogram using patchwork
combined_plot <- map_with_background / hist_plot +
  plot_layout(heights = c(3.5, 1.2)) +
  plot_annotation(
    title = "Air Quality Standards National Coverage for Criteria Pollutants across the World",
    subtitle = paste(
      "This analysis draws on the WHO/Swiss 2025 TPH Global Database of National Air Quality Standards (2nd edition, February 2025;\n updated May 2025). The database compiles standards for six criteria pollutants using averaging times aligned with WHO AQ Guidelines\n across 251 countries and territories. Standards set for additional averaging times in some countries are not captured in this dataset."
    ),
    caption = paste(
      "Data Source: WHO/SWISS TPH Global AQ Guidelines 2025",
      "| Standards assessed: PM2.5, PM10, NO2, SO2, O3, CO | Graphic: github.com/AarshBatra/biteSizedAQ"
    ),
    theme = theme(
      plot.title = element_text(
        size = 27,  # Increased from 22 to 24
        face = "bold",
        hjust = 0.5,
        family = "Arial",
        color = text_primary,
        margin = margin(b = 0.4, unit = "cm")  # Restored original spacing between title and subtitle
      ),
      plot.subtitle = element_text(
        size = 16,  # Increased from 13 to 15
        hjust = 0.4,
        margin = margin(b = 1),  # Very small margin between subtitle and map
        family = "Arial",
        color = text_secondary,
        lineheight = 1.2
      ),
      plot.caption = element_text(
        size = 11.5,  # Increased from 10 to 12
        hjust = 0.5,
        color = text_tertiary,
        family = "Arial",
        margin = margin(t = 1.5, b = 1, unit = "cm"),
        lineheight = 1.1
      ),
      plot.background = element_rect(
        fill = bg_primary,
        color = NA
      ),
      plot.margin = margin(20, 10, 15, 10)  # Reduced left/right margins to give more space to map
    )
  )

# # Add GitHub logo to the final plot using the same pattern as the sample
# final_plot <- ggdraw(combined_plot) +
#   draw_image(
#     "./18.bite.sized.vis.4.who.nat.aq.st.database.2025/gh_logo.png",  # Replace with your actual PNG file path
#     x = 0.72,     # Horizontal position (0-1, where 0.5 is center)
#     y = 0.020,    # Vertical position (0-1, where 0 is bottom)
#     width = 0.02, # Logo width (slightly larger than before)
#     height = 0.02 # Logo height (slightly larger than before)
#   )

# 6. Save the high-quality version of the plot
ggsave(
  "air_quality_standards_analysis_final.png",
  plot = combined_plot,  # Changed from combined_plot to final_plot
  width = 15,
  height = 17,
  dpi = 520
)
