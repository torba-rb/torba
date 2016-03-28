require "test_helper"

module Torba
  class GitTest < Minitest::Test
    def test_url
      remote = RemoteSources::Git.new("https://github.com/azer/left-pad.git")
      assert_equal "https://github.com/azer/left-pad.git", remote.url
    end

    def test_unique_digest
      remote = RemoteSources::Git.new("https://github.com/azer/left-pad.git")
      same_remote = RemoteSources::Git.new("https://github.com/azer/left-pad.git")

      assert_equal remote.digest, same_remote.digest

      another_remote = RemoteSources::Git.new("https://github.com/azer/concat.git")

      refute_equal remote.digest, another_remote.digest
    end

    def test_digest_contains_filename
      remote = RemoteSources::Git.new("https://github.com/azer/left-pad.git")
      assert_match /^left-pad-/, remote.digest
    end
  end
end
