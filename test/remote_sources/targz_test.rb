require "test_helper"

module Torba
  class TargzTest < Minitest::Test
    def test_url
      remote = RemoteSources::Targz.new("http://jquery.com/jquery.tar.gz")
      assert_equal "http://jquery.com/jquery.tar.gz", remote.url
    end

    def test_unique_digest
      remote = RemoteSources::Targz.new("http://jquery.com/jquery.tar.gz")
      same_remote = RemoteSources::Targz.new("http://jquery.com/jquery.tar.gz")

      assert_equal remote.digest, same_remote.digest

      another_remote = RemoteSources::Targz.new("http://zeptojs.com/jquery.tar.gz")

      refute_equal remote.digest, another_remote.digest
    end

    def test_digest_contains_filename
      remote = RemoteSources::Targz.new("http://jquery.com/jquery.tar.gz")
      assert_match /^jquery-/, remote.digest

      remote = RemoteSources::Targz.new("http://jquery.com/jquery.tgz")
      assert_match /^jquery-/, remote.digest
    end
  end
end
