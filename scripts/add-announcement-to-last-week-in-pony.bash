#!/bin/bash

# Adds a note about a release to the Last Week in Pony newsletter
#
# Tools required in the environment that runs this:
#
# - bash
# - curl
# - jq

set -o errexit

# Verify ENV is set up correctly
# We validate all that need to be set in case, in an absolute emergency,
# we need to run this by hand. Otherwise the GitHub actions environment should
# provide all of these if properly configured
if [[ -z "${GITHUB_REF}" ]]; then
  echo -e "\e[31mThe release tag needs to be set in GITHUB_REF."
  echo -e "\e[31mThe tag should be in the following GitHub specific form:"
  echo -e "\e[31m    /refs/tags/announce-X.Y.Z"
  echo -e "\e[31mwhere X.Y.Z is the version we are announcing"
  echo -e "\e[31mExiting.\e[0m"
  exit 1
fi

if [[ -z "${GITHUB_REPOSITORY}" ]]; then
  echo -e "\e[31mName of this repository needs to be set in GITHUB_REPOSITORY."
  echo -e "\e[31mShould be in the form OWNER/REPO, for example:"
  echo -e "\e[31m     ponylang/ponyup"
  echo -e "\e[31mExiting.\e[0m"
  exit 1
fi

if [[ -z "${RELEASE_TOKEN}" ]]; then
  echo -e "\e[31mA personal access token with 'public repo' access"
  echo -e "needs to be set in RELEASE_TOKEN."
  echo -e "Exiting.\e[0m"
  exit 1
fi

# no unset variables allowed from here on out
# allow above so we can display nice error messages for expected unset variables
set -o nounset

# Extract version from tag reference
# Tag ref version: "refs/tags/announce-1.0.0"
# Version: "1.0.0"
VERSION="${GITHUB_REF/refs\/tags\/announce-/}"

# Update Last Week in Pony
echo -e "\e[34mAdding release to Last Week in Pony...\e[0m"

result=$(curl https://api.github.com/repos/ponylang/ponylang-website/issues?labels=last-week-in-pony)

lwip_url=$(echo "${result}" | jq -r '.[].url')
if [ "$lwip_url" != "" ]; then
  body="
Version ${VERSION} of ${GITHUB_REPOSITORY} has been released.
See the [release notes](https://github.com/${GITHUB_REPOSITORY}/releases/tag/${VERSION}) for more details.
"

  jsontemplate="
  {
    \"body\":\$body
  }
  "

  json=$(jq -n \
  --arg body "$body" \
  "${jsontemplate}")

  result=$(curl -s -X POST "$lwip_url/comments" \
    -H "Content-Type: application/x-www-form-urlencoded" \
    -u "${RELEASE_TOKEN}" \
    --data "${json}")

  rslt_scan=$(echo "${result}" | jq -r '.id')
  if [ "$rslt_scan" != null ]; then
    echo -e "\e[34mRelease notice posted to LWIP\e[0m"
  else
    echo -e "\e[31mUnable to post to LWIP, here's the curl output..."
    echo -e "\e[31m${result}\e[0m"
  fi
else
  echo -e "\e[31mUnable to post to Last Week in Pony."
  echo -e "Can't find the issue.\e[0m"
fi
