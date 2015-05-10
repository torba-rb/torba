require "fileutils"

require "torba/remote_sources/common"
require "torba/remote_sources/get_file"

module Torba
  module RemoteSources
    # Represents remote tar.gz archive.
    # @since unreleased
    class Targz
      include Common

      attr_reader :url, :digest

      def initialize(url)
        @url = url
        @digest = "#{File.basename(url).sub(/\.(tgz|tar\.gz)$/, '')}-#{Torba.digest(url)}"
      end

      private

      def ensure_cached
        unless Dir.exist?(cache_path)
          FileUtils.mkdir_p(cache_path)

          tempfile = GetFile.process(url)

          command = "gzip -qcd #{tempfile.path} | tar -mxpf - --strip-components=1 -C #{cache_path}"
          system(command) || raise(Errors::ShellCommandFailed.new(command))
        end
      rescue
        FileUtils.rm_rf(cache_path)
        raise
      end
    end
  end
end
