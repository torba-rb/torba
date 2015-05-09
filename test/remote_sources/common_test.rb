require "test_helper"
require "fileutils"

module Torba
  class CommonRemoteSourceTest < Minitest::Test
    def cache_path
      Torba.home_path
    end

    def remote
      @remote ||= Test::RemoteSource.new(cache_path)
    end

    def touch(path)
      super File.join(cache_path, path)
    end

    def assert_valid_tuple(path, tuple)
      assert_equal File.join(cache_path, path), tuple[0]
      assert_equal path, tuple[1]
    end

    def test_glob
      touch "one.jpg"
      touch "two.jpg"

      tuples = remote["*"]
      assert_equal 2, tuples.size

      tuple1, tuple2 = tuples
      assert_valid_tuple "one.jpg", tuple1
      assert_valid_tuple "two.jpg", tuple2
    end

    def test_no_directories
      touch "hello/one.jpg"

      tuples = remote["*"]
      assert_equal 0, remote["*"].size

      tuples = remote["**/*"]
      assert_equal 1, tuples.size

      assert_valid_tuple "hello/one.jpg", tuples.first
    end

    def test_always_absolute_path
      touch "hello/one.jpg"

      Dir.chdir(cache_path) do
        remote = Test::RemoteSource.new("./hello")

        tuples = remote["*"]
        assert_equal 1, tuples.size

        tuple = tuples.first
        assert_equal File.join(cache_path, "hello/one.jpg"), tuple[0]
        assert_equal "one.jpg", tuple[1]
      end
    end
  end
end
