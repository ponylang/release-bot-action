#!/bin/bash

# Deletes the tag we used to trigger the announce step
#
# Tools required in the environment that runs this:
#
# - bash
# - git

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

if [[ -z "${GIT_USER_NAME}" ]]; then
  echo -e "\e[31mThe user name associated with git commits needs to be set in "
  echo -e "\e[31mGIT_USER_NAME."
  echo -e "\e[31mExiting.\e[0m"
  exit 1
fi

if [[ -z "${GIT_USER_EMAIL}" ]]; then
  echo -e "\e[31mThe email address associated with git commits needs to be set "
  echo -e "\e[31min GIT_USER_EMAIL."
  echo -e "\e[31mExiting.\e[0m"
  exit 1
fi

git config --global user.name "${GIT_USER_NAME}"
git config --global user.email "${GIT_USER_EMAIL}"
git config --global push.default simple

# no unset variables allowed from here on out
# allow above so we can display nice error messages for expected unset variables
set -o nounset

# Extract version from tag reference
# Tag ref version: "refs/tags/announce-1.0.0"
# Version: "1.0.0"
VERSION="${GITHUB_REF/refs\/tags\/announce-/}"

# delete announce-VERSION tag
echo -e "\e[34mDeleting no longer needed remote tag announce-${VERSION}\e[0m"
git push --delete origin "announce-${VERSION}"
