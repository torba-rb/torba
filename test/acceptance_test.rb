require "test_helper"

module Torba
  class AcceptanceTest < Minitest::Test
    include Torba::Test::Exec

    def test_pack_zip
      out, err, status = torba("pack", torbafile: "01_zip.rb")
      assert status.success?, err
      assert_includes out, "Torba has been packed!"
      compare_dirs "test/fixtures/home_path/01", path_to_packaged("trumbowyg")
    end

    def test_pack_targz
      out, err, status = torba("pack", torbafile: "01_targz.rb")
      assert status.success?, err
      assert_includes out, "Torba has been packed!"
      compare_dirs "test/fixtures/home_path/01", path_to_packaged("trumbowyg")
    end

    def test_pack_gh_release
      out, err, status = torba("pack", torbafile: "01_gh_release.rb")
      assert status.success?, err
      assert_includes out, "Torba has been packed!"
      compare_dirs "test/fixtures/home_path/01", path_to_packaged("trumbowyg")
    end

    def test_pack_npm
      out, err, status = torba("pack", torbafile: "02_npm.rb")
      assert status.success?, err
      assert_includes out, "Torba has been packed!"
      compare_dirs "test/fixtures/home_path/02", path_to_packaged("lo_dash")
    end

    def test_pack_without_image_asset_specified_in_import
      out, err, status = torba("pack", torbafile: "03_image_asset_not_specified.rb")
      refute status.success?, err
      assert_includes out, <<OUT
Unknown asset to process with path '#{path_to_packaged "Trumbowyg", Test::TempHome.persistent_tmp_dir}/dist/ui/images/icons-2x.png'.
Make sure that you've imported all image/font assets mentioned in a stylesheet(-s).
OUT
    end

    def test_pack_with_not_existed_assets_mentioned_in_stylesheets
      out, err, status = torba("pack", torbafile: "04_not_existed_assets.rb")
      assert status.success?, err
      assert_includes out, "Torba has been packed!"
      compare_dirs "test/fixtures/home_path/04", path_to_packaged("bourbon")
    end

    def test_verify_unpacked
      out, err, status = torba("verify", torbafile: "01_zip.rb")
      refute status.success?, err
      assert_equal <<OUT, out
Your Torba is not packed yet.
Missing packages:
  * trumbowyg
Run `bundle exec torba pack` to install missing packages.
OUT
    end

    def test_verify_packed
      _, err, status = torba("pack", torbafile: "01_zip.rb")
      assert status.success?, err

      out, err, status = torba("verify", torbafile: "01_zip.rb")
      assert status.success?, err
      assert_equal <<OUT, out
Torba is prepared!
OUT
    end
  end
end
