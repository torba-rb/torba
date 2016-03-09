require "torba/package"
require "torba/remote_sources/zip"
require "torba/remote_sources/github_release"
require "torba/remote_sources/targz"
require "torba/remote_sources/npm"

module Torba
  module Errors
    class MissingPackages < StandardError
      attr_reader :packages

      def initialize(packages)
        @packages = packages
        super
      end
    end
  end
  # Represents Torbafile.
  class Manifest
    # all packages defined in Torbafile
    attr_reader :packages

    # Reads Torbafile and evaluates it.
    # @return [Manifest]
    #
    # @overload self.build(file_path)
    #   @param file_path [String] absolute path to Torbafile
    #
    # @overload self.build
    #   Reads Torbafile from current directory
    def self.build(file_path = ENV["TORBA_FILE"])
      file_path ||= File.join(Dir.pwd, "Torbafile")

      manifest = new
      content = File.read(file_path)
      manifest.instance_eval(content, file_path)
      manifest
    end

    def initialize
      @packages = []
    end

    # Adds {Package} with {RemoteSources::Zip} to {#packages}
    def zip(name, options = {})
      url = options.fetch(:url)
      remote_source = RemoteSources::Zip.new(url)
      packages << Package.new(name, remote_source, options)
    end

    # Adds {Package} with {RemoteSources::GithubRelease} to {#packages}
    def gh_release(name = nil, options = {})
      if name.is_a?(Hash)
        options, name = name, nil
      end

      source = options.fetch(:source)
      tag = options.fetch(:tag)
      remote_source = RemoteSources::GithubRelease.new(source, tag)

      name ||= remote_source.repository_name
      packages << Package.new(name, remote_source, options)
    end

    # Adds {Package} with {RemoteSources::Targz} to {#packages}
    # @since 0.3.0
    def targz(name, options = {})
      url = options.fetch(:url)
      remote_source = RemoteSources::Targz.new(url)
      packages << Package.new(name, remote_source, options)
    end

    # Adds {Package} with {RemoteSources::Npm} to {#packages}
    # @since 0.3.0
    def npm(name = nil, options = {})
      if name.is_a?(Hash)
        options, name = name, nil
      end

      package_name = options.fetch(:package)
      version = options.fetch(:version)
      remote_source = RemoteSources::Npm.new(package_name, version)

      name ||= remote_source.package
      packages << Package.new(name, remote_source, options)
    end

    # Builds all {#packages}
    # @return [void]
    def pack
      packages.each(&:build)
    end

    # @return [Array<String>] list of paths to each prepared asset package.
    #   It should be appended to the Sprockets' load_path.
    def load_path
      packages.map(&:load_path)
    end

    # @return [Array<String>] logical paths that packages contain except JS ans CSS.
    #   It should be appended to the Sprockets' precompile list. Packages' JS and CSS
    #   are meant to be included into application.js/.css and not to be compiled
    #   alone (you can add them by hand though).
    # @note Avoid importing everything from a package as it'll be precompiled and accessible
    #   publicly.
    # @see Package#import_paths
    # @see Package#non_js_css_logical_paths
    # @since 0.3.0
    def non_js_css_logical_paths
      packages.flat_map(&:non_js_css_logical_paths)
    end

    # Verifies all {#packages}
    # @return [void]
    # @raise [Errors::MissingPackages] if at least one package is not build.
    def verify
      missing = packages.reject(&:verify)

      if missing.any?
        raise Errors::MissingPackages.new(missing)
      end
    end
  end
end
