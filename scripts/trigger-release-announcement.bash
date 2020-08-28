#!/bin/bash

# Triggers the running of the announce a release process
#
# - Creates announce-X.Y.Z tag and pushes to remote repo
#
# This script should be set up in CI to only run after all build artifact
# creation tasks have successfully run. It is built to be a separate script
# and ci step so that multi-artifacts could in theory be created and uploaded
# before a release is announced.
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
  echo -e "\e[31mA tag for the version we are announcing needs to be set in GITHUB_REF."
  echo -e "\e[31mThe tag should be in the following GitHub specific form:"
  echo -e "\e[31m    /refs/tags/X.Y.Z"
  echo -e "\e[31mwhere X.Y.Z is the version we are announcing"
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

if [[ -z "${VERSION}" ]]; then
  echo -e "\e[34mOptional VERSION environment variable found. Using it.\e[0m"
else
  # Extract version from tag reference
  # Tag ref version: "refs/tags/1.0.0"
  # Version: "1.0.0"
  # Note, this will only work if the action was kicked off by the push of tag.
  # Anything else will result in the ref being something like
  # "refs/heads/master" and the pushed tag will be something 'incorrect' like
  # "announce-refs/heads/master".
  # If you are using this action and it isn't triggered by a tag push, you must
  # use the optional VERSION environment variable instead of falling back to
  # the default behavior of extracting the version from GITHUB_REF.
  echo -e "\e[34mExtracting version from GITHUB_REF.\e[0m"
  VERSION="${GITHUB_REF/refs\/tags\//}"
fi

# tag for announcement
echo -e "\e[34mTagging to kick off release announcement\e[0m"
git tag "announce-${VERSION}"

# push tag
echo -e "\e[34mPushing announce-${VERSION} tag\e[0m"
git push "${PUSH_TO}" "announce-${VERSION}"
