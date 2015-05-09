require "torba/remote_sources/zip"

module Torba
  module RemoteSources
    # Represents {https://help.github.com/articles/about-releases/ Github release}.
    class GithubRelease < Zip
      # @return [String] repository user and name.
      # @example
      #   "jashkenas/underscore"
      # @see #repository_name
      # @see #repository_user
      attr_reader :source

      # @return [String]
      # @since 0.2.0
      attr_reader :repository_name

      # @return [String]
      # @since 0.2.0
      attr_reader :repository_user

      # @return [String] repository tag.
      # @example
      #   "v1.8.3"
      attr_reader :tag

      # @param source see {#source}
      # @param tag see {#tag}
      def initialize(source, tag)
        @source = source
        @tag = tag
        @repository_user, @repository_name = source.split("/")
        super("https://github.com/#{source}/archive/#{tag}.zip")
        @digest = "#{repository_name}-#{Torba.digest(url)}"
      end
    end
  end
end
