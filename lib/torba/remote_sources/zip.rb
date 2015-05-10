require "fileutils"

require "torba/remote_sources/common"
require "torba/remote_sources/get_file"

module Torba
  module RemoteSources
    # Represents remote zip archive.
    class Zip
      include Common

      attr_reader :url, :digest

      def initialize(url)
        @url = url
        @digest = "#{File.basename url, '.zip'}-#{Torba.digest(url)}"
      end

      private

      def ensure_cached
        unless Dir.exist?(cache_path)
          FileUtils.mkdir_p(cache_path)

          tempfile = GetFile.process(url)

          command = "unzip -oqq -d #{cache_path} #{tempfile.path}"
          system(command) || raise(Errors::ShellCommandFailed.new(command))

          get_rid_of_top_level_directory
        end
      rescue
        FileUtils.rm_rf(cache_path)
        raise
      end

      def get_rid_of_top_level_directory
        top_level_content = Dir.glob("#{cache_path}/*")
        if top_level_content.size == 1 && File.directory?(top_level_content.first)
          top_level_dir = top_level_content.first
          FileUtils.cp_r("#{top_level_dir}/.", cache_path)
          FileUtils.rm_rf(top_level_dir)
        end
      end
    end
  end
end
