#
# = Rakefile - helper of developement and packaging
#
# Copyright::   Copyright (C) 2009 Naohisa Goto <ng@bioruby.org>
# License::     The Ruby License
#

require 'rake/testtask'

ERUBY = "eruby"

task :default => "test"

Rake::TestTask.new do |t|
  t.test_files = FileList["test/{unit,functional}/**/test_*.rb"]
end

desc "Update bioruby.gemspec"
task :gemspec => "bioruby.gemspec"

desc "Update bioruby.gemspec"
file "bioruby.gemspec" => "bioruby.gemspec.erb" do |t|
  sh "#{ERUBY} #{t.prerequisites[0]} > #{t.name}"
end

