require "test_helper"

module Torba
  class GithubReleaseTest < Minitest::Test
    def remote
      RemoteSources::GithubRelease.new("repo/user", "v.2.0.0")
    end

    def test_source
      assert_equal "repo/user", remote.source
    end

    def test_tag
      assert_equal "v.2.0.0", remote.tag
    end

    def test_url
      assert_equal "https://github.com/repo/user/archive/v.2.0.0.zip", remote.url
    end
  end
end
