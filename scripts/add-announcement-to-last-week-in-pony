#!/usr/bin/python3
# pylint: disable=C0103
# pylint: disable=C0114

import os
import re
import sys
from github import Github

ENDC = '\033[0m'
ERROR = '\033[31m'
INFO = '\033[34m'
NOTICE = '\033[33m'

# validate env
if 'RELEASE_TOKEN' not in os.environ:
    print(ERROR + "RELEASE_TOKEN needs to be set in env. Exiting." + ENDC)
    sys.exit(1)

# version is in the form of "refs/tags/release-1.0.0" where the version is 1.0.0
version = re.sub('refs/tags/announce-', '', os.environ['GITHUB_REF'])

release_repo = os.environ['GITHUB_REPOSITORY']

print(INFO + "Adding release to Last Week in Pony..." + ENDC)

g = Github(os.environ['RELEASE_TOKEN'])
repo = g.get_repo('ponylang/ponylang-website')
results = repo.get_issues(labels=['last-week-in-pony'])
if results.totalCount == 0:
    print(ERROR + "Unable to find Last Week in Pony issue. Exiting." + ENDC)
    sys.exit(1)

comment = (
    f'Version {version} of {release_repo} has been released.'
    f"\n\n"
    f'See the '
    f'[release notes](https://github.com/{release_repo}/releases/tag/{version})'
    f' for more details.'
)

lwip_issue = results[0]
lwip_issue.create_comment(comment)

print(INFO + "Release notice posted to Last Week in Pony" + ENDC)
