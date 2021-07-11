#!/usr/bin/python3
# pylint: disable=C0103
# pylint: disable=C0114

import os
import os.path
import re
import subprocess
import sys
import git
from git.exc import GitCommandError

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

if not os.path.isfile('CHANGELOG.md'):
    print(ERROR + "Unable to find CHANGELOG.md. Exiting." + ENDC)
    sys.exit(1)

print(INFO + "Updating CHANGELOG.md for release" + ENDC)
try:
    subprocess.run(['changelog-tool', 'release', version, '-e'],
        capture_output=True,
        text=True,
        check=True)
except subprocess.CalledProcessError as e:
    print(ERROR + "Unable to version for release." + ENDC)
    print(ERROR + e.stdout + ENDC)
    print(ERROR + e.stderr + ENDC)

print(INFO + "Commiting CHANGELOG.md changes" + ENDC)
git.add('CHANGELOG.md')
if not git.status('-s'):
    print(INFO + "No changes. Exiting." + ENDC)
    sys.exit(0)
git.commit('-m',
    f'Update CHANGELOG.md in preparation for {version} release')

push_failures = 0
while True:
    try:
        print(INFO + "Pushing updated CHANGELOG.md." + ENDC)
        git.push()
        break
    except GitCommandError:
        push_failures += 1
        if push_failures <= 5:
            print(NOTICE
                  + "Failed to push. Going to pull and try again."
                  + ENDC)
            git.pull(rebase=True)
        else:
            print(ERROR + "Failed to push again. Giving up." + ENDC)
            raise
