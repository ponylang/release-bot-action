#!/usr/bin/python3
# pylint: disable=C0103
# pylint: disable=C0114

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

# Get repository and version names from the environment
# version is in the form of "refs/tags/release-1.0.0" where the version is 1.0.0
repository = os.environ['GITHUB_REPOSITORY']
version = re.sub('refs/tags/release-', '', os.environ['GITHUB_REF'])

git = git.Repo(os.environ['GITHUB_WORKSPACE']).git
print(INFO + "Setting up git configuration." + ENDC)
git.config('--global', 'user.name', os.environ['GIT_USER_NAME'])
git.config('--global', 'user.email', os.environ['GIT_USER_EMAIL'])
git.config('--global', 'branch.autosetuprebase', 'always')

# what to find and what to replace it with
subs = [
    (fr'docker://{repository}:\d+\.\d+\.\d+',
     f'docker://{repository}:{version}'),
    (fr'{repository}@\d+\.\d+\.\d+',
     f'{repository}@{version}'),
    (fr'corral add github.com/{repository}.git -(-version|v) \d+\.\d+\.\d+',
     fr'corral add github.com/{repository}.git -\1 {version}'
    )
]

# find the README
readme_file_options = [
    "README.md",
    "README.rst"
]

readme_file = ""
for rfo in readme_file_options:
    if os.path.isfile(rfo):
        readme_file = rfo
        break


if not readme_file:
    print(ERROR + "Unable to find README. Exiting." + ENDC)
    sys.exit(1)

# open README and update with new version
print(INFO + "Updating versions in " + readme_file + " to " + version + ENDC)
with open(readme_file, "r+") as readme:
    text = readme.read()
    for sub in subs:
        (find, replace) = sub
        text = re.sub(find, replace, text)
    readme.seek(0)
    readme.write(text)
    readme.truncate()

print(INFO + "Adding git changes." + ENDC)
git.add(readme_file)
if not git.status("-s"):
    print(INFO + "No changes. Exiting." + ENDC)
    sys.exit(0)
git.commit('-m',
    f'Update {readme_file} examples to reflect new version {version}')

push_failures = 0
while True:
    try:
        print(INFO + "Pushing updated README." + ENDC)
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
