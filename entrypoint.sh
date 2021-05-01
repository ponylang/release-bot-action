#!/bin/bash

set -o errexit

echo -e "\e[31m'entrypoint' must be set; it should be one of: "
echo -e "* /start-a-release.bash"
echo -e "* /trigger-release-announcement.bash"
echo -e "* /announce-a-release.bash\e[0m"
exit 1;

