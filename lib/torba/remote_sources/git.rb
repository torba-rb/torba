require "fileutils"

require "torba/remote_sources/common"

module Torba
  module RemoteSources
    # Represents remote git repository.
    class Git
      include Common

      attr_reader :url, :digest

      def initialize(url)
        @url = url
        @digest = "#{File.basename url, '.git'}-#{Torba.digest(url)}"
      end

      private

      def ensure_cached
        unless Dir.exist?(cache_path)
          FileUtils.mkdir_p(cache_path)

          command = "git clone --depth 1 #{url} #{cache_path}"
          system(command) || raise(Errors::ShellCommandFailed.new(command))
        end
      rescue
        FileUtils.rm_rf(cache_path)
        raise
      end
    end
  end
end
