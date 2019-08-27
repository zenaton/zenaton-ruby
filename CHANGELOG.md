# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/en/1.0.0/)
and this project adheres to [Semantic Versioning](http://semver.org/spec/v2.0.0.html).

## [Unreleased]
### Changes
- No longer load JSON core extensions. Use our own refinements to avoid clashes
  with frameworks and user code.

### Added
- (De)Serialization support for instances of Class.
- Execution context for tasks and workflows
- Optional `on_error_retry_delay` method handling task failures and specifying
  how many seconds to wait before retrying.

### Fixed
- Backport of ActiveSupport's `next_occurring` for older versions.

## [0.4.2] - 2019-08-05
### Added

- Added `intent_id` when dispatching workflows and tasks, sending events and
  pausing/resuming/stoping workflows.

### Fixed
- Fixed an error caused by a bad class name serialization when `as_json` is overrided (in rails for example).

## [0.4.1] - 2019-06-04
 ### Changes
- Fix symbol json encoding breaking compatibility with some gems

### Added
- Added `event_data` property when sending event

## [0.4.0] - 2019-03-25
### Added
- Calling `#dispatch` on tasks now allows to process tasks asynchronously

### Changes
- Update Zenaton engine URL to point to the new subdomain.

### Fixed
- When creating a `Wait` task which uses both `#at` (to specify time) and either
  `#day_of_month` or `#monday` et al (to set day), it was surprising that the
  wait task only waited for next week/month when it would make sense to wait for
  later the same day. For example, on a Monday at 1 p.m, it waits for a couple
  of hours if you create a wait task with `.monday(1).at("15")`. Otherwise the
  previous behaviour of waiting for next week is preserved.
- Fix encoding of query parameters when searching for existing workflows

## [0.3.1] - 2018-10-02
### Fixed
- [Serialization]: Serializing ActiveModel object should no longer raise an
  error

## [0.3.0] - 2018-09-24
### Changed
- Rename `on_day` method to `day_of_month`
- Improve error messages by using the message contained in the API response when
available.
- Rescue from new engine error when finding non existing workflow

## [0.2.3] - 2018-08-13
### Added
- Introduce this changelog file.

### Removed
- Dependency on httparty

## [0.2.2] - 2018-08-10
### Fixed
- [Serialization]: Distinct objects, even if equal to one another, now map to
  distinct entries in the data store.

## [0.2.1] - 2018-08-10
### Added
- Serializer now handles the same objects as Ruby's built-in JSON library.
- Instructions on how to use the gem in a Ruby on Rails application.

### Changed
- Fixed typos and broken links in the readme

## [0.2.0] - 2018-08-08
### Added
- New serialization format for array and hashes. Currently running workflows
  should still be able to deserialize data in the old format.

### Fixed
- Arrays and hashes with circular structures no longer cause infinite loops when
  serializing.

## [0.1.1] - 2018-08-03
### Added
- Run test suite against all currently supported ruby versions
- Readme has a rubygems badge showing the current released version.

### Fixed
- Serialization should now be working on Ruby 2.3.

## 0.1.0 - 2018-08-03
### Added
- Initial release.

[Unreleased]: https://github.com/zenaton/zenaton-ruby/compare/v0.4.2...HEAD
[0.4.2]: https://github.com/zenaton/zenaton-ruby/compare/v0.4.1...v0.4.2
[0.4.1]: https://github.com/zenaton/zenaton-ruby/compare/v0.4.0...v0.4.1
[0.4.0]: https://github.com/zenaton/zenaton-ruby/compare/v0.3.1...v0.4.0
[0.3.1]: https://github.com/zenaton/zenaton-ruby/compare/v0.3.0...v0.3.1
[0.3.0]: https://github.com/zenaton/zenaton-ruby/compare/v0.2.3...v0.3.0
[0.2.3]: https://github.com/zenaton/zenaton-ruby/compare/v0.2.2...v0.2.3
[0.2.2]: https://github.com/zenaton/zenaton-ruby/compare/v0.2.1...v0.2.2
[0.2.1]: https://github.com/zenaton/zenaton-ruby/compare/v0.2.0...v0.2.1
[0.2.0]: https://github.com/zenaton/zenaton-ruby/compare/v0.1.1...v0.2.0
[0.1.1]: https://github.com/zenaton/zenaton-ruby/compare/v0.1.0...v0.1.1
