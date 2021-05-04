#!/bin/bash

# Validates that there is a CHANGELOG entry for the given tag.
# The only reasons for it to be missing are:
#
# - misconfigured workflows
# - user mistake in pushing `x.y.z` tag instead of `release-x.y.z`
#
# Tools required in the environment that runs this:
#
# - bash
# - changelog-tool

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

# no unset variables allowed from here on out
# allow above so we can display nice error messages for expected unset variables
set -o nounset

# Extract version from tag reference
# Tag ref version: "refs/tags/release-1.0.0"
# Version: "1.0.0"
VERSION="${GITHUB_REF/refs\/tags\//}"

# If we can get the tag from the changelog-tool then at it was correctly setup
# for release

changelog-tool get "${VERSION}"
