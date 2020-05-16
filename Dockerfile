FROM ponylang/changelog-tool:release AS changelog-tool
FROM alpine

COPY --from=changelog-tool /usr/local/bin/changelog-tool /usr/local/bin/changelog-tool

COPY entrypoint.sh /entrypoint.sh
COPY scripts/announce-a-release.bash /announce-a-release.bash
COPY scripts/start-a-release.bash /start-a-release.bash
COPY scripts/trigger-release-announcement.bash /trigger-release-announcement.bash

RUN apk add --update bash \
  jq \
  git \
  grep \
  curl

ENTRYPOINT ["/entrypoint.sh"]
