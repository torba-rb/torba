require "test_helper"

module Torba
  class AcceptanceTest < Minitest::Test
    def manifest
      @manifest ||= Manifest.build("test/Torbafile")
    end

    def find(file_path)
      manifest.load_path.map{ |lp| File.join(lp, file_path) }.find{ |full_path| File.exists?(full_path) }
    end

    def assert_exists(file_path)
      assert find(file_path)
    end

    def refute_exists(file_path)
      refute find(file_path)
    end

    def read(file_path)
      File.read(find(file_path))
    end

    def test_pack
      manifest.pack

      assert_exists "trumbowyg-from-zip/trumbowyg.js"
      refute_exists "trumbowyg-from-zip/trumbowyg.css.erb"
      refute_exists "trumbowyg-from-zip/icons.png"
      refute_exists "trumbowyg-from-zip/icons-2x.png"

      assert_exists "trumbowyg/trumbowyg.js"
      assert_exists "trumbowyg/trumbowyg.css.erb"
      assert_exists "trumbowyg/icons.png"
      assert_exists "trumbowyg/icons-2x.png"

      css = read "trumbowyg/trumbowyg.css.erb"
      assert_includes css, "background: transparent url('<%= asset_path('trumbowyg/icons.png') %>') no-repeat;"
      assert_includes css, "background-image: url('<%= asset_path('trumbowyg/icons-2x.png') %>')"

      refute_exists "trumbowyg-from-tar/trumbowyg.js"
      assert_exists "trumbowyg-from-tar/trumbowyg.css.erb"
      assert_exists "trumbowyg-from-tar/images/icons.png"
      assert_exists "trumbowyg-from-tar/images/icons-2x.png"
    end
  end
end
