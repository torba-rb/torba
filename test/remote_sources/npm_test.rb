require "test_helper"

module Torba
  class NpmTest < Minitest::Test
    def remote
      RemoteSources::Npm.new("coffee-script", "2.0.0")
    end

    def test_package
      assert_equal "coffee-script", remote.package
    end

    def test_tag
      assert_equal "2.0.0", remote.version
    end

    def test_url
      assert_equal "https://registry.npmjs.org/coffee-script/-/coffee-script-2.0.0.tgz", remote.url
    end

    def test_unique_digest
      remote = RemoteSources::Npm.new("coffee-script", "2.0.0")
      same_remote = RemoteSources::Npm.new("coffee-script", "2.0.0")
      assert_equal remote.digest, same_remote.digest

      another_remote = RemoteSources::Npm.new("coffee-script", "2.0.1")
      refute_equal remote.digest, another_remote.digest
    end

    def test_digest_contains_repository_name
      assert_match /^coffee-script-/, remote.digest
    end
  end
end
