#!/bin/bash

# Load the JSON file
JSON_FILE="expected.json"
QUERY_NUM=1

# Parse the JSON file and iterate over each query-response pair
jq -c '.[]' "$JSON_FILE" | while read -r item; do
    # Extract the query and expectation from the current JSON object
    QUERY=$(echo "$item" | jq -r '.query')
    RESPONSE=$(echo "$item" | jq -r '.response')

    printf "$QUERY_NUM: $QUERY => "

    # Construct the JSON payload for the request
    JSON=$(jq -n --arg query "$QUERY" \
        '{query: $query, startTime: "2024-10-29T00:00:00.000Z", endTime: "2024-11-29T23:00:00.000Z"}')

    # Measure the time taken to execute the query
    start_time=$(date +%s%3)
    curl  -H "Content-Type: application/json" -k -XPOST -u "admin:admin" "$P_URL/api/v1/query" --data "${JSON}"
    end_time=$(date +%s%3)
    elapsed_time=$((end_time - start_time))

    echo " (${elapsed_time}ms)"
    echo "${QUERY_NUM},${elapsed_time}" >> result.csv

    QUERY_NUM=$((QUERY_NUM + 1))

done;
