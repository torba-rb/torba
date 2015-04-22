require "test_helper"
require "fileutils"
require "torba/remote_sources/common"

module Torba
  class PackageImportListTest < Minitest::Test
    def source_dir
      @source_dir ||= begin
        dir = File.join(Torba.home_path, "source")
        FileUtils.mkdir_p(dir)
        dir
      end
    end

    def touch(path)
      absolute_path = File.join(source_dir, path)
      FileUtils.mkdir_p(File.dirname(absolute_path))
      FileUtils.touch(absolute_path)
    end

    class RemoteSource
      include RemoteSources::Common

      attr_reader :cache_path

      def initialize(cache_path)
        @cache_path = cache_path
      end

      def ensure_cached; end
    end

    def remote_source
      @remote_source ||= RemoteSource.new(source_dir)
    end

    def test_single_file_path
      touch("hello.js")

      list = Package.new("package", remote_source, import: ["hello.js"]).import_list
      assert_equal 1, list.assets.size
      item = list.assets.first
      assert_equal "hello.js", item.subpath
      assert_equal File.join(source_dir, "hello.js"), item.absolute_path
    end

    def test_single_file_path_with_subdir
      touch("build/hello.js")

      list = Package.new("package", remote_source, import: ["build/hello.js"]).import_list
      assert_equal 1, list.assets.size
      item = list.assets.first
      assert_equal "hello.js", item.subpath
      assert_equal File.join(source_dir, "build/hello.js"), item.absolute_path

      touch("build/standalone/hello.js")

      list = Package.new("package", remote_source, import: ["build/standalone/hello.js"]).import_list
      assert_equal 1, list.assets.size
      item = list.assets.first
      assert_equal "hello.js", item.subpath
      assert_equal File.join(source_dir, "build/standalone/hello.js"), item.absolute_path
    end

    def test_directory
      touch("build/standalone/hello.js")

      list = Package.new("package", remote_source, import: ["build/"]).import_list
      assert_equal 1, list.assets.size
      item = list.assets.first
      assert_equal "standalone/hello.js", item.subpath
      assert_equal File.join(source_dir, "build/standalone/hello.js"), item.absolute_path


      list = Package.new("package", remote_source, import: ["build/standalone/"]).import_list
      assert_equal 1, list.assets.size
      item = list.assets.first
      assert_equal "hello.js", item.subpath
      assert_equal File.join(source_dir, "build/standalone/hello.js"), item.absolute_path
    end

    def test_multiple_files
      touch("build/images/first.png")
      touch("build/images/second.png")

      list = Package.new("package", remote_source, import: ["build/"]).import_list
      assert_equal 2, list.assets.size

      first_item = list.assets[0]
      assert_equal "images/first.png", first_item.subpath
      assert_equal File.join(source_dir, "build/images/first.png"), first_item.absolute_path

      second_item = list.assets[1]
      assert_equal "images/second.png", second_item.subpath
      assert_equal File.join(source_dir, "build/images/second.png"), second_item.absolute_path
    end

    def test_multiple_import_paths
      touch("images/one.jpg")
      touch("js/script.js")

      list = Package.new("package", remote_source, import: ["images/", "js/script.js"]).import_list
      assert_equal 2, list.assets.size

      first_item = list.assets[0]
      assert_equal "one.jpg", first_item.subpath
      assert_equal File.join(source_dir, "images/one.jpg"), first_item.absolute_path

      second_item = list.assets[1]
      assert_equal "script.js", second_item.subpath
      assert_equal File.join(source_dir, "js/script.js"), second_item.absolute_path
    end

    def test_glob_pattern
      touch("js/hello.js")
      touch("build/css/bye.css")

      list = Package.new("package", remote_source, import: ["**/*.{js,coffee}"]).import_list
      assert_equal 1, list.assets.size
      item = list.assets.first
      assert_equal "js/hello.js", item.subpath
      assert_equal File.join(source_dir, "js/hello.js"), item.absolute_path

      list = Package.new("package", remote_source, import: ["build/**/*.css"]).import_list
      assert_equal 1, list.assets.size
      item = list.assets.first
      assert_equal "css/bye.css", item.subpath
      assert_equal File.join(source_dir, "build/css/bye.css"), item.absolute_path
    end

    def test_missing_file
      assert_raises(Torba::Errors::NothingToImport) do
        Package.new("package", remote_source, import: ["hello.js"]).import_list
      end

      touch("hello.js")

      assert_raises(Torba::Errors::NothingToImport) do
        Package.new("package", remote_source, import: ["hello.js", "another_missing.js"]).import_list
      end
    end
  end
end
