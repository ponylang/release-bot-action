FROM ghcr.io/ponylang/changelog-tool:release AS changelog-tool
FROM ubuntu:20.04

RUN apt-get update \
  && apt-get install -y --no-install-recommends \
     git \
     python3-pip \
  && rm -rf /var/lib/apt/lists/* \
  && apt-get -y autoremove --purge \
  && apt-get -y clean

RUN pip3 install \
  gitpython==3.1.18 \
  pygithub==1.55 \
  pylint==2.9.3 \
  pyyaml==5.4.1 \
  zulip==0.8.0

COPY --from=changelog-tool /usr/local/bin/changelog-tool /usr/local/bin/changelog-tool

COPY entrypoint /entrypoint
COPY scripts/ /commands/

ENV PATH "/commands:$PATH"

RUN chmod a+x /commands/*
RUN chmod a+x /entrypoint

ENTRYPOINT ["/entrypoint"]
