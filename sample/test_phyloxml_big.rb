#
# = sample/test_phyloxml_big.rb - Tests for Bio::PhyloXML. Testing very big files.
#
# Copyright::   Copyright (C) 2009
#               Diana Jaunzeikare <latvianlinuxgirl@gmail.com>
#               Naohisa Goto <ng@bioruby.org>
# License::     The Ruby License
#

# libraries needed for the tests
require 'libxml'
require 'pathname'
require 'test/unit'
require 'digest/sha1'

require 'bio/command'
require 'bio/db/phyloxml/phyloxml_parser'
require 'bio/db/phyloxml/phyloxml_writer'

PhyloXMLBigDataPath = ARGV.shift

if !PhyloXMLBigDataPath then
  exit_code = 0
elsif !File.directory?(PhyloXMLBigDataPath) then
  exit_code = 1
else
  exit_code = false
end

if exit_code then
  puts "Usage: #{$0} path_to_data (test options...)"
  puts ""
  puts "Requirements:"
  puts " - Write permission to the path_to_data"
  puts " - Internet connection for downloading test data"
  puts " - unzip command to extract downloaded test data"
  puts ""
  puts "You may want to run Ruby with -rubygems and -I<path_to_bioruby_lib>."
  puts ""
  puts "Example of usage using /tmp:"
  puts "    $ mkdir /tmp/phyloxml"
  puts "    $ ruby -rubygems -I lib #{$0} /tmp/phyloxml -v"
  puts ""
  exit(exit_code)
end

module TestPhyloXMLBigData

  module_function

  def metazoa_xml
    #puts "Metazoa 30MB"
    filename = 'ncbi_taxonomy_metazoa.xml'
    uri = "http://www.phylosoft.org/archaeopteryx/examples/data/ncbi_taxonomy_metazoa.xml.zip"
    download_and_unzip_if_not_found(filename, uri, "1M", "33M")
  end

  def metazoa_test_xml
    #puts "writing Metazoa 30MB"
    File.join PhyloXMLBigDataPath, 'writer_test_ncbi_taxonomy_metazoa.xml'
  end

  def metazoa_roundtrip_xml
    #puts "writing Metazoa 30MB roundtrip"
    File.join PhyloXMLBigDataPath, 'roundtrip_test_ncbi_taxonomy_metazoa.xml'
  end

  def mollusca_xml
    #puts "Mollusca 1.5MB"
    filename = 'ncbi_taxonomy_mollusca.xml'
    uri = "http://www.phylosoft.org/archaeopteryx/examples/data/ncbi_taxonomy_mollusca.xml.zip"
    download_and_unzip_if_not_found(filename, uri, "67K", "1.5M")
  end

  def mollusca_test_xml
    #puts "Writing Mollusca 1.5MB"
    File.join PhyloXMLBigDataPath, 'writer_test_ncbi_taxonomy_mollusca.xml'
  end

  def mollusca_roundtrip_xml
    #puts "Writing Mollusca 1.5MB roundtrip"
    File.join PhyloXMLBigDataPath, 'roundtrip_test_ncbi_taxonomy_mollusca.xml'
  end

  def life_xml
    #Right now this file is not compatible with xsd 1.10
    filename = 'tol_life_on_earth_1.xml'
    uri = "http://www.phylosoft.org/archaeopteryx/examples/data/tol_life_on_earth_1.xml.zip"

    download_and_unzip_if_not_found(filename, uri, '10M', '45M')
  end

  def life_test_xml
    File.join PhyloXMLBigDataPath, 'writer_test_tol_life_on_earth_1.xml'
  end

  def life_roundtrip_xml
    File.join PhyloXMLBigDataPath, 'roundtrip_test_tol_life_on_earth_1.xml'
  end

  def unzip_file(file, target_dir)
    flag = system('unzip', "#{file}.zip", "-d", target_dir)
    unless flag then
      raise "Failed to unzip #{file}.zip"
    end
    file
  end

  def download_and_unzip_if_not_found(basename, uri, zipsize, origsize)
    file = File.join PhyloXMLBigDataPath, basename
    return file if File.exists?(file)

    if File.exists?("#{file}.zip")
      unzip_file(file, PhyloXMLBigDataPath)
      return file
    end

    puts "File #{basename} does not exist. Do you want to download it? (If yes, ~#{zipsize}B zip file will be downloaded and extracted (to #{origsize}B), if no, the test will be skipped.) y/n?"
    res = gets
    if res.to_s.chomp.downcase == "y"
      File.open("#{file}.zip", "wb") do |f|
        f.write(Bio::Command.read_uri(uri))
      end
      puts "File downloaded."
      self.unzip_file(file, PhyloXMLBigDataPath)
      return file
    else
      return nil
      #return File.join PHYLOXML_TEST_DATA, "#{basename}.stub"
    end
  end

end #end module TestPhyloXMLBigData

module Bio

  class TestPhyloXMLBig < Test::Unit::TestCase

    def do_test_next_tree(readfilename)
      raise "the test is skipped" unless readfilename
      filesizeMB = File.size(readfilename) / 1048576.0
      printf "Reading %s (%2.1f MB)\n", readfilename, filesizeMB
             
      begin
        phyloxml = Bio::PhyloXML::Parser.open(readfilename)
      rescue NoMethodError
        phyloxml = Bio::PhyloXML::Parser.new(readfilename)
      end
      tree = nil
      assert_nothing_raised {
        tree = phyloxml.next_tree
      }
      tree
    end
    private :do_test_next_tree

    def do_test_write(tree, writefilename)
      printf "Writing to %s\n", writefilename
      writer = Bio::PhyloXML::Writer.new(writefilename)
      assert_nothing_raised {
        writer.write(tree)
      }

      # checks file size and sha1sum
      str = File.open(writefilename, 'rb') { |f| f.read }
      sha1 = Digest::SHA1.hexdigest(str)
      puts "Wrote #{str.length} bytes."
      puts "sha1: #{sha1}"
    end
    private :do_test_write

    def test_mollusca
      tree = do_test_next_tree(TestPhyloXMLBigData.mollusca_xml)
      do_test_write(tree, TestPhyloXMLBigData.mollusca_test_xml)

      tree2 = do_test_next_tree(TestPhyloXMLBigData.mollusca_test_xml)
      do_test_write(tree2, TestPhyloXMLBigData.mollusca_roundtrip_xml)
    end

    def test_metazoa
      tree = do_test_next_tree(TestPhyloXMLBigData.metazoa_xml)
      do_test_write(tree, TestPhyloXMLBigData.metazoa_test_xml)

      tree2 = do_test_next_tree(TestPhyloXMLBigData.metazoa_test_xml)
      do_test_write(tree2, TestPhyloXMLBigData.metazoa_roundtrip_xml)
    end

    if false
      # Disabled because of the error.
      # LibXML::XML::Error: Fatal error: Input is not proper UTF-8,
      # indicate encoding !
      # Bytes: 0xE9 0x6B 0x65 0x73 at tol_life_on_earth_1.xml:132170.
      #
      def test_life
        tree = do_test_next_tree(TestPhyloXMLBigData.life_xml)
        do_test_write(tree, TestPhyloXMLBigData.life_test_xml)
        
        tree2 = do_test_next_tree(TestPhyloXMLBigData.life_test_xml)
        do_test_write(tree2, TestPhyloXMLBigData.life_roundtrip_xml)
      end
    end #if false

  end

end
