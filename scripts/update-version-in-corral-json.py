#!/usr/bin/python3
# pylint: disable=C0103
# pylint: disable=C0114

import json
import os
import os.path
import re
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

if not os.path.isfile('corral.json'):
    print(ERROR + "Unable to find corral.json. Exiting." + ENDC)
    sys.exit(1)

print(INFO + "Updating version in corral.json to " + version + ENDC)
with open('corral.json', 'r+') as cjson:
    corral_data = json.load(cjson)
    corral_data['info']['version'] = version
    cjson.seek(0)
    json.dump(corral_data, cjson, indent = 2)
    cjson.write("\n")
    cjson.truncate()

print(INFO + "Commiting corral.json changes" + ENDC)
git.add('corral.json')
if not git.status('-s'):
    print(INFO + "No changes. Exiting." + ENDC)
    sys.exit(0)
git.commit('-m',
    f'Update corral.json in preparation for {version} release')

push_failures = 0
while True:
    try:
        print(INFO + "Pushing updated corral.json." + ENDC)
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
