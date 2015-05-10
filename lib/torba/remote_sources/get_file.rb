require "tempfile"

module Torba
  module RemoteSources
    # File downloading abstraction
    # @since unreleased
    class GetFile
      # @param url [String] to be downloaded.
      # @return [Tempfile] temporarily stored content of the URL.
      # @raise [Errors::ShellCommandFailed] if failed to fetch the URL
      def self.process(url)
        tempfile = Tempfile.new("torba")
        tempfile.close

        Torba.ui.info "downloading '#{url}'"

        command = "curl -Lf -o #{tempfile.path} #{url}"
        system(command) || raise(Errors::ShellCommandFailed.new(command))

        tempfile
      end
    end
  end
end
