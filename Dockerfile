FROM ponylang/changelog-tool:release AS changelog-tool
FROM alpine:3.12

COPY --from=changelog-tool /usr/local/bin/changelog-tool /usr/local/bin/changelog-tool

COPY entrypoint.sh /entrypoint.sh
COPY scripts/announce-a-release.bash /commands/announce-a-release.bash
COPY scripts/trigger-artifact-creation.bash /commands/trigger-artifact-creation.bash
COPY scripts/trigger-release-announcement.bash /commands/trigger-release-announcement.bash
COPY scripts/update-changelog-for-release.bash /commands/update-changelog-for-release.bash
COPY scripts/update-version-in-corral-json.bash /commands/update-version-in-corral-json.bash
COPY scripts/update-version-in-VERSION.bash /commands/update-version-in-VERSION.bash

ENV PATH "/commands:$PATH"

RUN chmod a+x /commands/*

RUN apk add --update --no-cache \
  bash \
  curl \
  jq \
  git \
  grep

ENTRYPOINT ["/entrypoint.sh"]
