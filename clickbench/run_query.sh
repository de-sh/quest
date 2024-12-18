#!/bin/bash

# Load the JSON file
JSON_FILE="expected.json"
QUERY_NUM=1

# Parse the JSON file and iterate over each query-response pair
jq -c '.queries[]' "$JSON_FILE" | while read -r query; do
    # Extract the query and expectation from the current JSON object
    QUERY=$(echo "$query" | jq -r '.query')
    RESPONSE=$(echo "$query" | jq -r '.response')

    printf "$QUERY_NUM: $QUERY => "

    # Construct the JSON payload for the request
    JSON=$(jq -n --arg query "$QUERY" \
        '{query: $query, startTime: "$START_TIME", endTime: "$END_TIME"}')

    # Measure the time taken to execute the query
    start_time=$(date +%s%3N)
    curl  -H "Content-Type: application/json" -k -XPOST -u "$P_USERNAME:$P_PASSWORD" "$P_URL/api/v1/query" --data "${JSON}"
    end_time=$(date +%s%3N)
    elapsed_time=$((end_time - start_time))

    echo " (${elapsed_time}ms)"
    echo "${QUERY_NUM},${elapsed_time}" >> result.csv

    QUERY_NUM=$((QUERY_NUM + 1))

done;
