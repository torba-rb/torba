require "bundler/setup"
require "torba"
require "torba/remote_sources/common"

require "minitest/autorun"
require "mocha/mini_test"
require "tmpdir"
require "fileutils"
require "open3"

module Torba
  module Test
    module TempHome
      attr_reader :torba_tmp_dir

      def self.persistent_tmp_dir
        @persistent_tmp_dir ||= File.realpath(Dir.mktmpdir("torba"))
      end

      def before_setup
        Torba.home_path = @torba_tmp_dir = File.realpath(Dir.mktmpdir("torba"))
        super
      end

      def after_teardown
        FileUtils.rm_rf(torba_tmp_dir)
        Torba.home_path = nil
        super
      end

      Minitest.after_run do
        FileUtils.rm_rf(persistent_tmp_dir)
      end
    end

    module FileSystem
      def assert_exists(file_path)
        assert File.exists?(file_path)
      end

      def refute_exists(file_path)
        refute File.exists?(file_path)
      end

      def touch(path)
        FileUtils.mkdir_p(File.dirname(path))
        FileUtils.touch(path)
      end

      def path_to_packaged(name, home = torba_tmp_dir)
        path = Dir.glob("#{home}/*").grep(Regexp.new(name)).first
        assert path, "Couldn't find packaged #{name.inspect} in #{home.inspect}"
        path
      end

      def read_without_newline(path)
        content = File.read(path)
        content.strip
      rescue ArgumentError # ignore binary files
        content
      end

      def compare_dirs(expected, actual)
        expected_paths = Dir.glob("#{expected}/**/*").map{ |path| path.sub(expected, "")}

        expected_paths.each do |path|
          actual_file = File.join(actual, path)
          assert_exists actual_file

          unless File.directory?(actual_file)
            expected_file = File.join(expected, path)
            assert_equal read_without_newline(expected_file), read_without_newline(actual_file), "#{expected_file.inspect} should be equal to #{actual_file.inspect}"
          end
        end

        actual_paths = Dir.glob("#{actual}/**/*").map{ |path| path.sub(actual, "")}

        paths_diff = actual_paths - expected_paths
        assert_empty paths_diff, "#{expected.inspect} contains extra paths #{paths_diff.inspect}"
      end
    end

    module Exec
      def torba(torba_cmd, options = {})
        env = {"TORBA_HOME_PATH" => torba_tmp_dir, "TORBA_CACHE_PATH" => TempHome.persistent_tmp_dir}

        if (torbafile = options.delete(:torbafile))
          env.merge!("TORBA_FILE" => "test/fixtures/torbafiles/#{torbafile}")
        end

        if (home_path = options.delete(:home_path))
          env.merge!("TORBA_HOME_PATH" => home_path)
        end

        if (cache_path = options.delete(:cache_path))
          env.merge!("TORBA_CACHE_PATH" => cache_path)
        end

        if (additional_env = options.delete(:env))
          env.merge!(additional_env)
        end

        cmd = "ruby bin/torba #{torba_cmd}"
        Open3.capture3(env, cmd, options)
      end

      def skip_java_capture3_bug
        if RUBY_PLATFORM == "java"
          skip "Skipping test due to Open3.capture3 bug in Jruby"
        end
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
  include Torba::Test::FileSystem
  include Torba::Test::Exec
end
