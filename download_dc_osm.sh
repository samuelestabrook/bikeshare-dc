http://download.geofabrik.de/north-america/us-south-latest.osm.pbf | xargs -n 1 -P 6 wget -P data/
brew install osmosis
brew cleanup -s
cd data
osmosis --rb us-south-latest.osm.pbf --bounding-box left=-77.50 right=-76.50 top=39.25 bottom=38.50 --wb dc-area.osm.pbf
cd ..