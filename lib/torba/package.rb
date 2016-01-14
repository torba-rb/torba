require "fileutils"

require "torba/css_url_to_erb_asset_path"
require "torba/import_list"

module Torba
  module Errors
    class NothingToImport < StandardError
      attr_reader :package, :path

      def initialize(options)
        @package = options.fetch(:package)
        @path = options.fetch(:path)
        super
      end
    end
  end

  # Represents remote source with explicit paths/files to be imported (i.e.
  # copied from an archive, git repository etc).
  # Stylesheets (if any) are treated specially because static "url(...)"
  # definitions should be replaced with Sprockets-aware "asset_path" helpers.
  class Package
    # @return [String] short package name, acts as as namespace within Sprockets' load path.
    #   Doesn't need to be equal to remote package name.
    attr_reader :name

    # @return instance that implements {RemoteSources::Common}
    attr_reader :remote_source

    # @return [Array<String>] list of file paths to import (relative to remote source root).
    # @example Direct path to a file
    #   ["build/underscore.js"]
    # @example {http://www.rubydoc.info/stdlib/core/Dir#glob-class_method Dir.glob} pattern
    #   ["build/*.js", "**/*.css"]
    # @example Any file within directory (including subdirectories)
    #   ["build/"] # same as ["build/**/*"]
    # @note Put in this list only files that are absolutely necessary to you as
    #   {Manifest#non_js_css_logical_paths} depends on it.
    # @see #build
    attr_reader :import_paths

    # @param name [String] see {#name}
    # @param remote_source [#[]] see {#remote_source}
    # @param options [Hash]
    # @option options [Array<String>] :import list assigned to {#import_paths}
    def initialize(name, remote_source, options = {})
      @name = name
      @remote_source = remote_source
      @import_paths = (options[:import] || ["**/*"]).sort.map do |path|
        if path.end_with?("/")
          File.join(path, "**/*")
        else
          path
        end
      end
    end

    # @return [false] if package is not build.
    def verify
      built?
    end

    # Cache remote source and import specified assets to {#load_path}.
    # @return [void]
    # @note Directories explicitly specified in {#import_paths} are not preserved after importing,
    #   i.e. resulted file tree becomes flatten. This way you can omit build specific directories
    #   when requiring assets in your project. If you want to preserve remote source file tree,
    #   use glob patterns without mentioning subdirectories in them.
    #
    #   In addition {#name} is used as a namespace folder within {#load_path} to protect file names
    #   clashing across packages.
    #
    #     package.name #=> "datepicker"
    #     package.import_paths #=> ["css/stylesheet.css", "js/*.js"]
    #     Dir[package.load_path + "/**/*"] #=> ["datepicker/stylesheet.css", "datepicker/script.js"]
    #
    #     package.name #=> "datepicker"
    #     package.import_paths #=> ["**/*.{js,css}"]
    #     Dir[package.load_path + "/**/*"] #=> ["datepicker/css/stylesheet.css", "datepicker/js/script.js"]
    def build
      return if built?
      process_stylesheets
      process_other_assets
    rescue
      remove
      raise
    end

    # @return [String] path where processed files of the package reside. It's located within
    #   {Torba.home_path} directory.
    def load_path
      @load_path ||= File.join(Torba.home_path, folder_name)
    end

    # @return [Array<String>] {https://github.com/rails/sprockets#logical-paths logical paths} that
    #   the package contains.
    # @since 0.3.0
    def logical_paths
      import_list.assets.map(&:logical_path)
    end

    # @return [Array<String>] {https://github.com/rails/sprockets#logical-paths logical paths} that the
    #   package contains except JS ans CSS.
    # @since 0.3.0
    def non_js_css_logical_paths
      import_list.non_js_css_assets.map(&:logical_path)
    end

    # @return [ImportList]
    def import_list
      @import_list ||= build_import_list
    end

    # Remove self from filesystem.
    # @return [void]
    def remove
      FileUtils.rm_rf(load_path)
    end

    private

    def built?
      Dir.exist?(load_path)
    end

    def folder_name
      digest = Torba.digest(import_paths.join << remote_source.digest)
      "#{name}-#{digest}"
    end

    def build_import_list
      assets = import_paths.flat_map do |import_path|
        path_wo_glob_metacharacters = import_path.sub(/\*.+$/, "")

        assets = remote_source[import_path].map do |absolute_path, relative_path|
          subpath =
            if relative_path == import_path
              File.basename(relative_path)
            else
              relative_path.sub(path_wo_glob_metacharacters, "")
            end

          ImportList::Asset.new(absolute_path, with_namespace(subpath))
        end

        if assets.empty?
          raise Errors::NothingToImport.new(package: name, path: import_path)
        end

        assets
      end

      ImportList.new(assets)
    end

    def process_stylesheets
      import_list.css_assets.each do |asset|
        content = File.read(asset.absolute_path)

        new_content = CssUrlToErbAssetPath.call(content, asset.absolute_path) do |image_file_path|
          image_asset = import_list.find_by_absolute_path(image_file_path)
          image_asset.logical_path
        end

        if content == new_content
          new_absolute_path = File.join(load_path, asset.logical_path)
        else
          new_absolute_path = File.join(load_path, asset.logical_path + ".erb")
        end

        ensure_directory(new_absolute_path)
        File.write(new_absolute_path, new_content)
      end
    end

    def process_other_assets
      import_list.non_css_assets.each do |asset|
        new_absolute_path = File.join(load_path, asset.logical_path)
        ensure_directory(new_absolute_path)
        FileUtils.cp(asset.absolute_path, new_absolute_path)
      end
    end

    def with_namespace(file_name)
      File.join(name, file_name)
    end

    def ensure_directory(file)
      FileUtils.mkdir_p(File.dirname(file))
    end
  end
end
