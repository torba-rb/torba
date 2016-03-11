module Torba
  # Parses content of CSS file and converts its image assets paths into Sprockets'
  # {https://github.com/rails/sprockets#logical-paths logical paths}.
  class CssUrlToErbAssetPath
    URL_RE =
      /
        (                # $1
          url\(          # url(
          \s*            # optional space
          ['"]?          # optional quote
          (?!data)       # no data URIs
          (?!http[s]?:\/\/)  # no remote URIs
          (?!\/)         # only relative location
        )
        (                # $2
          [^'"?#]+?      # location
        )
        (                # $3
          ([?#][^'"]+?)? # optional query or fragment
          ['"]?          # optional quote
          \s*            # optional space
          \)             # )
        )
      /xm

    # @return [String] CSS file content where image "url(...)" paths are replaced by ERB
    #   interpolations "url(<%= asset_path(...) %>)".
    # @param content [String] content of original CSS file
    # @param file_path [String] absolute path to original CSS file
    # @yield [image_file_path]
    # @yieldparam image_file_path [String] absolute path to original image file which is mentioned
    #   within CSS file
    # @yieldreturn [String] logical path to image file within Sprockets' virtual filesystem.
    #
    # @example
    #   content = \
    #     ".react-toolbar {
    #       width: 100%;
    #       background: url('./images/toolbar.png');
    #     }"
    #
    #   new_content = CssUrlToErbAssetPath.call(content, "/var/downloads/react_unzipped/styles.css") do |url|
    #     url.sub("/var/downloads/react_unzipped/images", "react-toolbar-js"
    #   end
    #
    #   new_content #=>
    #     ".react-toolbar {
    #       width: 100%;
    #       background: url('<%= asset_path('react-toolbar-js/toolbar.png') %>');
    #     }"
    def self.call(content, file_path)
      content.gsub(URL_RE) do
        absolute_image_file_path = File.expand_path($2, File.dirname(file_path))
        sprockets_file_path = yield absolute_image_file_path
        if sprockets_file_path
          "#{$1}<%= asset_path('#{sprockets_file_path}') %>#{$3}"
        else
          $&
        end
      end
    end
  end
end
