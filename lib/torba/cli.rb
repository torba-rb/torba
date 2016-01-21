require "thor"
require "torba"

module Torba
  class Cli < Thor
    desc "pack", "download and prepare all packages defined in Torbafile"
    def pack
      Torba.pretty_errors { Torba.pack }
      Torba.ui.confirm "Torba has been packed!"
    end

    desc "verify", "check if all packages are prepared"
    def verify
      Torba.pretty_errors { Torba.verify }
      Torba.ui.confirm "Torba is prepared!"
    end

    desc "clean", "delete all contents of Torba.home_path"
    def clean
      Torba.pretty_errors { Torba.clean }
      Torba.ui.confirm "Torba has been cleaned!"
    end
  end
end
