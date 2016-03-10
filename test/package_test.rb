require "test_helper"

module Torba
  class PackageTest < Minitest::Test
    def source_dir
      @source_dir ||= File.join(Torba.home_path, "source")
    end

    def touch(path)
      super File.join(source_dir, path)
    end

    def fixture(path, content = nil)
      touch(path)
      if content
        File.write(File.join(source_dir, path), content)
      end
    end

    def test_package_css_with_urls
      touch "image.png"
      fixture "hello.css" , "body {\nbackground-image: url(image.png)\n}"
      source = Torba::Test::RemoteSource.new(source_dir)
      package = Package.new("package", source, import: ["hello.css", "image.png"])

      package.build

      assert_exists File.join(package.load_path, "package", "hello.css.erb")
      assert_exists File.join(package.load_path, "package", "image.png")
    end

    def test_package_css_without_urls
      fixture "hello.css"
      source = Torba::Test::RemoteSource.new(source_dir)
      package = Package.new("package", source, import: ["hello.css"])

      package.build

      assert_exists File.join(package.load_path, "package", "hello.css")
    end

    def test_package_css_with_urls_pointing_to_nonexisting_assets
      fixture "hello.css", "/*body {\nbackground-image: url(image.png)\n}*/"
      source = Torba::Test::RemoteSource.new(source_dir)
      package = Package.new("package", source, import: ["hello.css"])

      package.build

      assert_exists File.join(package.load_path, "package", "hello.css")
    end
  end
end
