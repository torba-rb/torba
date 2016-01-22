module Torba
  class Engine < Rails::Engine
    initializer "torba.assets" do |app|
      Rails.application.config.assets.paths.concat(Torba.load_path)
      Rails.application.config.assets.precompile.concat(Torba.non_js_css_logical_paths)
    end

    rake_tasks do
      require "torba/rake_task"
      Torba::RakeTask.new("torba:pack", :before => "assets:precompile")
    end
  end
end
