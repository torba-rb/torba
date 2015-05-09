module Torba
  module RemoteSources
    module Common
      # Expands pattern inside content of the remote source.
      # @return [Array<Array(String, String)>] where first element of the tuple is an absolute
      #   path to cached file and second element is the same path relative to cache directory.
      # @param pattern [String] see {http://www.rubydoc.info/stdlib/core/Dir#glob-class_method Dir.glob}
      #   for pattern examples
      # @note Unlike Dir.glob doesn't include directories.
      def [](pattern)
        ensure_cached

        Dir.glob(File.join(cache_path, pattern)).reject{ |path| File.directory?(path) }.map do |path|
          [File.absolute_path(path), path.sub(/#{cache_path}\/?/, "")]
        end
      end

      # @return [String] unique short name used as a representation of the remote source.
      #   Used by default as a cache folder name.
      def digest
        raise NotImplementedError
      end

      private

      def cache_path
        @cache_path ||= File.join(Torba.cache_path, digest)
      end

      def ensure_cached
        raise NotImplementedError
      end
    end
  end
end
