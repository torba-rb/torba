require "test_helper"

module Torba
  class AcceptanceTest < Minitest::Test
    include Torba::Test::Exec

    def test_pack_zip
      out, err, status = torba("pack", torbafile: "01_zip.rb")
      assert status.success?, err
      assert_equal <<OUT, out
downloading 'https://github.com/torba-rb/Trumbowyg/archive/1.1.6.zip'
Torba has been packed!
OUT
      compare_dirs "test/fixtures/home_path/01", path_to_packaged("trumbowyg")
    end

    def test_pack_targz
      out, err, status = torba("pack", torbafile: "01_targz.rb")
      assert status.success?, err
      assert_equal <<OUT, out
downloading 'https://github.com/torba-rb/Trumbowyg/archive/1.1.6.tar.gz'
Torba has been packed!
OUT
      compare_dirs "test/fixtures/home_path/01", path_to_packaged("trumbowyg")
    end

    def test_pack_gh_release
      out, err, status = torba("pack", torbafile: "01_gh_release.rb")
      assert status.success?, err
      assert_equal <<OUT, out
downloading 'https://github.com/torba-rb/Trumbowyg/archive/1.1.6.zip'
Torba has been packed!
OUT
      compare_dirs "test/fixtures/home_path/01", path_to_packaged("trumbowyg")
    end

    def test_pack_npm
      out, err, status = torba("pack", torbafile: "02_npm.rb")
      assert status.success?, err
      assert_equal <<OUT, out
downloading 'https://registry.npmjs.org/lodash/-/lodash-0.1.0.tgz'
Torba has been packed!
OUT
      compare_dirs "test/fixtures/home_path/02", path_to_packaged("lo_dash")
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
