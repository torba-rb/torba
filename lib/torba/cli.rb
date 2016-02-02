require "thor"
require "torba"

module Torba
  class Cli < Thor
    desc "pack", "download and prepare all packages defined in Torbafile"
    def pack
      Torba.pretty_errors { Torba.pack }
      Torba.ui.confirm "Torba has been packed!"
    end
    map install: :pack

    desc "verify", "check if all packages are prepared"
    def verify
      Torba.pretty_errors { Torba.verify }
      Torba.ui.confirm "Torba is prepared!"
    end

    desc "show PACKAGE", "show the source location of a particular package"
    def show(name)
      Torba.pretty_errors do
        Torba.pack
        Torba.ui.info(find_package(name).load_path)
      end
    end

    private

    def find_package(name)
      packages = Torba.find_packages_by_name(name)
      case packages.size
      when 0
        Torba.ui.error "Could not find package '#{name}'."
        exit(false)
      when 1
        packages.first
      else
        index = Torba.ui.choose_one(packages.map(&:name))
        if index
          packages[index]
        else
          exit(false)
        end
      end
    end
  end
end
