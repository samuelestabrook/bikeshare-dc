# signal charting

library(RPostgreSQL)
library(ggplot2)
library(extrafont)
library(dplyr)
library(scales)
source("/Users/samuelestabrook/Documents/git/bikeshare-dc/analysis/helpers.R")

bikeshare_signal = query("
  SELECT
    trip_date,
    bikes
  FROM bike_union
  WHERE trip_date >= '2015-06-03'::timestamp
    AND trip_date <  '2015-06-04'::timestamp
  ")

bikeshare_signal = query("
  SELECT
    trip_date,
    bikes
  FROM bike_lincoln
  WHERE trip_date >= '2015-06-03'::timestamp
    AND trip_date <  '2015-06-04'::timestamp
  ")

bikeshare_signal = query("
  SELECT
    trip_date,
    bikes
  FROM bike_1_n_se
  WHERE trip_date >= '2015-06-03'::timestamp
    AND trip_date <  '2015-06-04'::timestamp
  ")

bikeshare_signal = query("
  SELECT
    trip_date,
    bikes
  FROM bike_jefferson
  WHERE trip_date >= '2015-06-03'::timestamp
    AND trip_date <  '2015-06-04'::timestamp
  ")

bikeshare_signal = query("
  SELECT
    trip_date,
    bikes
  FROM bike_iwo_jima
  WHERE trip_date >= '2015-06-03'::timestamp
    AND trip_date <  '2015-06-04'::timestamp
  ")

bikeshare_signal$trip_date = as.POSIXlt(bikeshare_signal$trip_date, tz='America/New_York')
bikeshare_signal$trip_date$hour <- bikeshare_signal$trip_date$hour - 4

png(filename = '/Users/samuelestabrook/Documents/git/bikeshare-dc/analysis/graphs/bike_iwo_jima.png', width = 640, height = 420)
ggplot(data = bikeshare_signal, aes(x = trip_date, y = bikes)) +
  geom_bar(stat='identity') +
  scale_x_datetime(date_breaks=('2 hours'), labels=date_format('%H')) +
  title_with_subtitle('Union Station Bikeshare Pickups')
dev.off()

#####################


#Selected stations for charting:

metro_crystal_city
share_crystal_city_metro_18th_bell_st

metro_clarendon
share_clarendon_metro_wilson_blvd_n_highland_st

metro_clarendon
share_clarendon_blvd_pierce_st

metro_clarendon
share_clarendon_blvd_n_fillmore_st

metro_eastern_market
share_eastern_market_metro_pennsylvania_ave_7th_st_se

metro_eastern_market
share_eastern_market_7th_north_carolina_ave_se




library(RPostgreSQL)
library(ggplot2)
library(extrafont)
library(reshape2)
source("/Users/samuelestabrook/Documents/git/bikeshare-dc/analysis/helpers.R")
both_signal = query("
  SELECT
    m.trip_date,
    m.rides,
    b.bikes
  FROM metro_union_station m, share_columbus_circle_union_station b
  WHERE m.trip_date >= '2015-06-03'::timestamp
    AND m.trip_date <  '2015-06-04'::timestamp
    AND b.trip_date >= '2015-06-03'::timestamp
    AND b.trip_date <  '2015-06-04'::timestamp
    AND m.trip_date = b.trip_date
  ")
both_signal$trip_date = as.POSIXlt(both_signal$trip_date, tz='America/New_York')
both_signal$ride_ratio <- both_signal$rides/sum(both_signal$rides)
both_signal$bike_ratio <- both_signal$bikes/sum(both_signal$bikes)
both_signal_long <- melt(both_signal, id="trip_date")
png(filename = '/Users/samuelestabrook/Documents/git/bikeshare-dc/analysis/graphs/union_station_final.png', width = 640, height = 420)
ggplot(both_signal, aes(trip_date)) + 
  geom_line(aes(y = ride_ratio), colour = "blue", alpha = 0.4) + 
  stat_smooth(data = both_signal, aes(x = trip_date, y = ride_ratio), method = "gam", formula = y ~ s(x), se = FALSE, size = 1, colour = "cyan") +
  geom_line(aes(y = bike_ratio), colour = "red", alpha = 0.4)+
  stat_smooth(data = both_signal, aes(x = trip_date, y = bike_ratio), method = "gam", formula = y ~ s(x), se = FALSE, size = 1, colour = "pink")
dev.off()


FIND THE CLOSEST BIKE SHARE STATIONS:

SELECT b.id, b.geom, ST_Distance(ST_Transform(b.geom,6347),ST_Transform(w.geom, 6347)) FROM wmata_stations w, bike_stations_num b ORDER BY ST_Distance(b.geom, w.geom) LIMIT 90;


# TEST QUERY WITH FULL COMBINED R SUPPORT AND NO INTERMEDIATE QUERIES:


library(RPostgreSQL)
library(ggplot2)
library(extrafont)
library(reshape2)
library(dplyr)
source("/Users/samuelestabrook/Documents/git/bikeshare-dc/analysis/helpers.R")


# For each metro station
# select nearest bike station
# run script on the two
# select next nearest bike station

for(row in 1:row(data)){}
bike_station_str <- 
metro_station_str <- 
first_time <- 
end_time <- 
interval_time <- "3 minutes"


# needed?
bike_station_var <- 
metro_station_var <- 

both_signal = query(paste0("
  WITH share_", bike_station_str, " AS (
    WITH bike_bins AS (
      SELECT
        r.start_station AS station,
        d::timestamp AS start_date,
        COUNT(r.id) AS bikes
      FROM generate_series(", first_time, "::timestamp, ", end_time, "::timestamp, ", interval_time, ") d,
         bike_trips r
      WHERE r.start_date >= d::timestamp
        AND r.start_date < d::timestamp + ", interval_time, "::interval
        AND r.start_station = ", bike_station_var, "
      GROUP BY d::timestamp, station
      ORDER BY d::timestamp
    ), june_dates AS (
    SELECT generate_series(", first_time, "::timestamp, ", end_time, "::timestamp, ", interval_time, ") AS trip_date
    )
    SELECT
      j.trip_date, COALESCE(bike_bins.bikes, 0) AS bikes
    FROM bike_bins
    FULL OUTER JOIN june_dates j ON j.trip_date = bike_bins.start_date
    ORDER BY j.trip_date
  ),
  metro_", metro_station_str, " AS (
    WITH metro_bins AS (
      SELECT
        r.target_name AS station,
        d::timestamp AS end_date,
        COUNT(r.id) AS rides
      FROM generate_series(", first_time, "::timestamp, ", end_time, "::timestamp, ", interval_time, ") d,
         wmata r
      WHERE r.target_t >= d::timestamp
        AND r.target_t < d::timestamp + ", interval_time, "::interval
        AND r.target_name = ", metro_station_var, "
      GROUP BY d::timestamp, station
      ORDER BY d::timestamp
    ), june_dates AS (
    SELECT generate_series(", first_time, "::timestamp, ", end_time, "::timestamp, ", interval_time, ") AS trip_date
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
  FROM metro_", metro_station_str, " m, share_", bike_station_str, " b
  WHERE m.trip_date >= ", first_time, "::timestamp
    AND m.trip_date <  ", end_time, "::timestamp
    AND b.trip_date >= ", first_time, "::timestamp
    AND b.trip_date <  ", end_time, "::timestamp
    AND m.trip_date = b.trip_date
  ")

lower(trim(trailing from replace(replace(replace(replace(replace(replace(replace(replace(projectrow, ' ', '_'), '''', '_'), '-', '_'), '&', '_'), '/', '_'), '.', '_'), '___', '_'), '__', '_'), '_')), '2015-06-03', '2015-06-04', '3 minutes', projectrow);


both_signal$trip_date = as.POSIXlt(both_signal$trip_date, tz='America/New_York')
both_signal$ride_ratio <- both_signal$rides/sum(both_signal$rides)
both_signal$bike_ratio <- both_signal$bikes/sum(both_signal$bikes)
both_signal_long <- melt(both_signal, id="trip_date")
png(filename = '/Users/samuelestabrook/Documents/git/bikeshare-dc/analysis/graphs/union_station_final.png', width = 640, height = 420)
ggplot(both_signal, aes(trip_date)) + 
  geom_line(aes(y = ride_ratio), colour = "blue", alpha = 0.4) + 
  stat_smooth(data = both_signal, aes(x = trip_date, y = ride_ratio), method = "gam", formula = y ~ s(x), se = FALSE, size = 1, colour = "cyan") +
  geom_line(aes(y = bike_ratio), colour = "red", alpha = 0.4)+
  stat_smooth(data = both_signal, aes(x = trip_date, y = bike_ratio), method = "gam", formula = y ~ s(x), se = FALSE, size = 1, colour = "pink")
dev.off()



# FUCKIN WORKS!!!!

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
  png(filename = paste0('/Users/samuelestabrook/Documents/git/bikeshare-dc/analysis/automated/sig_', ms_slug, '_m_', bs_slug,'_b_4.png'), width = 640, height = 420)
  print(p)
  dev.off()
}


# NEED TO SAVE AND EVALUATE DISTANCES
# MAYBE ALSO INTERSECT A BUFFER????

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
    SELECT b.geom AS stations
    FROM wmata_select w, bike_stations_num b
    WHERE ST_Intersects(ST_Transform(b.geom, 6347), ST_Buffer(ST_Transform(w.geom, 6347), 300))
    '))

  #station_count <- nearest_share
  #print(station)
  #print(station_count)

  # with the buffer, each result will have possibly multiple bikeshares - aggregate or loop????
  closest_1 <- c(nearest_share[,1])
  closest_2 <- c(nearest_share[,2])
  closest_3 <- c(nearest_share[,3])
  closest_4 <- c(nearest_share[,4])



  bike_station_var <- 
  bike_station_var_2 <- closest[]
  bike_station_var_3 <- closest[]
  bike_station_var_4 <- closest[]
  metro_station_var <- station
  ms_slug <- to_slug(station)
  bs_slug <- to_slug(nearest_share[,1])
  pretty_string <- paste0('Metro Station ', station, ' is closest to ', nearest_share[,1], ' Capital Bikeshare station at ', nearest_share[,2], ' meters.')
  print(pretty_string)
  # add to a dataframe for saving here
}



MY SOLUTION FOR INCORPORATING MORE THAN ONE BIKE SHARE STATION PER METRO STATION - BUFFER YEYEYEYEYEYE

agg_signal_2 = query(paste0('
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
        AND r.start_station = ', escape(bike_station_var), ' OR ', escape(bike_station_var_2), '
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

##########################################################################
agg_signal_2 = query(paste0('
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
        AND r.start_station = ', escape(bike_station_var), ' OR ', escape(bike_station_var_2), '
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

##########################################################################
agg_signal_3 = query(paste0('
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
        AND r.start_station = ', escape(bike_station_var), ' OR ', escape(bike_station_var_2), ' OR ', escape(bike_station_var_3), '
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


##########################################################################
agg_signal_4 = query(paste0('
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
        AND r.start_station = ', escape(bike_station_var), ' OR ', escape(bike_station_var_2), ' OR ', escape(bike_station_var_3), ' OR ', escape(bike_station_var_4), '
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



#BUFFER INTERSECTION WORKSPACE

WITH wmata_select AS (
WITH correct_name AS (
SELECT geom_names
FROM wmata_name_conv c
WHERE 'Union Station' = c.trip_names)
SELECT geom 
FROM wmata_stations s, correct_name n
WHERE n.geom_names = s.name) 
SELECT b.geom AS stations, row_number() OVER () AS id
FROM wmata_select w, bike_stations_num b
WHERE ST_Intersects(ST_Transform(b.geom, 6347), ST_Buffer(ST_Transform(w.geom, 6347), 200));

"Columbia Heights"

WITH wmata_select AS (
WITH correct_name AS (
SELECT geom_names
FROM wmata_name_conv c
WHERE 'Columbia Heights' = c.trip_names)
SELECT geom 
FROM wmata_stations s, correct_name n
WHERE n.geom_names = s.name) 
SELECT b.geom AS stations, row_number() OVER () AS id
FROM wmata_select w, bike_stations_num b
WHERE ST_Intersects(ST_Transform(b.geom, 6347), ST_Buffer(ST_Transform(w.geom, 6347), 200));

WITH wmata_select AS (
WITH correct_name AS (
SELECT geom_names
FROM wmata_name_conv c
WHERE 'Columbia Heights' = c.trip_names)
SELECT geom 
FROM wmata_stations s, correct_name n
WHERE n.geom_names = s.name) 
SELECT b.geom AS stations, row_number() OVER () AS id
FROM wmata_select w, bike_stations_num b
WHERE ST_Intersects(ST_Transform(b.geom, 6347), ST_Buffer(ST_Transform(w.geom, 6347), 300));









































# OLD MANUAL CHARTING

both_signal$trip_date = as.POSIXlt(both_signal$trip_date, tz='America/New_York')
both_signal$ride_ratio <- both_signal$rides/sum(both_signal$rides)
both_signal$bike_ratio <- both_signal$bikes/sum(both_signal$bikes)
both_signal_long <- melt(both_signal, id="trip_date")
png(filename = '/Users/samuelestabrook/Documents/git/bikeshare-dc/analysis/graphs/union_week_10min.png', width = 640, height = 420)
ggplot(both_signal, aes(trip_date)) + 
  geom_line(aes(y = ride_ratio), colour = "blue", alpha = 0.4) + 
  stat_smooth(data = both_signal, aes(x = trip_date, y = ride_ratio), method = "gam", formula = y ~ s(x), se = FALSE, size = 1, colour = "blue") +
  geom_line(aes(y = bike_ratio), colour = "red", alpha = 0.4)+
  stat_smooth(data = both_signal, aes(x = trip_date, y = bike_ratio), method = "gam", formula = y ~ s(x), se = FALSE, size = 1, colour = "red")
dev.off()

counts <- table(both_signal$bikes)
barplot(counts, main="Frequency Distribution", xlab="Number of Bikes in bin")

counts <- table(both_signal$rides)
barplot(counts, main="Frequency Distribution", xlab="Number of Rides in bin")






# FIXING THE METRO NAMES!!!!!!!!

CREATE TABLE wmata_name_conv (trip_names varchar, geom_names varchar);

COPY wmata_name_conv FROM '/Users/samuelestabrook/Desktop/name_conversions.csv' DELIMITER ',' CSV;

# wmata_name_conv.geom_names = wmata_stations.name
# wmata_name_conv.trip_names = wmata.target_name OR wmata.source_name










# Calendar style charts

library(RPostgreSQL)
library(ggplot2)
library(extrafont)
library(reshape2)
source("/Users/samuelestabrook/Documents/git/bikeshare-dc/analysis/helpers.R")
both_signal = query("
  SELECT
    m.trip_date,
    m.rides,
    b.bikes
  FROM metro_union_station m, share_columbus_circle_union_station b
  WHERE m.trip_date >= '2015-06-03'::timestamp
    AND m.trip_date <  '2015-06-04'::timestamp
    AND b.trip_date >= '2015-06-03'::timestamp
    AND b.trip_date <  '2015-06-04'::timestamp
    AND m.trip_date = b.trip_date
  ")
both_signal$trip_date = as.POSIXlt(both_signal$trip_date, tz='America/New_York')
both_signal$ride_ratio <- both_signal$rides/sum(both_signal$rides)
both_signal$bike_ratio <- both_signal$bikes/sum(both_signal$bikes)
both_signal_long <- melt(both_signal, id="trip_date")
png(filename = '/Users/samuelestabrook/Documents/git/bikeshare-dc/analysis/graphs/union_station_final.png', width = 640, height = 420)
ggplot(both_signal, aes(trip_date)) + 
  geom_line(aes(y = ride_ratio), colour = "blue", alpha = 0.4) + 
  stat_smooth(data = both_signal, aes(x = trip_date, y = ride_ratio), method = "gam", formula = y ~ s(x), se = FALSE, size = 1, colour = "cyan") +
  geom_line(aes(y = bike_ratio), colour = "red", alpha = 0.4)+
  stat_smooth(data = both_signal, aes(x = trip_date, y = bike_ratio), method = "gam", formula = y ~ s(x), se = FALSE, size = 1, colour = "pink")
dev.off()




















































library(RPostgreSQL)
library(ggplot2)
library(extrafont)
library(dplyr)
library(scales)
source("/Users/samuelestabrook/Documents/git/bikeshare-dc/analysis/helpers.R")

metros = query("
  SELECT DISTINCT lower(trim(trailing from replace(replace(replace(replace(replace(replace(replace(replace(target_name, ' ', '_'), '''', '_'), '-', '_'), '&', '_'), '/', '_'), '.', '_'), '___', '_'), '__', '_'), '_'))
  FROM wmata
  ")

shares = query("
  SELECT DISTINCT lower(trim(trailing from replace(replace(replace(replace(replace(replace(replace(replace(start_station, ' ', '_'), '''', '_'), '-', '_'), '&', '_'), '/', '_'), '.', '_'), '___', '_'), '__', '_'), '_'))
  FROM bike_trips
  ")

for (m in metros) {
  metro_signal = query("
  SELECT
    trip_date,
    rides
  FROM m
  WHERE trip_date >= '2015-06-03'::timestamp
    AND trip_date <  '2015-06-04'::timestamp
  ")
  p = ggplot(data = metro_signal, aes(x = trip_date, y = rides)) +
  geom_bar(stat='identity') +
  scale_x_datetime(date_breaks=('2 hours'), labels=date_format('%H')) +
  title_with_subtitle('%s Metro exits', m)
}










metro_signal = query("
  SELECT
    trip_date,
    rides
  FROM metro_union
  WHERE trip_date >= '2015-06-03'::timestamp
    AND trip_date <  '2015-06-04'::timestamp
  ", ) 

metro_signal$trip_date = as.POSIXlt(metro_signal$trip_date, tz='America/New_York')
metro_signal$trip_date$hour <- metro_signal$trip_date$hour - 4

png(filename = '/Users/samuelestabrook/Documents/git/bikeshare-dc/analysis/graphs/metro_union.png', width = 640, height = 420)
ggplot(data = metro_signal, aes(x = trip_date, y = rides)) +
  geom_bar(stat='identity') +
  scale_x_datetime(date_breaks=('2 hours'), labels=date_format('%H')) +
  title_with_subtitle('Union Station Metro exits')
dev.off()


#####################

library(RPostgreSQL)
library(ggplot2)
library(extrafont)
library(reshape2)
source("/Users/samuelestabrook/Documents/git/bikeshare-dc/analysis/helpers.R")

both_signal = query("
  SELECT
    m.trip_date,
    m.rides,
    b.bikes
  FROM metro_union_station m, share_union_market_6th_st_neal_pl_ne b
  WHERE m.trip_date >= '2015-06-03'::timestamp
    AND m.trip_date <  '2015-06-04'::timestamp
    AND b.trip_date >= '2015-06-03'::timestamp
    AND b.trip_date <  '2015-06-04'::timestamp
    AND m.trip_date = b.trip_date
  ")

both_signal$trip_date = as.POSIXlt(both_signal$trip_date, tz='America/New_York')
both_signal$trip_date$hour <- both_signal$trip_date$hour - 4

png(filename = '/Users/samuelestabrook/Documents/git/bikeshare-dc/analysis/graphs/metro_union.png', width = 640, height = 420)
ggplot(data = both_signal, aes(x = trip_date, y = rides)) +
  geom_bar(stat='identity') +
  geom_line(group=)
  scale_x_datetime(date_breaks=('2 hours'), labels=date_format('%H')) +
  title_with_subtitle('Union Station Metro exits')
dev.off()

both_signal$ride_ratio <- both_signal$rides/sum(both_signal$rides)
both_signal$bike_ratio <- both_signal$bikes/sum(both_signal$bikes)

both_signal_long <- melt(both_signal, id="trip_date")

png(filename = '/Users/samuelestabrook/Documents/git/bikeshare-dc/analysis/graphs/both_plot_10.png', width = 640, height = 420)
ggplot(both_signal_long, aes(trip_date)) +
       geom_line() +
       stat_smooth(aes(trip_date), method = "gam", formula = y ~ s(x), se = FALSE, size = 1)
dev.off()


png(filename = '/Users/samuelestabrook/Documents/git/bikeshare-dc/analysis/graphs/both_plot_gam2.png', width = 640, height = 420)
ggplot(both_signal, aes(trip_date)) + 
  geom_line(aes(y = ride_ratio), colour = "blue") + 
  stat_smooth(data = both_signal, aes(x = trip_date, y = ride_ratio), method = "gam", formula = y ~ s(x), se = FALSE, size = 1, colour = "dark blue") +
  geom_line(aes(y = bike_ratio), colour = "red")+
  stat_smooth(data = both_signal, aes(x = trip_date, y = bike_ratio), method = "gam", formula = y ~ s(x), se = FALSE, size = 1, colour = "dark red")
dev.off()



png(filename = '/Users/samuelestabrook/Documents/git/bikeshare-dc/analysis/graphs/metro_smooths.png', width = 640, height = 420)
ggplot(both_signal, aes(trip_date)) + 
  geom_line(aes(y = ride_ratio), colour = "blue") + 
  stat_smooth(data = both_signal, aes(x = trip_date, y = ride_ratio), method = "lm", formula = y ~ x, size = 1, se = FALSE, colour = "black") + 
  stat_smooth(data = both_signal, aes(x = trip_date, y = ride_ratio), method = "lm", formula = y ~ x + I(x^2), size = 1, se = FALSE, colour = "dark blue") + 
  stat_smooth(data = both_signal, aes(x = trip_date, y = ride_ratio), method = "loess", formula = y ~ x, size = 1, se = FALSE, colour = "red") +
  stat_smooth(data = both_signal, aes(x = trip_date, y = ride_ratio), method = "gam", formula = y ~ s(x), size = 1, se = FALSE, colour = "green") +
  stat_smooth(data = both_signal, aes(x = trip_date, y = ride_ratio), method = "gam", formula = y ~ s(x, k = 3), size = 1, se = FALSE, colour = "violet")
dev.off()



loess   y ~ x
gam   y ~ s(x)







#####################
BELOW DOESNT WORK, BUT ITS A POSSIBILITY FOR DOUBLE PLOTTING

install.packages('plotrix', dep = TRUE)
library("plotrix")

going_up<-seq(3,7,by=0.5)+rnorm(9)
 going_down<-rev(60:74)+rnorm(15)
 twoord.plot(2:10,metro_signal$rides,1:15,bikeshare_signal$bikes,xlab="Sequence",
  ylab="Ascending values",rylab="Descending values",lcol=4,
  main="Trial Combination Plots",
  do.first="plot_bg();grid(col=\"white\",lty=1)")












bikeshare_signal$trip_date = as.POSIXct(bikeshare_signal$trip_date, tz='America/New_York')

unclass(bikeshare_signal)
sapply(bikeshare_signal, class)
sapply(bikeshare_signal, typeof)

Sys.timezone()
attr(bikeshare_signal[,1][1],"tzone")
base::format(bikeshare_signal[,1][1], format="%Z")

attr(bikeshare_signal$trip_date, "tzone") <- "America/New_York"

#####################
attributes(bikeshare_signal$trip_date)$tzone <- "America/New_York"
bikeshare_signal$trip_date = as.POSIXlt(c(bikeshare_signal$trip_date), tz='America/New_York')

as.POSIXct(Sys.time(),"America/New_York")
as.POSIXlt(Sys.time(),"America/New_York")


#for day in month:
#take one day
#make graph
#move to next day

names(unclass(bikeshare_signal[,1][1]))
bikeshare_signal$trip_date$hour <- bikeshare_signal$trip_date$hour - 4


png(filename = '/Users/samuelestabrook/Documents/git/bikeshare-dc/analysis/graphs/signal_bikes1.png', width = 640, height = 420)
ggplot(data = bikeshare_signal, aes(x = trip_date, y = bikes)) +
  geom_bar(stat='identity') +
  scale_x_datetime(date_breaks=('2 hours'), labels=date_format('%H')) +
  title_with_subtitle('Union Station Bikeshare Pickups')
dev.off()




























  mutate(timestamp_for_x_axis = as.POSIXct(trip_date))
ggplot(data = bikeshare_signal, aes(x = timestamp_for_x_axis, y = bikes)) +
  scale_y_continuous('Number of Bikes pulled\n') +
  geom_line(size = 0.5) +
, labels = comma
#  scale_x_datetime(labels=date_format('%H:%M:%S')) + 



#-----------------------------------------------------
library(ggplot2)

datos=read.csv(zz, sep=";", header=TRUE, na.strings="-99.9")

datos$dia=as.POSIXct(datos[,1], format="%y/%m/%d %H:%M:%S")  

ggplot(data=datos,aes(x=dia, y=TEMP_M)) + 
  geom_path(colour="red") + 
  ylab("Temperatura (ºC)") + 
  xlab("Fecha") + 
  opts(title="Temperatura media") 
#-----------------------------------------------------


#-----------------------------------------------------
#BELOW DOESNT WORK
#
#
#bikeshare_signal = query("
#  SELECT
#    trip_date,
#    bikes
#  FROM bike_zeros
#  ")
#
#bikeshare_signal = bikeshare_signal %>%
#  mutate(timestamp_for_x_axis = as.POSIXct(trip_date, origin = "1970-01-01", tz = "UTC"))
#
#png(filename = "graphs/uniquely_identifiable.png", width = 640, height = 420)
#ggplot(data = bikeshare_signal, aes(x = timestamp_for_x_axis, y = bikes)) +
#  geom_line(size = 1) +
#  scale_x_continuous("Date") +
#  scale_y_continuous("Number of Bikes pulled\n", labels = count) +
##  expand_limits(y = c(0.7, 1)) +
#  scale_color_discrete("") +
#  title_with_subtitle("Union Station Bikeshare Pickups") +
##  theme_tws(base_size = 18) +
#  theme(legend.position = "bottom")
##add_credits()
#dev.off()