# Release-bot action

Multiple workflows are required as part of the standard Pony release process that this bot encompasses. You will need 3 different workflow files.

A release is started by tagging the HEAD commit of a repo with a tag that looks like:

`release-x.y.z` where `x.y.z` is the version to release; e.g. 0.1.0

When the tag is pushed, it will trigger the start-a-release section of the workflow below. See [scripts/start-a-release.bash](scripts/start-a-release.bash) for full-details. When start-a-release finishes, it will delete the `release-x.y.z` tag and push a new tag `x.y.z` that triggers the release step.

Each library or application will have it's own release steps that are needed. They should be supplied as a series of steps in a **release.yml** (see below). Each of those steps will be a requirement to trigger the trigger-release-announcement step.

trigger-release-announcement pushes a new tag `announce-x.y.z` that will trigger the next and final step in the process. The trigger-release-announcement step exists so that if any build artifact portion of the release process fails, it can be completed by hand and then, a human can push a `announce-x.y.z` tag to start the final step in the release process.

announce-a-release will post:

- Post the release notes to the release section of GitHub
- Post a notification of the release to the #announce stream on Zulip
- Add a notice to the open Last Week in Pony issue

Once announce-a-release has completed, the release process is done. For more in-depth details, please see each of the respective scripts in [scripts](scripts/).

**N.B.** The environment variable `RELEASE_TOKEN` that is required by each step **must** be a personal access token with `public_repo` access. You can not use the `GITHUB_TOKEN` environment variable provided by GitHub's action environment. If you try to use `GITHUB_TOKEN`, no additional steps will trigger after start-a-release has completed.

## Example workflows

### start-a-release

Starts the release process.

Requires that your repo have Pony standard CHANGELOG and VERSION files.

**start-a-release.yml**:

```yml
name: Start a release

on:
  push:
    tags: release-*.*.*

jobs:
  start-a-release:
    name: Start a release
    runs-on: ubuntu-latest
    container:
      image: ponylang/shared-docker-ci-release:20191107
    steps:
      - uses: actions/checkout@v1
      - name: Start
        uses: ponylang/release-bot-action@0.1.0
        with:
          step: start-a-release
          git_user_name: "Ponylang Main Bot"
          git_user_email: "ponylang.main@gmail.com"
        env:
          RELEASE_TOKEN: ${{ secrets.RELEASE_TOKEN }}
```

## trigger-release-announcement

Triggers the announcement of the release.

Should be run after all release artifact building steps are done. For an application, this would mean that all artifacts have been uploaded to Cloudsmith and any Docker images were built.

**release.yml**:

```yml
name: Release

on:
  push:
    tags:
      - \d+.\d+.\d+

jobs:
  # Artifact building steps go here

  trigger-release-announcement:
    name: Trigger release announcement
    runs-on: ubuntu-latest
    container:
      image: ponylang/shared-docker-ci-release:20191107
    needs: [ARTIFACT_BUILDING_STEPS_HERE]
    steps:
      - uses: actions/checkout@v1
      - name: Trigger
        uses: ponylang/release-bot-action@0.1.0
        with:
          step: trigger-release-announcement
          git_user_name: "Ponylang Main Bot"
          git_user_email: "ponylang.main@gmail.com"
        env:
          RELEASE_TOKEN: ${{ secrets.RELEASE_TOKEN }}
```

## announce-a-release

Announces a release after artifacts have been built:

- Publishes release notes to GitHub
- Announces in the #announce stream of Zulip
- Adds a note about the release to LWIP

**announce-a-release.yml**:

```yml
name: Announce a release

on:
  push:
    tags: announce-*.*.*

jobs:
  announce-a-release:
    name: Announce a release
    runs-on: ubuntu-latest
    container:
      image: ponylang/shared-docker-ci-release:20191107
    steps:
      - uses: actions/checkout@v1
      - name: Announce
        uses: ponylang/release-bot-action@0.1.0
        with:
          step: announce-a-release
          git_user_name: "Ponylang Main Bot"
          git_user_email: "ponylang.main@gmail.com"
        env:
          ASSET_NAME: "My awesome application/library"
          RELEASE_TOKEN: ${{ secrets.RELEASE_TOKEN }}
          ZULIP_TOKEN: ${{ secrets.ZULIP_TOKEN }}
```
