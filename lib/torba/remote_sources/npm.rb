require "torba/remote_sources/targz"

module Torba
  module RemoteSources
    # Represents {https://npmjs.com npm package}.
    # @since 0.3.0
    class Npm < Targz
      # @return [String] package name.
      # @example
      #   "coffee-script"
      #   "@lottiefiles/lottie-player"
      attr_reader :package

      # @return [String] package version.
      # @example
      #   "1.8.3"
      attr_reader :version

      # @param package see {#package}
      # @param version see {#version}
      def initialize(package, version)
        @package = package
        @version = version

        # https://docs.npmjs.com/about-scopes
        # "@lottiefiles/lottie-player" => "lottie-player"
        unscoped_package = package.sub(%r{@[^/]+/}, "")

        super("https://registry.npmjs.org/#{package}/-/#{unscoped_package}-#{version}.tgz")
        @digest = "#{package}-#{Torba.digest(url)}"
      end
    end
  end
end
