#!/bin/bash

# Sends a release announcement to the Pony Zulip
#
# Tools required in the environment that runs this:
#
# - bash
# - curl

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

if [[ -z "${ZULIP_TOKEN}" ]]; then
  echo -e "\e[31mA Zulip access token needs to be set in ZULIP_TOKEN."
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

# Send announcement to Zulip
message="
Version ${VERSION} of ${GITHUB_REPOSITORY} has been released.

See the [release notes](https://github.com/${GITHUB_REPOSITORY}/releases/tag/${VERSION}) for more details.
"

echo -e "\e[34mSending announcement to Zulip...\e[0m"

result=$(curl -s -X POST https://ponylang.zulipchat.com/api/v1/messages \
  -u "${ZULIP_TOKEN}" \
  -d "type=stream" \
  -d "to=announce" \
  -d "topic=${GITHUB_REPOSITORY}" \
  -d "content=${message}")

  echo "${result}"
