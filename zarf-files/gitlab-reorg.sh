#!/bin/bash

set -euo pipefail

./glab config set -g host "$2"

./glab config set -g skip_tls_verify true --host "$2"

./glab auth login -t "$1" -h "$2"

PROJECTS=$(./glab api projects | ./jq '.[] | [.id, .name, .path, .visibility] | @sh' | sed 's/"//g' | sed "s/'//g" | sed "s/ /,/g")

for project in $PROJECTS; do

  project_id=$(echo $project | cut -d ',' -f1)
  project_name=$(echo $project | cut -d ',' -f2)
  project_path=$(echo $project | cut -d ',' -f3)

  if echo "$project_name" | grep -q -E -- '-[0-9]{4,}' || echo "$project_path" | grep -q -E -- '-[0-9]{4,}'; then
    new_name=$(echo $project_name | sed -E 's/-([0-9]{4,})//g')
    new_path=$(echo $project_path | sed -E 's/-([0-9]{4,})//g')
    new_visibility="public"

    echo "Renaming $project_name to $new_name"

    ./glab api --method PUT projects/$project_id -f name=$new_name -f path=$new_path -f visibility=$new_visibility --silent
  fi
done
