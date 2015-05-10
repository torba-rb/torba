require "test_helper"

module Torba
  class GetFileTest < Minitest::Test
    def test_404
      exception = assert_raises(Errors::ShellCommandFailed) do
        RemoteSources::GetFile.process("http://jquery.com/jquery.zip")
      end
      assert_includes exception.message, "curl"
    end
  end
end
