require "test_helper"

module Torba
  class ManifestTest < Minitest::Test
    def manifest
      @manifest ||= Manifest.new
    end

    def package
      manifest.packages.first
    end

    def remote
      package.remote_source
    end

    def test_zip
      manifest.zip "angular", url: "http://angularjs.com/angularjs.zip"

      assert_equal 1, manifest.packages.size
      assert_equal "angular", package.name
      assert_instance_of RemoteSources::Zip, remote
      assert_equal "http://angularjs.com/angularjs.zip", remote.url
    end

    def test_targz
      manifest.targz "angular", url: "http://angularjs.com/angularjs.targz"

      assert_equal 1, manifest.packages.size
      assert_equal "angular", package.name
      assert_instance_of RemoteSources::Targz, remote
      assert_equal "http://angularjs.com/angularjs.targz", remote.url
    end

    def test_zip_wo_url
      assert_raises(KeyError) do
        manifest.zip "angular"
      end
    end

    def test_gh_release
      manifest.gh_release "lo-dash", source: "jashkenas/underscore", tag: "1.8.3"

      assert_equal 1, manifest.packages.size
      assert_equal "lo-dash", package.name
      assert_instance_of RemoteSources::GithubRelease, remote
      assert_equal "jashkenas/underscore", remote.source
      assert_equal "1.8.3", remote.tag
    end

    def test_gh_release_implicit_name
      manifest.gh_release source: "jashkenas/underscore", tag: "1.8.3"
      assert_equal "underscore", package.name
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

    def test_npm
      manifest.npm "coffee", package: "coffee-script", version: "1.8.3"

      assert_equal 1, manifest.packages.size
      assert_equal "coffee", package.name
      assert_instance_of RemoteSources::Npm, remote
      assert_equal "coffee-script", remote.package
      assert_equal "1.8.3", remote.version
    end

    def test_npm_implicit_name
      manifest.npm package: "coffee-script", version: "1.8.3"
      assert_equal "coffee-script", package.name
    end

    def test_npm_wo_package
      assert_raises(KeyError) do
        manifest.npm version: "1.8.3"
      end
    end

    def test_npm_wo_version
      assert_raises(KeyError) do
        manifest.npm package: "underscore"
      end
    end

    def test_non_js_css_logical_paths
      manifest.zip "angular", url: "http://angularjs.com/angularjs.zip"
      manifest.zip "backbone", url: "http://backbonejs.com/backbonejs.zip"

      manifest.packages[0].stub :non_js_css_logical_paths, ["angular.png"] do
        manifest.packages[1].stub :non_js_css_logical_paths, ["backbone.png"] do
          assert_equal %w[angular.png backbone.png], manifest.non_js_css_logical_paths
        end
      end
    end

    def test_verify
      manifest.zip "angular", url: "http://angularjs.com/angularjs.zip"
      manifest.npm package: "coffee-script", version: "1.8.3"

      error = assert_raises(Torba::Errors::MissingPackages) { manifest.verify }

      assert_equal error.packages.map(&:name), %w(angular coffee-script)
    end

    def test_clean
      torba_home_path = '/tmp/torba_home_path'
      FileUtils.mkdir_p torba_home_path
      FileUtils.rm_rf torba_home_path
      refute_exists torba_home_path
    end
  end
end
