FROM ponylang/changelog-tool:release AS changelog-tool
FROM alpine:3.12

RUN apk add --update --no-cache \
  git \
  py3-pip

RUN pip3 install \
  gitpython \
  pygithub==1.54.1 \
  pylint \
  pyyaml \
  zulip

COPY --from=changelog-tool /usr/local/bin/changelog-tool /usr/local/bin/changelog-tool

COPY entrypoint /entrypoint
COPY scripts/ /commands/

ENV PATH "/commands:$PATH"

RUN chmod a+x /commands/*
RUN chmod a+x /entrypoint

ENTRYPOINT ["/entrypoint"]
