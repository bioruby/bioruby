$:.unshift '../lib'
require 'rubygems'

spec = Gem::Specification.new do |s|
  s.name = 'bio'
  s.version = "0.7.1"
  s.author = "BioRuby project"
  s.email = "staff@bioruby.org"
  s.homepage = "http://bioruby.org/"
  s.platform = Gem::Platform::RUBY
  s.summary = "BioRuby is a library for bioinformatics (biology + information science)."
  s.files = Dir.glob("{bin,doc,etc,lib,sample,test}/**/*").delete_if {|item| item.include?("CVS") || item.include?("rdoc")}
  s.files.concat ["ChangeLog"]
  s.require_path = 'lib'
  s.autorequire = 'bio'
end

if $0 == __FILE__
  Gem::manage_gems
  Gem::Builder.new(spec).build
end

