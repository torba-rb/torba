# Torba

[![Build Status](https://img.shields.io/travis/torba-rb/torba.svg)](https://travis-ci.org/torba-rb/torba)
[![Gem version](https://img.shields.io/gem/v/torba.svg)](https://rubygems.org/gems/torba)

**Torba** is a [Bower][bower]-less asset manager for [Sprockets][sprockets]. It makes a local copy
of a JS/CSS library and puts it under Sprockets' [load path][sprockets-load-path].

## Name origin

"Торба" [[tǒːrba][torba-pronounce]] in Ukrainian and "torba" in Polish, Turkic languages can mean
"duffel bag", "gunny sack" or, more generally, any flexible container.

## Status

Production ready.

## Documentation

[Released version](http://rubydoc.info/gems/torba/0.5.0)

## Why

De facto approach, i.e. wrapping JS and CSS libraries in a gem, requires a
maintainer to constantly track changes in an upstream repository. Even more so, if a gem
maintainer stops using that specific library, the gem will eventually become abandoned.
Additionally, many libraries still have no gem wrappers.

Other alternatives:

* [rails-assets][rails-assets] relies on Bower *and* it is quite complex,
* [bower-rails][bower-rails] relies on Bower, see below for why this can be an issue.

Problems with the Bower:

* it is not a part of the Ruby ecosystem,
* frontend JS libraries are usually standalone (except for a potential jQuery dependency), so there's
  no need for a complex Bundler-like solution with tree-dependency resolution,
* often we can't use optimistic version constraints, because the JavaScript community does not consistenly apply the principles of [Semver][semver]. By specifying strict versions we use Bower as a complex facade for functionality that could be accomplished with curl.

## External dependencies

* curl
* unzip
* gzip
* tar

## Design limitations

* Torba doesn't do any version dependency resolution, it's up to you to specify the correct version of
  each asset package,
* Torba doesn't do any builds, you should use remote sources with pre-built assets.

## Installation

Add this line to your application's Gemfile and run `bundle`:

```ruby
gem 'torba'
```

### Rails

in boot.rb

```diff
 require 'bundler/setup' # Set up gems listed in the Gemfile.
+require 'torba/verify'
```

in config/application.rb

```diff
 # Require the gems listed in Gemfile, including any gems
 # you've limited to :test, :development, or :production.
 Bundler.require(*Rails.groups)
+
+require 'torba/rails'
```

## Usage

1. Create Torbafile at the project root and commit it.

2. Run `bundle exec torba pack`.

3. Add "require" [Sprockets directives][sprockets-directives] to your "application.js"
and/or "@import" [Sass directives][sass-import] to "application.css".

4. Non JS/CSS assets are automatically added to precompile list, nothing to do here.

If any changes made to the Torbafile, run `bundle exec torba pack` again.

### Torbafile

Torbafile is an assets specification. It is a plain text file that contains one or more
sections, each of them describes one remote source of assets.

Currently only zip, tar.gz archives, [Github releases][github-releases] and
[npm packages][npm] are supported.

#### Zip archive package

Allows to download and unpack asset package from any source accessible by curl.

The syntax is:

```ruby
zip "name", url: "..." [, import: %w(...)]
```

where "name" is an arbitrary name for the package, more on "import" below. For example,

```ruby
zip "scroll_magic", url: "https://github.com/janpaepke/ScrollMagic/archive/v2.0.0.zip"
```

#### Tar.gz archive package

The syntax is same as for a zip package:

```ruby
targz "name", url: "..." [, import: %w(...)]
```

for example,

```ruby
targz "scroll_magic", url: "https://github.com/janpaepke/ScrollMagic/archive/v2.0.0.tar.gz"
```

#### Github release package

This is a more readable version/shortcut for "https://github.com/.../archive/..." URLs.

The syntax is:

```ruby
gh_release "name", source: "...", tag: "..." [, import: %w(...)]
```

where "source" is the user + repository and "tag" is the repository tag (exactly as on Github,
i.e. with "v" prefix if present), more on "import" below. For example,

```ruby
gh_release "scroll_magic", source: "janpaepke/ScrollMagic", tag: "v.2.0.0"
```

You can omit the name, it will be equal to the repository name:

```ruby
gh_release source: "janpaepke/ScrollMagic", tag: "v.2.0.0" # "ScrollMagic" is assumed
```

#### npm package

Allows to download packages from npm registry.

The syntax is:

```ruby
npm "name", package: "...", version: "..." [, import: %w(...)]
```

where "package" is the package name as published on npm registry and "version" is its version,
more on "import" below. For example,

```ruby
npm "coffee", package: "coffee-script", version: "1.9.2"
```

You can omit the name, it will be equal to the package name:

```ruby
npm package: "coffee-script", version: "1.9.2"
```

### "Packing the torba" process

When you run `torba pack` the following happens:

1.  All remote sources are cached locally.

2.  Archives are unpacked with top level directory removed. This is done for good because it
usually contains the package version in the name, e.g. "react-0.13.2", and you don't want to have to reference versions
inside your application code (except Torbafile).

3.  Remote source's content is copied as is to the `Torba.home_path` location with **package name used
as a namespace**.

    This is also done for good reason in order to avoid name collisions (since many JS projects can have
assets with the same names and all packages are placed into Sprockets' shared virtual filesystem).
The downside is that you have to use namespaces in each require directive, which can lead to
duplication:

    ```javascript
    // application.js
    //= require 'underscore/underscore'
    ```

    Hint: use "require_directory" if you're strongly against such duplication:

    ```javascript
    //= require_directory 'underscore'
    ```

4.  Stylesheets (if any) are converted to ".css.erb" with "asset_path" helpers used in "url(...)"
statements.

### :import option

Copying whole remote source's content has the disadvantage of using remote source specific paths in your
require/import directives. For example, if an archive contains files in the "dist/css" directory, you'll have
to mention it:

```css
/* application.css */
@import 'lightslider/dist/css/lightslider';
```

To mitigate this you can cherry-pick files from the source via the "import" option, for example:

```ruby
gh_release "lightslider", source: "sachinchoolur/lightslider", tag: "1.1.2", import: %w[
  dist/css/lightslider.css
]
```

Such files will be copied directly to the package root (i.e. file tree becomes flatten), thus you
can omit unnecessary paths:

```css
@import 'lightslider/lightslider';
```

You can use any Dir.glob pattern:

```ruby
gh_release "lightslider", source: "sachinchoolur/lightslider", tag: "1.1.2", import: %w[
  dist/css/lightslider.css
  dist/img/*.png
]
```

In addition to this "path/" is treated as a shortcut for "path/**/*" glob pattern.

Be careful to **import only that you really need**. Everything that is non JS or CSS asset is
going to be precompiled by Sprockets and accessible publicly. See [Rails ticket][rails-ticket-vendoring]
that explains this problem (and why Rails >= 4 precompiles only application.js/css in vendor by
default), except that Torba does have a way to specify exact list of files to import.

## Deployment

In Rails apps, Torba automatically hooks into the existing `assets:precompile`
Rake task to ensure that `torba pack` is executed. This means that Rails
deployments will "just work", although there are some optimizations you can make
as explained below.

### Heroku

You will need to specify some config vars to ensure Torba's files are placed in
locations suitable for the Heroku platform.

`TORBA_HOME_PATH` should be within your app so that Torba's assets are included
in the slug.

`TORBA_CACHE_PATH` should make use of the `tmp/cache/assets` directory. This is
where the Ruby buildpack expects cached files to be stored related to the
`assets:precompile` step. This way Torba doesn't have to download packages fresh
every time.

```bash
heroku config:set TORBA_HOME_PATH=vendor/torba TORBA_CACHE_PATH=tmp/cache/assets/torba
```

Now your Heroku app is good to go.

### Capistrano

Specify the `TORBA_HOME_PATH` env variable pointing to a persistent directory
writable by your deploy user and shared across releases. Capistrano's `shared`
directory is good for this.

For example:

```bash
export TORBA_HOME_PATH=/var/www/my_app/shared/torba
```

There is no need to add a symlink.

### Troubleshooting

If you are getting an error like `Your Torba is not packed yet` when trying to
run `rake assets:precompile` (or `bin/rails assets:precompile` in Rails 5),
set the `TORBA_DONT_VERIFY` environment variable, like this:

```bash
TORBA_DONT_VERIFY=1 bin/rake assets:precompile
```

[bower]: http://bower.io/
[sprockets]: https://github.com/rails/sprockets/
[sprockets-load-path]: https://github.com/rails/sprockets#the-load-path
[torba-pronounce]: http://upload.wikimedia.org/wikipedia/commons/2/28/Uk-%D1%82%D0%BE%D1%80%D0%B1%D0%B0.ogg
[github-releases]: https://help.github.com/articles/about-releases/
[sprockets-directives]: https://github.com/rails/sprockets#the-directive-processor
[sass-import]: http://sass-lang.com/documentation/file.SASS_REFERENCE.html#import
[rails-assets]: https://rails-assets.org/
[bower-rails]: https://github.com/rharriso/bower-rails
[semver]: http://semver.org/
[rails-ticket-vendoring]: https://github.com/rails/rails/pull/7968
[npm]: https://npmjs.com
