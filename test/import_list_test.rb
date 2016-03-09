require "test_helper"

module Torba
  class ImportListTest < Minitest::Test
    def test_find_by_absolute_path
      item = ImportList::Asset.new("/dir/subdir/file.jpg", "file.jpg")
      list = ImportList.new([item])

      found = list.find_by_absolute_path("/dir/subdir/file.jpg")
      assert_equal item, found
    end

    def test_find_by_absolute_path_missing
      list = ImportList.new([])

      assert_raises(Errors::AssetNotFound) do
        list.find_by_absolute_path("file.jpg")
      end
    end

    def js_asset
      ImportList::Asset.new("/dir/script.js", "script.js")
    end

    def css_asset
      ImportList::Asset.new("/dir/stylesheet.css", "stylesheet.css")
    end

    def scss_asset
      ImportList::Asset.new("/dir/stylesheet.scss", "stylesheet.scss")
    end

    def sass_asset
      ImportList::Asset.new("/dir/stylesheet.sass", "stylesheet.sass")
    end

    def test_css_assets
      list = ImportList.new([js_asset, css_asset, scss_asset, sass_asset])
      assert [css_asset, scss_asset, sass_asset], list.css_assets
    end

    def test_non_css_assets
      list = ImportList.new([js_asset, css_asset, scss_asset, sass_asset])
      assert [js_asset], list.non_css_assets
    end

    def test_non_js_css_assets
      img_asset = ImportList::Asset.new("/dir/image.png", "image.png")
      list = ImportList.new([js_asset, css_asset, scss_asset, sass_asset, img_asset])
      assert [img_asset], list.non_js_css_assets
    end
  end
end
