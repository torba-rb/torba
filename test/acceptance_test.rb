require "test_helper"

module Torba
  class AcceptanceTest < Minitest::Test
    def manifest
      @manifest ||= Manifest.build("test/Torbafile")
    end

    def find_path(file_path)
      manifest.load_path.map{ |lp| File.join(lp, file_path) }.find{ |full_path| File.exists?(full_path) }
    end

    def assert_exists(file_path)
      assert find_path(file_path), "'#{file_path}' should exist"
    end

    def refute_exists(file_path)
      refute find_path(file_path), "'#{file_path}' should not exist"
    end

    def read_path(file_path)
      File.read(find_path(file_path))
    end

    def pack_torbafile(content)
      File.write("test/Torbafile", content)
      manifest.pack
    end

    def test_zip
      pack_torbafile <<-TORBA
        zip "trumbowyg-from-zip",
          url: "https://github.com/torba-rb/Trumbowyg/archive/1.1.6.zip",
          import: ["dist/trumbowyg.js"]
      TORBA

      assert_exists "trumbowyg-from-zip/trumbowyg.js"
      refute_exists "trumbowyg-from-zip/trumbowyg.css.erb"
      refute_exists "trumbowyg-from-zip/icons.png"
      refute_exists "trumbowyg-from-zip/icons-2x.png"
    end

    def test_gh_release
      pack_torbafile <<-TORBA
        gh_release "trumbowyg", source: "torba-rb/Trumbowyg", tag: "1.1.7", import: %w[
          dist/trumbowyg.js
          dist/ui/*.css
          dist/ui/images/
        ]
      TORBA

      assert_exists "trumbowyg/trumbowyg.js"
      assert_exists "trumbowyg/trumbowyg.css.erb"
      assert_exists "trumbowyg/icons.png"
      assert_exists "trumbowyg/icons-2x.png"

      css = read_path "trumbowyg/trumbowyg.css.erb"
      assert_includes css, %[background: transparent url("<%= asset_path('trumbowyg/icons.png') %>") no-repeat;]
      assert_includes css, %[background-image: url("<%= asset_path('trumbowyg/icons-2x.png') %>")]
    end

    def test_targz
      pack_torbafile <<-TORBA
        targz "trumbowyg-from-tar",
        url: "https://github.com/torba-rb/Trumbowyg/archive/1.1.7.tar.gz",
        import: ["dist/ui/"]
      TORBA

      refute_exists "trumbowyg-from-tar/trumbowyg.js"
      assert_exists "trumbowyg-from-tar/trumbowyg.css.erb"
      assert_exists "trumbowyg-from-tar/images/icons.png"
      assert_exists "trumbowyg-from-tar/images/icons-2x.png"

      css = read_path "trumbowyg-from-tar/trumbowyg.css.erb"
      assert_includes css, %[background: transparent url("<%= asset_path('trumbowyg-from-tar/images/icons.png') %>") no-repeat;]
      assert_includes css, %[background-image: url("<%= asset_path('trumbowyg-from-tar/images/icons-2x.png') %>")]
    end

    def test_npm
      pack_torbafile <<-TORBA
        npm "lo_dash", package: "lodash", version: "0.1.0", import: ["lodash.js"]
      TORBA

      assert_exists "lo_dash/lodash.js"
    end
  end
end
