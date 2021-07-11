## Split "announce-a-release" into multiple different commands

Previously, release-bot-action had a command `announce-a-release` that did multiple things. It:

- Published release notes to GitHub
- Announced the release in the #announce stream of the Pony Zulip
- Added a note about the release to LWIP
- Deleted the `announce-X.Y.Z` tag used to trigger the command
- Rotated the release notes

In keeping with our project to break release-bot-action into a series of fine-grained commands, announce-a-release has been broken apart into multiple commands that can be called from steps in a GitHub actions workflow to compose functionality together on a per-project basis.

Those new commands covered in detail in our updated `announce-a-release` example in README.md. The new step commands are:

- add-announcement-to-last-week-in-pony.bash
- delete-announcement-tag.bash
- publish-release-notes-to-github.bash
- rotate-release-notes.bash
- send-announcement-to-pony-zulip.bash
