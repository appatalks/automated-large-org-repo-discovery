#!/bin/bash
# Export ALL Organization Repositories using REST and Pagination
#
# Example Usage:
# $ bash run_discovery.sh
#     Please enter the organization name:
#     My-Super-Cool-ORG
#
# IMPORTANT: Use the best Authentication for your case
# https://docs.github.com/en/graphql/overview/rate-limits-and-node-limits-for-the-graphql-api
#
# Minimum Scopes: repo, read:org
# NOTE: Delay between API calls is hardcoded for 6 seconds, with page progress discovery printed to screen.

# Check if the required GitHub API token is set
if [ -z "$TOKEN" ]; then
  echo "Error: Please set the GitHub API token in the TOKEN environment variable."
  echo "Example: $ export TOKEN=ghp_****"
  exit 1
fi

# Ask for organization name
echo "Please enter the organization name: "
read orgName

# Set up GitHub API url
url="https://api.github.com/orgs/$orgName/repos?per_page=100"

# Define an empty array to store the repositories
repos=()

# Set the initial page to 1
page=1

# Use a while loop to iterate through all the pages
while true; do
  # Send GET request to the current page URL and retrieve the repositories
  page_repos=$(curl -s -H "Authorization: token $TOKEN" "$url&page=$page" | jq -r '.[] | .name, .private')

# Add the repositories to the array one by one
  while IFS= read -r repo; do
    repos+=("$repo")
  done <<< "$page_repos"

  # Send GET request to GitHub API and retrieve the response headers
  headers=$(curl -s -I -H "Authorization: token $TOKEN" "$url&page=$page")

  # Extract the "link" header
  link_header=$(echo "$headers" | awk '/^link:/ {print $0}')
  echo ""
  echo "Discovering Repo Listing Standby: "
  echo ""
  echo $link_header

  # Check if "rel=next" is in the "link" header
  if echo "$link_header" | grep -q 'rel="next"'; then
    # "rel=next" is in the "link" header, so there is a next page
    next_page=1
  else
    # "rel=next" is not in the "link" header, so there is no next page
    next_page=0
  fi

  # Check if there is a next page
  if [ "$next_page" -eq 0 ]; then
    # No next page, so break the loop
    break
  fi

  # Increment the page counter
  ((page++))

  # Add a delay of n second between each REST API request
  sleep 6
  done

  # Convert repos to array
  arr=(${repos[@]})

  # Iterate over arr by 2 (since each pair of entries is a repo name and its visibility)
  for ((i=0; i<${#arr[@]}; i+=2)); do
    visibility="Public"
    if [ "${arr[$i+1]}" = "true" ]; then
    visibility="Private"
    fi
    repoName="${arr[$i]}" 

    # Add all repository names to file for use in next scripts.
    date=$(date +"%Y-%m-%d_%H-%M")
    filename="/tmp/${date}_discovered_repositories.tmp"
    echo "$repoName" >> $filename 
  done

# Print Discovered Repos count
echo ""
echo "Discovered Repository Count: $(cat $filename | wc -l)"
echo "Repo Listing located in: $filename"
