module Torba
  class Engine < Rails::Engine
    initializer "torba.assets" do |app|
      Rails.application.config.assets.paths.concat(Torba.load_path)
    end
  end
end
