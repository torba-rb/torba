## Unreleased

## Version 0.4.0

### Enhancements

* The exception that gets raised during `torba verify` now list the missing
  packages

## Version 0.3.1

### Bug fixes

* Fix no asset found when a CSS url contains "?#iefix" or "#svg-fragment"

## Version 0.3.0

### Enhancements

* Rails setup automatically populates `Rails.application.config.assets.precompile`
  If libraries added via Torba have image/font content, you can remove it from
  that list, no need for manual manipulation
* Support .tar.gz remote sources
* Support npm packages

## Version 0.2.1

### Bug fixes

* Cached GithubRelease remote contains in path repository name, not nameless
  version

## Version 0.2.0

### Enhancements

* Name for GH releases can be optional
* Cached zip remote contains URL filename in path for better introspection
* GithubRelease remote: introduce #repository_user, #repository_name

### Bug fixes

* Display actual exception (if any) instead of SystemExitError for pow
* Remote source always returns absolute path even if Torba.home_path/cache_path
  is relative to current directory

## Version 0.1.1

### Bug fixes

* Fail fast and report on 404 resources
