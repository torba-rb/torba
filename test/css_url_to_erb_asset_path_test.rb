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

    def test_http_url
      url = 'http://example.com/example.png'
      url_https = url.gsub('http', 'https')
      css = "background-image: url('#{url}');"
      css_https = "background-image: url('#{url_https}');"
      assert_equal css, filter.call(css, url)
      assert_equal css_https, filter.call(css_https, url_https)
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

    def test_url_with_iefix_query
      current_file = "/home/dist/ui/stylesheet.css"
      css = <<-CSS
      @font-face {
        font-family: "Material-Design-Icons";
        src: url("../font/material-design-icons/Material-Design-Icons.eot?#iefix") format("embedded-opentype");
        font-weight: normal;
        font-style: normal; }
      CSS

      new_content = filter.call(css, current_file) do |image_full_url|
        assert_equal "/home/dist/font/material-design-icons/Material-Design-Icons.eot", image_full_url
        "material-design-icons/Material-Design-Icons.eot"
      end

      assert_equal <<-CSS, new_content
      @font-face {
        font-family: "Material-Design-Icons";
        src: url("<%= asset_path('material-design-icons/Material-Design-Icons.eot') %>?#iefix") format("embedded-opentype");
        font-weight: normal;
        font-style: normal; }
      CSS
    end

    def test_url_with_svg_fragment
      current_file = "/home/dist/ui/stylesheet.css"
      css = <<-CSS
      @font-face {
        font-family: "Material-Design-Icons";
        src: url("../font/material-design-icons/Material-Design-Icons.svg#Material-Design-Icons") format("svg");
        font-weight: normal;
        font-style: normal; }
      CSS

      new_content = filter.call(css, current_file) do |image_full_url|
        assert_equal "/home/dist/font/material-design-icons/Material-Design-Icons.svg", image_full_url
        "material-design-icons/Material-Design-Icons.svg"
      end

      assert_equal <<-CSS, new_content
      @font-face {
        font-family: "Material-Design-Icons";
        src: url("<%= asset_path('material-design-icons/Material-Design-Icons.svg') %>#Material-Design-Icons") format("svg");
        font-weight: normal;
        font-style: normal; }
      CSS
    end
  end
end
