require "test_helper"

module Torba
  class PackageLogicalPathsTest < Minitest::Test
    def import_list
      js_asset = ImportList::Asset.new("/dir/script.js", "script.js")
      css_asset = ImportList::Asset.new("/dir/stylesheet.css", "stylesheet.css")
      img_asset = ImportList::Asset.new("/dir/image.svg", "image.svg")
      ImportList.new([js_asset, css_asset, img_asset])
    end

    def package
      @package ||= Package.new("hello", nil)
    end

    def test_logical_paths
      package.stub :import_list, import_list do
        assert_equal %w[script.js stylesheet.css image.svg], package.logical_paths
      end
    end

    def test_non_js_css_logical_paths
      package.stub :import_list, import_list do
        assert_equal %w[image.svg], package.non_js_css_logical_paths
      end
    end
  end
end
