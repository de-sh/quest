#!/bin/bash

QUERY_NUM=1
cat 'queries.sql' | while read -r QUERY; do

    printf "$QUERY_NUM: $QUERY => "
    JSON=$(jq -n --arg query "$QUERY" \
        '{query: $query, startTime: "2024-10-29T00:00:00.000Z", endTime: "2024-11-29T23:00:00.000Z"}')

    start_time=$(date +%s%3N)
    curl  -H "Content-Type: application/json" -k -XPOST -u "admin:admin" "$P_URL/api/v1/query" --data "${JSON}"
    end_time=$(date +%s%3N)
    elapsed_time=$((end_time - start_time))

    echo " (${elapsed_time}ms)"
    echo "${QUERY_NUM},${elapsed_time}" >> result.csv

    QUERY_NUM=$((QUERY_NUM + 1))

done;
