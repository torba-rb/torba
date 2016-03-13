## Unreleased

## Version 0.7.0

### Enhancements

* `torba show` command
* `torba open` command

## Version 0.6.0

### Enhancements

* Torba.cache_path= setter

### Bug fixes

* Handle stylesheets that mention nonexisting assets (e.g. with SCSS variables)

## Version 0.5.1

### Bug fixes

* Treat SASS/SCSS files as regular stylesheets

## Version 0.5.0

### Upgrading notes

Rails users are advised to remove manual execution of `torba pack` from
their deployment scripts, since the command now is a part of
`rake assets:precompile`.

### Enhancements

* Support deployment to Heroku
* `torba pack` is automatically injected into `rake assets:precompile`
  in Rails applications
* `torba install` command is a mapping for `torba pack`

### Bug fixes

* Retry 5 times if fetching a remote file fails

## Version 0.4.2

### Bug fixes

* Remote url() assets should not be given to asset_path
* Support both url(data: and url('data: in css

## Version 0.4.1

### Bug fixes

* Do not add the `.erb` extension for stylesheets that don't need it.

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
