#!/bin/bash

set -o errexit

# Set up GitHub credentials
# These are shared across all step types
git config --global user.name "${INPUT_GIT_USER_NAME}"
git config --global user.email "${INPUT_GIT_USER_EMAIL}"
git config --global push.default simple

# Determine step and run the corresponding script
case ${INPUT_STEP} in
  start-a-release)
    bash /start-a-release.bash
    ;;
  trigger-release-announcement)
    bash /trigger-release-announcement.bash
    ;;
  announce-a-release)
    bash /announce-a-release.bash
    ;;
  *)
    echo -e "\e[31mUnknown step. `step` should be one of: "
    echo -e "* start-a-release"
    echo -e "* trigger-release-announcement"
    echo -e "* announce-a-release\e[0m"
    exit 1;
esac
