library(RPostgreSQL)
library(ggplot2)
library(extrafont)
library(reshape2)
library(dplyr)
source("/Users/samuelestabrook/Documents/git/bikeshare-dc/analysis/helpers.R")

first_time <- "2015-06-03"
end_time <- "2015-06-04"
interval_time <- "4 minutes"

stations_list = query('SELECT DISTINCT target_name FROM wmata')

for (station in stations_list$target_name){
  nearest_share = query(paste0('
    WITH wmata_select AS (
    WITH correct_name AS (
    SELECT geom_names
    FROM wmata_name_conv c
    WHERE ', escape(station), ' = c.trip_names)
    SELECT geom 
    FROM wmata_stations s, correct_name n
    WHERE n.geom_names = s.name) 
    SELECT b.station, ST_Distance(ST_Transform(w.geom,6347), ST_Transform(b.geom,6347)) AS distance
    FROM bike_stations_num b, wmata_select w 
    ORDER BY ST_Distance(ST_Transform(w.geom,6347), ST_Transform(b.geom,6347)) ASC 
    LIMIT 1'))
  bike_station_var <- nearest_share[,1]
  metro_station_var <- station
  ms_slug <- to_slug(station)
  bs_slug <- to_slug(nearest_share[,1])

  both_signal = query(paste0('
    WITH share_agg AS (
      WITH bike_bins AS (
        SELECT
          r.start_station AS station,
          d::timestamp AS start_date,
          COUNT(r.id) AS bikes
        FROM generate_series(', escape(first_time), '::timestamp, ', escape(end_time), '::timestamp, ', escape(interval_time), ') d,
           bike_trips r
        WHERE r.start_date >= d::timestamp
          AND r.start_date < d::timestamp + ', escape(interval_time), '::interval
          AND r.start_station = ', escape(bike_station_var), '
        GROUP BY d::timestamp, station
        ORDER BY d::timestamp
      ), june_dates AS (
      SELECT generate_series(', escape(first_time), '::timestamp, ', escape(end_time), '::timestamp, ', escape(interval_time), ') AS trip_date
      )
      SELECT
        j.trip_date, COALESCE(bike_bins.bikes, 0) AS bikes
      FROM bike_bins
      FULL OUTER JOIN june_dates j ON j.trip_date = bike_bins.start_date
      ORDER BY j.trip_date
    ),
    metro_agg AS (
      WITH metro_bins AS (
        SELECT
          r.target_name AS station,
          d::timestamp AS end_date,
          COUNT(r.id) AS rides
        FROM generate_series(', escape(first_time), '::timestamp, ', escape(end_time), '::timestamp, ', escape(interval_time), ') d,
           wmata r
        WHERE r.target_t >= d::timestamp
          AND r.target_t < d::timestamp + ', escape(interval_time), '::interval
          AND r.target_name = ', escape(metro_station_var), '
        GROUP BY d::timestamp, station
        ORDER BY d::timestamp
      ), june_dates AS (
      SELECT generate_series(', escape(first_time), '::timestamp, ', escape(end_time), '::timestamp, ', escape(interval_time), ') AS trip_date
      )
      SELECT
        j.trip_date, COALESCE(metro_bins.rides, 0) AS rides
      FROM metro_bins
      FULL OUTER JOIN june_dates j ON j.trip_date = metro_bins.end_date
      ORDER BY j.trip_date
    )
    SELECT
      m.trip_date,
      m.rides,
      b.bikes
    FROM metro_agg m, share_agg b
    WHERE m.trip_date >= ', escape(first_time), '::timestamp
      AND m.trip_date <  ', escape(end_time), '::timestamp
      AND b.trip_date >= ', escape(first_time), '::timestamp
      AND b.trip_date <  ', escape(end_time), '::timestamp
      AND m.trip_date = b.trip_date
    '))
  
  both_signal$trip_date = as.POSIXlt(both_signal$trip_date, tz='America/New_York')
  both_signal$ride_ratio <- both_signal$rides/sum(both_signal$rides)
  both_signal$bike_ratio <- both_signal$bikes/sum(both_signal$bikes)
  both_signal_long <- melt(both_signal, id="trip_date")

  p = ggplot(both_signal, aes(trip_date)) + 
      geom_line(aes(y = ride_ratio), colour = "blue", alpha = 0.4) + 
      stat_smooth(data = both_signal, aes(x = trip_date, y = ride_ratio), method = "gam", formula = y ~ s(x), se = FALSE, size = 1, colour = "blue") +
      geom_line(aes(y = bike_ratio), colour = "red", alpha = 0.4)+
      stat_smooth(data = both_signal, aes(x = trip_date, y = bike_ratio), method = "gam", formula = y ~ s(x), se = FALSE, size = 1, colour = "red")
  png(filename = paste0('/Users/samuelestabrook/Documents/git/bikeshare-dc/analysis/graphs/sig_', ms_slug, '_m_', bs_slug,'_b_4.png'), width = 640, height = 420)
  print(p)
  dev.off()
}