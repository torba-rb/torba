require "bundler/setup"
require "torba"

require "minitest/autorun"
require "tmpdir"

module Torba
  module Test
    module TempHome
      def before_setup
        Torba.home_path = @_torba_tmp_dir = Dir.mktmpdir("torba")
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
  end
end

class Minitest::Test
  include Torba::Test::TempHome
  include Torba::Test::AssertExists
end
