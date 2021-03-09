#!/bin/bash

# Starts the release process by:
#
# - Getting latest changes on the default branch
# - Updating version in
#   - VERSION
#   - corral.json
#   - CHANGELOG.md
# - Pushing updated VERSION and CHANGELOG.md back to the default branch
# - Pushing tag to kick off building artifacts
# - Adding a new "unreleased" section to CHANGELOG
# - Pushing updated CHANGELOG back to the default branch
#
# Tools required in the environment that runs this:
#
# - bash
# - changelog-tool
# - git
# - jq

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

if [[ -z "${GITHUB_REPOSITORY}" ]]; then
  echo -e "\e[31mName of this repository needs to be set in GITHUB_REPOSITORY."
  echo -e "\e[31mShould be in the form OWNER/REPO, for example:"
  echo -e "\e[31m     ponylang/ponyup"
  echo -e "\e[31mExiting.\e[0m"
  exit 1
fi

if [[ -z "${RELEASE_TOKEN}" ]]; then
  echo -e "\e[31mA personal access token needs to be set in RELEASE_TOKEN."
  echo -e "\e[31mIt should not be secrets.GITHUB_TOKEN. It has to be a"
  echo -e "\e[31mpersonal access token otherwise next steps in the release"
  echo -e "\e[31mprocess WILL NOT trigger."
  echo -e "\e[31mPersonal access tokens are in the form:"
  echo -e "\e[31m     TOKEN"
  echo -e "\e[31mfor example:"
  echo -e "\e[31m     1234567890"
  echo -e "\e[31mExiting.\e[0m"
  exit 1
fi

# no unset variables allowed from here on out
# allow above so we can display nice error messages for expected unset variables
set -o nounset

PUSH_TO="https://${RELEASE_TOKEN}@github.com/${GITHUB_REPOSITORY}.git"

# Extract version from tag reference
# Tag ref version: "refs/tags/release-1.0.0"
# Version: "1.0.0"
VERSION="${GITHUB_REF/refs\/tags\/release-/}"

# this doesn't account for the default changing commit. It ssumes we are HEAD
# or can otherwise push without issue.
git checkout "${INPUT_DEFAULT_BRANCH}"
git pull

# update VERSION
echo -e "\e[34mUpdating VERSION to ${VERSION}\e[0m"
echo "${VERSION}" > VERSION

# update version in corral.json if it exists
if test -f "corral.json"; then
  echo -e "\e[34mUpdating VERSION in corral.json to ${VERSION}\e[0m"
  jq ".info.version = \"${VERSION}\"" corral.json > corral.tmp
  mv corral.tmp corral.json
fi

# version the changelog
echo -e "\e[34mUpdating CHANGELOG.md for release\e[0m"
changelog-tool release "${VERSION}" -e

# commit "version" updates
echo -e "\e[34mCommiting VERSION and CHANGELOG.md changes\e[0m"
git add CHANGELOG.md VERSION
if test -f "corral.json"; then
  echo -e "\e[34mCommiting corral.json changes\e[0m"
  git add corral.json
fi
git commit -m "${VERSION} release"

# tag release
echo -e "\e[34mTagging for release to kick off building artifacts\e[0m"
git tag -a "${VERSION}" -m "Version ${VERSION}"

# push to release to remote
echo -e "\e[34mPushing commited changes back to ${INPUT_DEFAULT_BRANCH}\e[0m"
git push "${PUSH_TO}" "${INPUT_DEFAULT_BRANCH}"
echo -e "\e[34mPushing ${VERSION} tag\e[0m"
git push "${PUSH_TO}" "${VERSION}"

# pull again, just in case, odds of this being needed are really slim
git pull

# update CHANGELOG for new entries
echo -e "\e[34mAdding new 'unreleased' section to CHANGELOG.md\e[0m"
changelog-tool unreleased -e

# commit changelog and push to ${INPUT_DEFAULT_BRANCH}
echo -e "\e[34mCommiting CHANGELOG.md change\e[0m"
git add CHANGELOG.md
git commit -m "Add unreleased section to CHANGELOG post ${VERSION} release"

echo -e "\e[34mPushing CHANGELOG.md\e[0m"
git push "${PUSH_TO}" "${INPUT_DEFAULT_BRANCH}"

# delete release-VERSION tag
echo -e "\e[34mDeleting no longer needed remote tag release-${VERSION}\e[0m"
git push --delete "${PUSH_TO}" "release-${VERSION}"
