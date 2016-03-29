require 'rubygems'
require 'rest-client'
require 'json'
require 'polylines'

# this ignores some work to connect to a postgres database that contains the `trips` and `stations` tables,
# but the basic idea is to use the Google Maps Directions API to get cycling directions as JSON, then
# use the polylines gem to decode directions into a series of lat/long coordinates

class Station < ActiveRecord::Base; end  ######### NEED TO CHECK THE SEMICOLON

class Trip < ActiveRecord::Base
  BASE_URL = 'localhost:5000'  ######### NEED TO FIX

  belongs_to :start_station, class_name: 'Station'
  belongs_to :end_station, class_name: 'Station'

  def directions_url
    qry = {
      loc: [start_station.latitude, start_station.longitude].map(&:to_f).join(','),
      loc: [end_station.latitude, end_station.longitude].map(&:to_f).join(',')
    }.to_query

    "#{BASE_URL}?#{qry}"
  end

  def fetch_directions_json
    JSON.parse(RestClient.get(directions_url))
  end

  def convert_directions_to_line_segments(options = {})
    steps = fetch_directions_json['routes'].first['legs'].first['steps']

    leg_counter = 1
    legs = []

    steps.each do |step|
      polyline = step['polyline']['points']
      points = Polylines::Decoder.decode_polyline(polyline)

      points.each_cons(2) do |(lat1, lon1), (lat2, lon2)|
        h = {
          number: leg_counter,
          start_station_id: start_station_id,
          end_station_id: end_station_id,
          start_latitude: lat1,
          start_longitude: lon1,
          end_latitude: lat2,
          end_longitude: lon2,
          duration: total_time
        }

        legs << h

        leg_counter += 1
      end
    end
  end
end

require 'pg'


conn = PGconn.open(:dbname => 'bikesharedb')
res = conn.exec('SELECT * FROM bike_stations_unique')
res.each do |re|
  re = Station.new
end

res_ref = conn.exec_params('SELECT * FROM bike_trips')
list = []

#for i in res_ref
#  res2 = conn.exec_params('SELECT * FROM bike_trips WHERE id = $1', [trip_id])
res_ref.each do |ref|
  ref = Trip.new
  Trip.convert_directions_to_line_segments(ref)
  list << ref
#  trip_id += 1
end

conn.close





BELOW IS WHAT COMES OUT OF THE RUBY PROCESS (MAYBE NPM POLYLINE? :/ )

MISSING -- station_direction_id and duration --


          station_direction_id: station_direction_id, ##????????

  station_direction_id integer,
  start_station_id integer,
  end_station_id integer,
  number integer,
  start_latitude numeric(9, 6),
  start_longitude numeric(9, 6),
  end_latitude numeric(9, 6),
  end_longitude numeric(9, 6),
  duration numeric(9, 6)
