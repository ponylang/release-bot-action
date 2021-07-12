## Remove file extension from commands

Previously all the release-bot-commands included a file extension like '.py'. We've removed all file extensions to allow for us to change the implementation language in the future without it being a breaking change.

Where a command might previously have been `foo.py` it is now simply `foo`.
