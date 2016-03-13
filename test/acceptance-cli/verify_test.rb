require "test_helper"

module Torba
  class VerifyTest < Minitest::Test
    def test_unpacked
      out, err, status = torba("verify", torbafile: "01_zip.rb")
      refute status.success?, err
      assert_equal <<OUT, out
Your Torba is not packed yet.
Missing packages:
  * trumbowyg
Run `bundle exec torba pack` to install missing packages.
OUT
    end

    def test_packed
      _, err, status = torba("pack", torbafile: "01_zip.rb")
      assert status.success?, err

      out, err, status = torba("verify", torbafile: "01_zip.rb")
      assert status.success?, err
      assert_includes out, "Torba is prepared!"
    end
  end
end
