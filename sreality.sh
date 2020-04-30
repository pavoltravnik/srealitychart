

#!/bin/bash

# firebase integration REST API
API_KEY="<your-firabase-api-key>";


# category_main_cb = byty (1) | domy (2) | pozemky (3) | komercni (4)
# category_type_cb = prodej (1) | pronajem (2)
# locality_region_id = kraje (1-14)
# locality_district_id = praha 5001 - 5010


for category_main_cb in {1..4}
do
  for category_type_cb in {1..2}
  do

    # CR
    # initiate json object 
    json="{\"date\": \"$(date +%F)\"}";
    for locality_region_id in {1..14}
    do
      sleep $((1 + RANDOM % 5));
      result_size=$(curl -s "https://www.sreality.cz/api/cs/v2/estates/count?category_main_cb=${category_main_cb}&category_type_cb=${category_type_cb}&locality_country_id=112&locality_region_id=${locality_region_id}" | jq .result_size)
      json=$(echo $json | jq --arg locality_region_id $locality_region_id --arg result_size $result_size '. + {($locality_region_id): ($result_size)|tonumber}');

    done
    curl -X POST -d "$json" "https://<firebase-db-name>.firebaseio.com/cr/${category_main_cb}/${category_type_cb}.json?auth=${API_KEY}"



    # PRG - region prague contains also districts
    json="{\"date\": \"$(date +%F)\"}";
    for locality_region_id in {10..10}
    do
      for locality_district_id in {5001..5010}
      do
        sleep $((1 + RANDOM % 5));
        result_size=$(curl -s "https://www.sreality.cz/api/cs/v2/estates/count?category_main_cb=${category_main_cb}&category_type_cb=${category_type_cb}&locality_country_id=112&locality_district_id=${locality_district_id}&locality_region_id=${locality_region_id}" | jq .result_size)
        json=$(echo $json | jq --arg locality_district_id $locality_district_id --arg result_size $result_size '. + {($locality_district_id): ($result_size)|tonumber}');

      done
      curl -X POST -d "$json" "https://<firebase-db-name>.firebaseio.com/prg/${category_main_cb}/${category_type_cb}.json?auth=${API_KEY}"
    done

  done
done
