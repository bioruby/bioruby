require 'rubygems'

spec = Gem::Specification.new do |s|
  s.name = 'bio'
  s.version = "1.2.1"

  s.author = "BioRuby project"
  s.email = "staff@bioruby.org"
  s.homepage = "http://bioruby.org/"
  s.rubyforge_project = "bioruby"
  s.summary = "Bioinformatics library"
  s.description = "BioRuby is a library for bioinformatics (biology + information science)."

  s.platform = Gem::Platform::RUBY
  s.files = Dir.glob("{bin,doc,etc,lib,sample,test}/**/*").delete_if {|item| item.include?("CVS") || item.include?("rdoc")}
  s.files.concat ["README", "README.DEV", "ChangeLog"]

  # s.rdoc_options << '--exclude' << '.'
  # s.has_rdoc = false

  s.require_path = 'lib'
  s.autorequire = 'bio'

  s.bindir = "bin"
  s.executables = ["bioruby", "br_biofetch.rb", "br_biogetseq.rb", "br_bioflat.rb", "br_pmfetch.rb"]
  s.default_executable = "bioruby"
end

if $0 == __FILE__
  Gem::manage_gems
  Gem::Builder.new(spec).build
end

