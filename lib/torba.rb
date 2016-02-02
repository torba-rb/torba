require "digest"

require "torba/ui"
require "torba/manifest"

# @since 0.1.0
module Torba
  module Errors
    ShellCommandFailed = Class.new(StandardError)
  end

  # @return [String] root path to prepared asset packages. By default it's ".torba" within
  #   your OS home directory (i.e. packages are shared between projects).
  # @note use "TORBA_HOME_PATH" env variable to override default value
  def self.home_path
    @home_path ||= ENV["TORBA_HOME_PATH"] || File.join(Dir.home, ".torba")
  end

  # Override home path with a new value
  # @param val [String] new home path
  # @return [void]
  def self.home_path=(val)
    @home_path = val
  end

  # @return [String] root path to downloaded yet unprocessed asset packages. By default
  #   it's "cache" within {.home_path}.
  # @note use "TORBA_CACHE_PATH" env variable to override default value
  def self.cache_path
    @cache_path ||= ENV["TORBA_CACHE_PATH"] || File.join(home_path, "cache")
  end

  # Override cache path with a new value
  # @param val [String] new cache path
  # @return [void]
  # @since 0.6.0
  def self.cache_path=(val)
    @cache_path = val
  end

  # @return [Ui]
  def self.ui
    @ui ||= Ui.new
  end

  # @return [Manifest]
  def self.manifest
    @manifest ||= Manifest.build
  end

  # @see Manifest#pack
  def self.pack
    manifest.pack
  end

  # @see Manifest#load_path
  def self.load_path
    manifest.load_path
  end

  # @see Manifest#non_js_css_logical_paths
  # @since 0.3.0
  def self.non_js_css_logical_paths
    manifest.non_js_css_logical_paths
  end

  # @see Manifest#verify
  def self.verify
    manifest.verify
  end

  # @return [String] unique short fingerprint/hash for given string
  # @param [String] string to be hashed
  #
  # @example
  #   Torba.digest("path/to/hash") #=> "23e3e63c"
  def self.digest(string)
    Digest::SHA1.hexdigest(string)[0..7]
  end

  # @see Manifest#find_packages_by_name
  # @since unreleased
  def self.find_packages_by_name(name)
    manifest.find_packages_by_name(name)
  end

  # @yield a block, converts common exceptions into useful messages
  def self.pretty_errors
    yield
  rescue Errors::MissingPackages => e
    ui.error "Your Torba is not packed yet."
    ui.error "Missing packages:"
    e.packages.each do |package|
      ui.error "  * #{package.name}"
    end
    ui.suggest "Run `bundle exec torba pack` to install missing packages."
    exit(false)
  rescue Errors::ShellCommandFailed => e
    ui.error "Couldn't execute command '#{e.message}'"
    exit(false)
  rescue Errors::NothingToImport => e
    ui.error "Couldn't import an asset(-s) '#{e.path}' from import list in '#{e.package}'."
    ui.suggest "Check for typos."
    ui.suggest "Make sure that the path has trailing '/' if its a directory."
    exit(false)
  rescue Errors::AssetNotFound => e
    ui.error "Unknown asset to process with path '#{e.message}'."
    ui.suggest "Make sure that you've imported all image/font assets mentioned in a stylesheet(-s)."
    exit(false)
  end
end
