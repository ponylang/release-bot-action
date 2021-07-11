## Replaced all .bash commands with equivalent .py commands

As part of an internal cleanup, all commands written in bash have been rewritten to python and in the process, each was renamed. Full list of changes is below:

- add-announcement-to-last-week-in-pony.bash => add-announcement-to-last-week-in-pony.py
- add-unreleased-section-to-changelog.bash => add-unreleased-section-to-changelog.py
- delete-announcement-tag.bash => delete-announcement-tag.py
- pre-artefact-changelog-check.bash => pre-artefact-changelog-check.py
- publish-release-notes-to-github.bash => publish-release-notes-to-github.py
- rotate-release-notes.bash => rotate-release-notes.py
- send-announcement-to-pony-zulip.bash => send-announcement-to-pony-zulip.py
- trigger-artefact-creation.bash => trigger-artefact-creation.py
- trigger-release-announcement.bash => trigger-release-announcement.py
- update-changelog-for-release.bash => update-changelog-for-release.py
- update-version-in-corral-json.bash => update-version-in-corral-json.py
- update-version-in-VERSION.bash => update-version-in-VERSION.py

As part of this change, the input values to `send-announcement-to-pony-zulip.py` have changed from those to `send-announcement-to-pony-zulip.bash`. Whereas previously, a single environment variable called `ZULIP_TOKEN` was expected, we now need two `ZULIP_API_KEY` and `ZULIP_EMAIL`.
