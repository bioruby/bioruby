#

require 'pathname'

envname_default_task = 'BIORUBY_RAKE_DEFAULT_TASK'

gem_dir = Pathname.new(File.join(File.dirname(__FILE__), '..')).realpath

case t = ENV[envname_default_task]
when 'gem-test'
  # do nothing
else
  $stderr.print "#{$0}: skipped: ENV[#{envname_default_task}]=#{t.inspect}\n"
  exit(0)
end

target = ENV['BUNDLE_GEMFILE']
unless target then
  $stderr.puts("Error: env BUNDLE_GEMFILE is not set.")
end

File.open(target, 'a') do |w|
  $stderr.puts "Add a line to #{target}"
  $stderr.puts "gem 'bio', :path => '#{gem_dir}'"
  w.puts ""
  w.puts "gem 'bio', :path => '#{gem_dir}'"
end

