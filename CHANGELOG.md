## Unreleased

## Version 1.1.1

### Enhancements

* Test files have been removed from the package to reduce
file size (and to spend less internet traffic too).

## Version 1.1.0

### Enhancements

* Thor dependency has been relaxed to support Rails 6.x.

## Version 1.0.1

### Bug fixes

* Fix unpacking tar.gz when running on unpriveleged containers

## Version 1.0.0

### Breaking changes

* Rails support has been removed. Use [torba-rails][torba-rails] instead.
* `torba/verify` no longer checks, whether it is executed within Rake task
  or not. This was a workaround for Rails support, which is no longer a goal
  of this gem.
* `torba/verify` no longer checks `TORBA_DONT_VERIFY` env variable. Same as
  above.

### Upgrading notes

If you are a non-Rails user, this should be a non-breaking update. In rare cases,
when you depend on old behaviour of `torba/verify`, please, add the conditionals
to your application code.

Rails users should:

1. Replace `gem "torba"` with `gem "torba-rails"` in the Gemfile.
2. Remove `require "torba/verify"` from `boot.rb`.
3. Remove `require "torba/rails"` from `application.rb`.
4. Unset obsolete `TORBA_DONT_VERIFY` env variable if present.

### Enhancements

* Rake task accepts a block to be executed before packing process

[torba-rails]: https://github.com/torba-rb/torba-rails

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
