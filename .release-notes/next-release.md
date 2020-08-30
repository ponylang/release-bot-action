## Allow for setting the default branch

GitHub is in the process of changing the default branch for all newly created repositories from `master` to `main`. When that happens, this action will stop working for any new repos as it has `master` hardcoded as the default branch.

With this change, release-bot-action now takes an optional input parameter `default_branch` that can be used to change what the default branch of the repo is.

The default branch is the branch that we push back changelog, release note, and other changes. The default is set to `main` to be forward compatible with what will become standard on GitHub. Because `main` was chosen as the default, **this is a breaking change**.

**All repositories still using `master` as the default branch will need to set the `default_branch` value to `master` to continue working** when they upgrade to a version of release-bot-action containing this commit.

