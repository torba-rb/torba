require "torba"
require "rake/tasklib"

module Torba
  # Calling Torba::RakeTask.new defines a "torba:pack" Rake task that does the
  # same thing as `bundle exec torba pack`. Furthermore, if the :before option
  # is specified, the "torba:pack" task will be installed as a prerequisite to
  # the specified task.
  #
  # This is useful for deployment because it allows for packing as part of the
  # "assets:precompile" flow, which platforms like Heroku already know to
  # invoke. By hooking into "assets:precompile" as a prerequisite, Torba can
  # participate automatically, with no change to the deployment process.
  #
  # Typical use is as follows:
  #
  #   # In Rakefile
  #   require "torba/rake_task"
  #   Torba::RakeTask.new("torba:pack", :before => "assets:precompile")
  #
  # You can also provide a block, which will be executed before packing process:
  #
  #   Torba::RakeTask.new do
  #     # some preconfiguration to be run when the "torba:pack" task is executed
  #   end
  #
  # Note that when you require "torba/rails" in a Rails app, this Rake task is
  # installed for you automatically. You only need to install the task yourself
  # if you are using something different, like Sinatra.
  #
  class RakeTask < Rake::TaskLib
    attr_reader :torba_pack_task_name

    def initialize(name="torba:pack", options={}, &before_pack)
      @torba_pack_task_name = name
      define_task(before_pack)
      install_as_prerequisite(options[:before]) if options[:before]
    end

    private

    def define_task(before_pack_proc)
      desc "Download and prepare all packages defined in Torbafile"
      task torba_pack_task_name do
        before_pack_proc.call if before_pack_proc
        Torba.pretty_errors { Torba.pack }
      end
    end

    def install_as_prerequisite(other_task)
      ensure_task_defined(other_task)
      Rake::Task[other_task].enhance([torba_pack_task_name])
    end

    def ensure_task_defined(other_task)
      return if Rake::Task.task_defined?(other_task)
      Rake::Task.define_task(other_task)
    end
  end
end
