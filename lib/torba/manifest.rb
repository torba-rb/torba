require "torba/package"
require "torba/remote_sources/zip"
require "torba/remote_sources/github_release"

module Torba
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
    def self.build(file_path = nil)
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
    def gh_release(name, options = {})
      source = options.fetch(:source)
      tag = options.fetch(:tag)
      remote_source = RemoteSources::GithubRelease.new(source, tag)
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

    # Verifies all {#packages}
    # @return [void]
    def verify
      packages.each(&:verify)
    end
  end
end
