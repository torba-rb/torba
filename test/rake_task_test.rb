require "test_helper"
require "torba/rake_task"

module Torba
  class RakeTaskTest < Minitest::Test
    include Rake::DSL

    def setup
      task "environment"
      task "assets:precompile" => "environment"
      Torba::RakeTask.new("torba:pack", :before => "assets:precompile")
    end

    def teardown
      Rake::Task.clear
    end

    def test_torba_pack_task_is_defined
      assert(Rake::Task.task_defined?("torba:pack"))
    end

    def test_torba_pack_task_has_description
      torba_task = Rake::Task["torba:pack"]
      torba_task.comment =~ /Torbafile/
    end

    def test_torba_pack_is_installed_as_prerequisite
      precompile_task = Rake::Task["assets:precompile"]
      assert_equal(%w(environment torba:pack), precompile_task.prerequisites)
    end

    def test_invoking_torba_pack
      Torba.expects(:pack).once
      Rake::Task["torba:pack"].invoke
    end

    def test_defines_task_if_doesnt_exist
      Rake::Task.clear
      Torba::RakeTask.new("torba:pack", :before => "something:else")

      assert(Rake::Task.task_defined?("something:else"))
      other_task = Rake::Task["something:else"]
      assert_equal(%w(torba:pack), other_task.prerequisites)
    end

    def test_alternative_task_name_can_be_specified
      Rake::Task.clear
      Torba::RakeTask.new("package")

      assert(Rake::Task.task_defined?("package"))

      Torba.expects(:pack).once
      Rake::Task["package"].invoke
    end
  end
end
