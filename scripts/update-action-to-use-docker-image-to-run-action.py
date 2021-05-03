#!/usr/bin/python3
# pylint: disable=C0103
# pylint: disable=C0114

import os
import os.path
import re
import sys
import git
from git.exc import GitCommandError
import yaml

ENDC = '\033[0m'
ERROR = '\033[31m'
INFO = '\033[34m'
NOTICE = '\033[33m'

# validate action.yml exists
if not os.path.isfile("action.yml"):
    print(ERROR + "Unable to find action.yml. Exiting." + ENDC)
    sys.exit(1)

# Get repository and version names from the environment
# version is in the form of "refs/tags/release-1.0.0" where the version is 1.0.0
repository = os.environ['GITHUB_REPOSITORY']
version = re.sub('refs/tags/release-', '', os.environ['GITHUB_REF'])

git = git.Repo(os.environ['GITHUB_WORKSPACE']).git
print(INFO + "Setting up git configuration." + ENDC)
git.config('--global', 'user.name', os.environ['INPUT_GIT_USER_NAME'])
git.config('--global', 'user.email', os.environ['INPUT_GIT_USER_EMAIL'])
git.config('--global', 'branch.autosetuprebase', 'always')

# open README and update with new version
print(INFO + "Switching to prebuilt image as runner in action.yml" + ENDC)
with open("action.yml", "r+") as action_yml:
    text = yaml.safe_load(action_yml)
    text['runs']['image'] = f'docker://{repository}:{version}'
    action_yml.seek(0)
    yaml.dump(text, action_yml)
    action_yml.truncate()

print(INFO + "Adding git changes." + ENDC)
git.add("action.yml")
if not git.status("-s"):
    print(INFO + "No changes. Exiting." + ENDC)
    sys.exit(0)
git.commit('-m',
    f'Update action.yml to run with prebuilt docker image for new version {version}')

push_failures = 0
while True:
    try:
        print(INFO + "Pushing updated action.yml." + ENDC)
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
