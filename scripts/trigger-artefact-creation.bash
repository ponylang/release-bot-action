#!/bin/bash

# Kicks off "actual release process" by creating a tag in the form X.Y.Z
# and cleans finishes off the "pre-release steps" by deleting the
# "release-X.Y.Z" tag that triggers the beginning stages of a release.
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
  echo -e "\e[31m    /refs/tags/release-X.Y.Z"
  echo -e "\e[31mwhere X.Y.Z is the version we are releasing"
  echo -e "\e[31mExiting.\e[0m"
  exit 1
fi

git config --global user.name "${INPUT_GIT_USER_NAME}"
git config --global user.email "${INPUT_GIT_USER_EMAIL}"
git config --global push.default simple

# no unset variables allowed from here on out
# allow above so we can display nice error messages for expected unset variables
set -o nounset

# Extract version from tag reference
# Tag ref version: "refs/tags/release-1.0.0"
# Version: "1.0.0"
VERSION="${GITHUB_REF/refs\/tags\/release-/}"

# tag release
echo -e "\e[34mTagging for release to kick off creating artefacts\e[0m"
git tag -a "${VERSION}" -m "Version ${VERSION}"

echo -e "\e[34mPushing ${VERSION} tag\e[0m"
git push origin "${VERSION}"

# delete release-VERSION tag
echo -e "\e[34mDeleting no longer needed remote tag release-${VERSION}\e[0m"
git push --delete origin "release-${VERSION}"
