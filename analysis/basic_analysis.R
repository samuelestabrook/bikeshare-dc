# Basic Plots in R
# Samuel Estabrook
# Thesis Proposal

# Bicycle Sharing Last Mile Signal Processing

# Actual functioning R script produces 3 graphs of the maintenance results
# from Tom's analysis of the Citi bikeshare

# If I can get this to work tonight, then I can get the Github repo up and running tomorrow

#drv <- dbDriver("PostgreSQL")

#con <- dbConnect(drv, dbname = "bikesharedb",
#	host = "localhost")

# TEST IF CONNECTION WORKS
#dbExistsTable(con, "bike_trips")

library(RPostgreSQL)
library(ggplot2)
library(extrafont)
library(dplyr)
library(scales)
source("helpers.R")

transports_hourly = query("
  SELECT
    station,
    hour,
    SUM(transported_to_other_station) / SUM(total_drop_offs) frac,
    SUM(total_drop_offs) total
  FROM hourly_station_aggregates a
    INNER JOIN bike_stations_num s
    ON a.end_num = s.id
  GROUP BY station, hour
  HAVING SUM(total_drop_offs) > 100
  ORDER BY station, hour
")
transports_hourly = transports_hourly %>%
  mutate(timestamp_for_x_axis = as.POSIXct(hour * 3600, origin = "1970-01-01", tz = "UTC"))

ntas = c("8th & D St NW", "8th & H St NW", "18th & R St NW", "7th & T St NW", "3rd & H St NE", "8th & H St NW")
for (n in ntas) {
  p = ggplot(data = filter(transports_hourly, station == n),
             aes(x = timestamp_for_x_axis, y = frac)) +
      geom_bar(stat = "identity", fill = capital_hex) +
      scale_x_datetime("\nDrop off hour", labels = date_format("%l %p")) +
      scale_y_continuous("% of bikes transported\n", labels = percent) +
      title_with_subtitle(n, "% of Capital Bike Share Bikes that are manually moved to a different station after being dropped off") +
      theme_tws(base_size = 18)

  png(filename = paste0("graphs/transports_", to_slug(n), ".png"), width = 640, height = 400)
  print(p)
#  add_credits()
  dev.off()
}