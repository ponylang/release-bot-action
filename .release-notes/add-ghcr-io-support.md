## Add support for GHCR.io

We've added support for an additional registry to our two commands that were registry specific.

`update-action-to-use-docker-image-to-run-action` now takes an environment variable `REGISTRY` to indicate which registry to use.

`update-version-in-README` now support changing docker urls for both the default (none) and for urls targeting `ghcr.io`.

See the README for updated usage instructions for `update-action-to-use-docker-image-to-run-action`. You don't need to make any changes for related to the `update-version-in-README` change.
