cat raw_data_urls_dc.txt | xargs -n 1 -P 6 wget -P data/
cd data
unzip \*.zip
cd ..