## Unreleased

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
