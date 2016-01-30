require "bundler/setup"
require "torba"
require "torba/remote_sources/common"

require "minitest/autorun"
require "mocha/mini_test"
require "tmpdir"
require "fileutils"

module Torba
  module Test
    module TempHome
      def before_setup
        Torba.home_path = @_torba_tmp_dir = File.realpath(Dir.mktmpdir("torba"))
        super
      end

      def after_teardown
        FileUtils.rm_rf(@_torba_tmp_dir)
        Torba.home_path = nil
        super
      end
    end

    module AssertExists
      def assert_exists(file_path)
        assert File.exists?(file_path)
      end

      def refute_exists(file_path)
        refute File.exists?(file_path)
      end
    end

    module Touch
      def touch(path)
        FileUtils.mkdir_p(File.dirname(path))
        FileUtils.touch(path)
      end
    end

    class RemoteSource
      include RemoteSources::Common

      attr_reader :cache_path

      def initialize(cache_path)
        @cache_path = cache_path
      end

      def ensure_cached; end

      def digest; '' end
    end
  end
end

class Minitest::Test
  include Torba::Test::TempHome
  include Torba::Test::AssertExists
  include Torba::Test::Touch
end
