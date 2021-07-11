#!/usr/bin/python3
# pylint: disable=C0103
# pylint: disable=C0114

import os
import os.path
import re
import sys
import git

ENDC = '\033[0m'
ERROR = '\033[31m'
INFO = '\033[34m'
NOTICE = '\033[33m'

# validate env
if 'GIT_USER_NAME' not in os.environ:
    print(ERROR + "GIT_USER_NAME needs to be set in env." + ENDC)
    print(ERROR + "It can be set in a GitHub action by passing" + ENDC)
    print(ERROR + "`git_user_name` to the step in a `with` block." + ENDC)
    print(ERROR + "Exiting." + ENDC)
    sys.exit(1)

if 'GIT_USER_EMAIL' not in os.environ:
    print(ERROR + "GIT_USER_EMAIL needs to be set in env." + ENDC)
    print(ERROR + "It can be set in a GitHub action by passing" + ENDC)
    print(ERROR + "`git_user_name` to the step in a `with` block." + ENDC)
    print(ERROR + "Exiting." + ENDC)
    sys.exit(1)

# version is in the form of "refs/tags/release-1.0.0" where the version is 1.0.0
version = re.sub('refs/tags/release-', '', os.environ['GITHUB_REF'])

git = git.Repo(os.environ['GITHUB_WORKSPACE']).git
print(INFO + "Setting up git configuration." + ENDC)
git.config('--global', 'user.name', os.environ['GIT_USER_NAME'])
git.config('--global', 'user.email', os.environ['GIT_USER_EMAIL'])
git.config('--global', 'branch.autosetuprebase', 'always')

print(INFO + "Tagging for release to kick off creating artefacts" + ENDC)
git.tag('-a', version, '-m', f'Version {version}')

print(INFO + "Pushing " + version + " tag" + ENDC)
git.push('origin', version)

print(INFO + "Deleting no longer needed remote tag release-" + version + ENDC)
git.push('--delete', 'origin', f'release-{version}')
