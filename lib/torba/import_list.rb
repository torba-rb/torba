module Torba
  module Errors
    AssetNotFound = Class.new(StandardError)
  end

  # Represents a list of assets to be imported from a remote source.
  class ImportList
    class Asset < Struct.new(:absolute_path, :logical_path)
      def css?
        absolute_path.end_with?(".css")
      end
    end

    # @return [Array<Asset>] full list of assets to be imported.
    attr_reader :assets

    def initialize(assets)
      @assets = assets
    end

    # @return [Asset] asset with given path.
    # @param path [String] absolute path of an asset.
    # @raise [Errors::AssetNotFound] if nothing found
    def find_by_absolute_path(path)
      assets.find { |asset| asset.absolute_path == path } || raise(Errors::AssetNotFound.new(path))
    end

    # @return [Array<Asset>] list of stylesheets to be imported.
    def css_assets
      assets.find_all { |asset| asset.css? }
    end

    # @return [Array<Asset>] list of assets to be imported except stylesheets.
    def non_css_assets
      assets.find_all { |asset| !asset.css? }
    end
  end
end
