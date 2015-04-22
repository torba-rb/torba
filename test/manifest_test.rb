require "test_helper"

module Torba
  class ManifestTest < Minitest::Test
    def manifest
      @manifest ||= Manifest.new
    end

    def test_zip
      manifest.zip "angular", url: "http://angularjs.com/angularjs.zip"

      assert_equal 1, manifest.packages.size

      package = manifest.packages.first
      assert_equal "angular", package.name

      remote = package.remote_source
      assert_instance_of RemoteSources::Zip, remote
      assert_equal "http://angularjs.com/angularjs.zip", remote.url
    end

    def test_zip_wo_url
      assert_raises(KeyError) do
        manifest.zip "angular"
      end
    end

    def test_gh_release
      manifest.gh_release "underscore", source: "jashkenas/underscore", tag: "1.8.3"

      assert_equal 1, manifest.packages.size

      package = manifest.packages.first
      assert_equal "underscore", package.name

      remote = package.remote_source
      assert_instance_of RemoteSources::GithubRelease, remote
      assert_equal "jashkenas/underscore", remote.source
      assert_equal "1.8.3", remote.tag
    end

    def test_gh_release_wo_source
      assert_raises(KeyError) do
        manifest.gh_release "underscore", tag: "1.8.3"
      end
    end

    def test_gh_release_wo_tag
      assert_raises(KeyError) do
        manifest.gh_release "underscore", source: "jashkenas/underscore"
      end
    end
  end
end
