require "test_helper"

module Torba
  class AcceptanceTest < Minitest::Test
    def manifest
      @manifest ||= Manifest.build("test/Torbafile")
    end

    def assert_exists(file_path)
      super File.join(manifest.load_path, file_path)
    end

    def test_pack
      manifest.pack

      assert_exists "trumbowyg/trumbowyg.js"
      assert_exists "trumbowyg/trumbowyg.css.erb"
      assert_exists "trumbowyg/icons.png"
      assert_exists "trumbowyg/icons-2x.png"

      css = File.read File.join(manifest.load_path, "trumbowyg/trumbowyg.css.erb")
      assert_includes css, "background: transparent url('<%= asset_path('trumbowyg/icons.png') %>') no-repeat;"
      assert_includes css, "background-image: url('<%= asset_path('trumbowyg/icons-2x.png') %>')"
    end
  end
end
