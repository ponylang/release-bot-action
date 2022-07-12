# Change Log

All notable changes to this project will be documented in this file. This project adheres to [Semantic Versioning](http://semver.org/) and [Keep a CHANGELOG](http://keepachangelog.com/).

## [unreleased] - unreleased

### Fixed

- Update to work with newer versions of git ([PR #57](https://github.com/ponylang/release-bot-action/pull/57))

### Added


### Changed


## [0.6.1] - 2021-07-14

### Added

- Add support for ponyc's specialized build requirements ([PR #51](https://github.com/ponylang/release-bot-action/pull/51))

## [0.6.0] - 2021-07-14

### Added

- Create images on release ([PR #31](https://github.com/ponylang/release-bot-action/pull/31))
- Add command to update the version in a README ([PR #37](https://github.com/ponylang/release-bot-action/pull/37))
- Add command to update the runner in action.yml files ([PR #38](https://github.com/ponylang/release-bot-action/pull/38))
- Add preartefact-changelog-check.bash command ([PR #42](https://github.com/ponylang/release-bot-action/pull/42))

### Changed

- Replace "step" input parameter with overriding of entrypoint ([PR #33](https://github.com/ponylang/release-bot-action/pull/33))
- Switch supported actions/checkout from v1 to v2 ([PR #34](https://github.com/ponylang/release-bot-action/pull/34))
- Split "start-a-release" into multiple different commands ([PR #35](https://github.com/ponylang/release-bot-action/pull/35))
- Split "announce-a-release" into multiple different commands ([PR #44](https://github.com/ponylang/release-bot-action/pull/44))
- Rewrite all bash commands in Python ([PR #46](https://github.com/ponylang/release-bot-action/pull/46))
- Remove file extension from commands ([PR #47](https://github.com/ponylang/release-bot-action/pull/47))

## [0.5.0] - 2021-03-09

### Changed

- Use annotated tags for releases ([PR #30](https://github.com/ponylang/release-bot-action/pull/30))

## [0.4.0] - 2021-02-07

### Fixed

- Update version in corral.json on release ([PR #28](https://github.com/ponylang/release-bot-action/pull/28))

### Changed

- Allow for setting the default branch ([PR #24](https://github.com/ponylang/release-bot-action/pull/24))

## [0.3.3] - 2020-08-30

### Fixed

- Fix broken trigger-release-announcement step ([PR #25](https://github.com/ponylang/release-bot-action/pull/25))

## [0.3.2] - 2020-08-30

### Added

- Allow for overriding how trigger release announcement step gets version information ([PR #23](https://github.com/ponylang/release-bot-action/pull/23))

## [0.3.1] - 2020-08-22

### Fixed

- Fix bash-ism in formatting for GitHub release notes ([PR #19](https://github.com/ponylang/release-bot-action/pull/19))

## [0.3.0] - 2020-08-13

### Changed

- Make ASSET_NAME hardcoded ([PR #11](https://github.com/ponylang/release-bot-action/pull/11))
- Remove empty line in Last Week in Pony announcement ([PR #12](https://github.com/ponylang/release-bot-action/pull/12))

## [0.2.2] - 2020-08-13

### Fixed

- Make .release-notes support optional ([PR #10](https://github.com/ponylang/release-bot-action/pull/10))

## [0.2.1] - 2020-08-12

### Added

- Add support for adding release notes as part of the release process ([PR #9](https://github.com/ponylang/release-bot-action/pull/9))

## [0.2.0] - 2020-06-06

### Changed

- Don't tie release commits to ponylang-main account ([PR #6](https://github.com/ponylang/release-bot-action/pull/6))

## [0.1.0] - 2020-05-17

### Added

- First initial working version

