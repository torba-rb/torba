require "test_helper"

module Torba
  class ZipTest < Minitest::Test
    def test_url
      remote = RemoteSources::Zip.new("http://jquery.com/jquery.zip")
      assert_equal "http://jquery.com/jquery.zip", remote.url
    end

    def test_unique_digest
      remote = RemoteSources::Zip.new("http://jquery.com/jquery.zip")
      same_remote = RemoteSources::Zip.new("http://jquery.com/jquery.zip")

      assert_equal remote.digest, same_remote.digest

      another_remote = RemoteSources::Zip.new("http://angularjs.com/angular.zip")

      refute_equal remote.digest, another_remote.digest
    end

    def test_digest_contains_filename
      remote = RemoteSources::Zip.new("http://jquery.com/jquery.zip")
      assert_match /^jquery-/, remote.digest
    end
  end
end
