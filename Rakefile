require "bundler/gem_tasks"

task :default => :test
task :test do
  $LOAD_PATH.unshift("test")
  Dir.glob("./test/**/*_test.rb").each { |file| require file}
end
