#

require 'pathname'
require 'fileutils'

envname_default_task = 'BIORUBY_RAKE_DEFAULT_TASK'

gem_dir = Pathname.new(File.join(File.dirname(__FILE__), '..')).realpath

case t = ENV[envname_default_task]
when 'gem-test'
  # do nothing
else
  $stderr.print "#{$0}: skipped: ENV[#{envname_default_task}]=#{t.inspect}\n"
  exit(0)
end

$stderr.puts "cd #{gem_dir}"
Dir.chdir(gem_dir)

args = [ 'bioruby.gemspec', '.gemspec' ]

$stderr.puts(['cp', *args].join(" "))
FileUtils.cp(*args)

