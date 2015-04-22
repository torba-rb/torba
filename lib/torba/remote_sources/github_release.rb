require "torba/remote_sources/zip"

module Torba
  module RemoteSources
    # Represents {https://help.github.com/articles/about-releases/ Github release}.
    class GithubRelease < Zip
      # @return [String] repository user and name.
      # @example
      #   "jashkenas/underscore"
      attr_reader :source

      # @return [String] repository tag.
      # @example
      #   "v1.8.3"
      attr_reader :tag

      # @param source see {#source}
      # @param tag see {#tag}
      def initialize(source, tag)
        @source = source
        @tag = tag
        super("https://github.com/#{source}/archive/#{tag}.zip")
      end
    end
  end
end
