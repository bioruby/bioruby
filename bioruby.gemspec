Gem::Specification.new do |s|
  s.name = 'bio'
  s.version = "1.2.9.9001"

  s.author = "BioRuby project"
  s.email = "staff@bioruby.org"
  s.homepage = "http://bioruby.org/"
  s.rubyforge_project = "bioruby"
  s.summary = "Bioinformatics library"
  s.description = "BioRuby is a library for bioinformatics (biology + information science)."

  s.platform = Gem::Platform::RUBY
  s.files = Dir.glob("{bin,doc,etc,lib,sample,test}/**/*").delete_if {|item| item.include?("CVS") || item.include?("rdoc")}
  s.files.concat ["README.rdoc", "README_DEV.rdoc", "ChangeLog"]

  s.has_rdoc = true
  s.extra_rdoc_files = [ 'README.rdoc', 'README_DEV.rdoc' ]
  s.rdoc_options << '--main' << 'README.rdoc'
  s.rdoc_options << '--exclude' << '\.yaml\z'

  s.require_path = 'lib'
  s.autorequire = 'bio'

  s.bindir = "bin"
  s.executables = ["bioruby", "br_biofetch.rb", "br_biogetseq.rb", "br_bioflat.rb", "br_pmfetch.rb"]
  s.default_executable = "bioruby"
end
