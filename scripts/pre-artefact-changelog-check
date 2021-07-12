#!/usr/bin/python3
# pylint: disable=C0103
# pylint: disable=C0114

import os
import os.path
import re
import subprocess
import sys

ENDC = '\033[0m'
ERROR = '\033[31m'
INFO = '\033[34m'
NOTICE = '\033[33m'

# version is in the form of "refs/tags/release-1.0.0" where the version is 1.0.0
version = re.sub('refs/tags/', '', os.environ['GITHUB_REF'])

if not os.path.isfile('CHANGELOG.md'):
    print(ERROR + "Unable to find CHANGELOG.md. Exiting." + ENDC)
    sys.exit(1)

# Will error out if the CHANGELOG entry is missing
try:
    subprocess.run(['changelog-tool', 'get', version],
        capture_output=True,
        text=True,
        check=True)
except subprocess.CalledProcessError as e:
    print(ERROR + "Unable to find this release in CHANGELOG.md" + ENDC)
    print(ERROR + e.stdout + ENDC)
    print(ERROR + e.stderr + ENDC)
    print(ERROR + "Exiting." + ENDC)
    sys.exit(1)
