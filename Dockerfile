FROM ponylang/changelog-tool:release AS changelog-tool
FROM alpine:3.12

COPY --from=changelog-tool /usr/local/bin/changelog-tool /usr/local/bin/changelog-tool

COPY entrypoint.sh /entrypoint.sh
COPY scripts/announce-a-release.bash /commands/announce-a-release.bash
COPY scripts/start-a-release.bash /commands/start-a-release.bash
COPY scripts/trigger-release-announcement.bash /commands/trigger-release-announcement.bash

ENV PATH "/commands:$PATH"

RUN chmod a+x /commands/*

RUN apk add --update --no-cache \
  bash \
  curl \
  jq \
  git \
  grep

ENTRYPOINT ["/entrypoint.sh"]
