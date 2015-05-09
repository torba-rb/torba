require "test_helper"

module Torba
  class GithubReleaseTest < Minitest::Test
    def remote
      RemoteSources::GithubRelease.new("user/repo", "v.2.0.0")
    end

    def test_source
      assert_equal "user/repo", remote.source
    end

    def test_repository_name
      assert_equal "repo", remote.repository_name
    end

    def test_repository_user
      assert_equal "user", remote.repository_user
    end

    def test_tag
      assert_equal "v.2.0.0", remote.tag
    end

    def test_url
      assert_equal "https://github.com/user/repo/archive/v.2.0.0.zip", remote.url
    end

    def test_unique_digest
      remote = RemoteSources::GithubRelease.new("user/repo", "v.2.0.0")
      same_remote = RemoteSources::GithubRelease.new("user/repo", "v.2.0.0")
      assert_equal remote.digest, same_remote.digest

      another_remote = RemoteSources::GithubRelease.new("another/repo", "v.2.0.0")
      refute_equal remote.digest, another_remote.digest
    end

    def test_digest_contains_repository_name
      assert_match /^repo-/, remote.digest
    end
  end
end
