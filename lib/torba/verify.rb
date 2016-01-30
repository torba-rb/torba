require "torba"

# We purposely skip verification during Rake execution, because Rake is used to
# run the Torba:RakeTask during the "assets:precompile" stage of deployment. In
# this case it is OK that the Torbafile hasn't been packed yet, because we are
# about to do so.
#
unless ENV["TORBA_DONT_VERIFY"] || defined?(Rake::Task)
  if STDOUT.tty?
    Torba.pretty_errors { Torba.verify }
  else
    Torba.verify
  end
end
