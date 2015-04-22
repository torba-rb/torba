require "thor/shell"

module Torba
  # Thin wrapper around Thor::Shell.
  class Ui
    def initialize
      @shell = Thor::Base.shell.new
    end

    def info(message)
      @shell.say(message)
    end

    def confirm(message)
      @shell.say(message, :green)
    end

    def suggest(message)
      @shell.say(message, :yellow)
    end

    def error(message)
      @shell.say(message, :red)
    end
  end
end
