FROM ponylang/changelog-tool:release AS changelog-tool
FROM alpine:3.12

RUN apk add --update --no-cache \
  bash \
  curl \
  jq \
  git \
  grep \
  py3-pip

RUN pip3 install \
  gitpython \
  pylint \
  pyyaml

COPY --from=changelog-tool /usr/local/bin/changelog-tool /usr/local/bin/changelog-tool

COPY entrypoint.sh /entrypoint.sh
COPY scripts/ /commands/

ENV PATH "/commands:$PATH"

RUN chmod a+x /commands/*

ENTRYPOINT ["/entrypoint.sh"]
