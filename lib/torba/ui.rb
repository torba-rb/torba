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

    # @return [Integer] index of chosen option.
    # @return [nil] if exit was chosen.
    # @since 0.7.0
    def choose_one(options)
      options.each_with_index do |option, index|
        info("#{index + 1} : #{option}")
      end
      info("0 : - exit -")

      index = @shell.ask("> ").to_i - 1
      (0..options.size - 1).cover?(index) ? index : nil
    end
  end
end
