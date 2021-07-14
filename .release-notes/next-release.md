## Add support for ponyc's specialized build requirements

We build ponyc in CirrusCI, not GitHub actions. We do this because we often need to build LLVM from source and GitHub doesn't provide execution environments that are powerful enough. This results in a change where we can't use a stock release-bot `trigger-release-announcement` command.

When the ponyc workflow goes to trigger release announcements, the tag used to build isn't available so the version needs to be provided via the `CUSTOM_VERSION` environment variable that is added in this change.

This functionality should have been included in 0.6.0 but was missed.

