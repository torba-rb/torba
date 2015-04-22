require "test_helper"

module Torba
  class CssUrlToErbAssetPathTest < Minitest::Test
    def filter
      CssUrlToErbAssetPath
    end

    def test_no_url
      css = "p { margin: 0; }"
      assert_equal css, filter.call(css, "/current/file")
    end

    def test_url_with_data
      css = "background-image: url(data:image/svg+xml;base64,PHN2ZyB4bWxucz0iaskip);"
      assert_equal css, filter.call(css, "/current/file")
    end

    def test_absolute_url
      css = "background-image: url('/icons.png');"
      assert_equal "background-image: url('/icons.png');", filter.call(css, "/current_file")
    end

    def test_stylesheet_and_image_in_same_directory
      current_file = "/home/package/dist/ui/stylesheet.css"
      css = "background-image: url('icons.png');"

      new_content = filter.call(css, current_file) do |image_full_url|
        assert_equal "/home/package/dist/ui/icons.png", image_full_url
        "ui/icons.png"
      end
      assert_equal "background-image: url('<%= asset_path('ui/icons.png') %>');", new_content
    end

    def test_url_double_quotes
      current_file = "/home/package/dist/ui/stylesheet.css"
      css = 'background-image: url("icons.png");'

      filter.call(css, current_file) do |image_full_url|
        assert_equal "/home/package/dist/ui/icons.png", image_full_url
      end
    end

    def test_minified
      current_file = "/home/package/dist/ui/stylesheet.css"
      css = ".image{background-image:url(icons.png)}.border{border(1px solid)};"

      filter.call(css, current_file) do |image_full_url|
        assert_equal "/home/package/dist/ui/icons.png", image_full_url
      end
    end

    def test_stylesheet_and_image_in_sibling_directories
      current_file = "/home/package/dist/ui/stylesheet.css"
      css = "background-image: url('../images/icons.png');"

      new_content = filter.call(css, current_file) do |image_full_url|
        assert_equal "/home/package/dist/images/icons.png", image_full_url
        "images/icons.png"
      end
      assert_equal "background-image: url('<%= asset_path('images/icons.png') %>');", new_content
    end

    def test_image_in_child_directory_of_stylesheet
      current_file = "/home/package/dist/ui/stylesheet.css"
      css = "background-image: url('./images/icons.png');"

      new_content = filter.call(css, current_file) do |image_full_url|
        assert_equal "/home/package/dist/ui/images/icons.png", image_full_url
        "ui/images/icons.png"
      end
      assert_equal "background-image: url('<%= asset_path('ui/images/icons.png') %>');", new_content
    end
  end
end
