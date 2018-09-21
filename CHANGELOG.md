# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/en/1.0.0/)
and this project adheres to [Semantic Versioning](http://semver.org/spec/v2.0.0.html).

## [Unreleased]
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

[Unreleased]: https://github.com/zenaton/zenaton-ruby/compare/v0.2.3...HEAD
[0.2.3]: https://github.com/zenaton/zenaton-ruby/compare/v0.2.2...v0.2.3
[0.2.2]: https://github.com/zenaton/zenaton-ruby/compare/v0.2.1...v0.2.2
[0.2.1]: https://github.com/zenaton/zenaton-ruby/compare/v0.2.0...v0.2.1
[0.2.0]: https://github.com/zenaton/zenaton-ruby/compare/v0.1.1...v0.2.0
[0.1.1]: https://github.com/zenaton/zenaton-ruby/compare/v0.1.0...v0.1.1
