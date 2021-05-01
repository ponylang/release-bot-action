## Create images on release

Permanant, unchanging images for this action are now available in DockerHub and will be updated on each release. See our examples for more details on how to use.

## Replace "step" input parameter with overriding of entrypoint

Previously, when configuring the release-bot, you would indicate which step should be run like:

```yml
        with:
          step: start-a-release
          git_user_name: "Ponylang Main Bot"
          git_user_email: "ponylang.main@gmail.com"
```

`step` as an input option has been removed and replaced by `entrypoint`. `entrypoint` is an existing option that GitHub actions supports for changing the script to run from within an action.

Previously, the steps where:

- start-a-release
- trigger-release-announcement
- announce-a-release

Those steps have been replaced with the following corresponding entrypoints:

- start-a-release.bash
- trigger-release-announcement.bash
- announce-a-release.bash

The aforementioned configuration from above would now be:

```yml
        with:
          entrypoint: start-a-release.bash
          git_user_name: "Ponylang Main Bot"
          git_user_email: "ponylang.main@gmail.com"
```

## Switch supported actions/checkout from v1 to v2

We've switched from supporting `actions/checkout@v1` to `actions/checkout@v2`.

The are a few changes to configuration of release-bot that come along with this change. You should check out the examples in the README.md to see the latest on how to configure.

Highlights of changes:

- Use `actions/checkout@v2`
- `action/checkout` requires the setting `token` and `ref` values.
- Most workflows no longer require a release token being passed to the action, only to `actions/checkout`.
- Workflows no longer take a default branch. The default branch is now handled by `actions/checkout@v2`.

