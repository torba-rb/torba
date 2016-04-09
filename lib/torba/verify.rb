require "torba"

if STDOUT.tty?
  Torba.pretty_errors { Torba.verify }
else
  Torba.verify
end
