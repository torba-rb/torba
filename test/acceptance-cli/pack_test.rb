require "test_helper"

module Torba
  class PackTest < Minitest::Test
    def test_zip
      out, err, status = torba("pack", torbafile: "01_zip.rb")
      assert status.success?, err
      assert_includes out, "Torba has been packed!"
      assert_dirs_equal "test/fixtures/home_path/01", path_to_packaged("trumbowyg")
    end

    def test_targz
      out, err, status = torba("pack", torbafile: "01_targz.rb")
      assert status.success?, err
      assert_includes out, "Torba has been packed!"
      assert_dirs_equal "test/fixtures/home_path/01", path_to_packaged("trumbowyg")
    end

    def test_gh_release
      out, err, status = torba("pack", torbafile: "01_gh_release.rb")
      assert status.success?, err
      assert_includes out, "Torba has been packed!"
      assert_dirs_equal "test/fixtures/home_path/01", path_to_packaged("trumbowyg")
    end

    def test_npm
      out, err, status = torba("pack", torbafile: "02_npm.rb")
      assert status.success?, err
      assert_includes out, "Torba has been packed!"
      assert_dirs_equal "test/fixtures/home_path/02", path_to_packaged("lo_dash")
    end

    def test_without_image_asset_specified_in_import
      out, err, status = torba("pack", torbafile: "01_image_asset_not_specified.rb")
      refute status.success?, err
      assert_includes out, <<OUT
Unknown asset to process with path '#{path_to_packaged "Trumbowyg", Test::TempHome.persistent_tmp_dir}/dist/ui/images/icons-2x.png'.
Make sure that you've imported all image/font assets mentioned in a stylesheet(-s).
OUT
    end

    def test_with_not_existed_assets_mentioned_in_stylesheets
      out, err, status = torba("pack", torbafile: "03_not_existed_assets.rb")
      assert status.success?, err
      assert_includes out, "Torba has been packed!"
      assert_dirs_equal "test/fixtures/home_path/03", path_to_packaged("bourbon")
    end
  end
end
