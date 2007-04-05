#
# = bio/io/fastacmd.rb - NCBI fastacmd wrapper class
#
# Copyright::  Copyright (C) 2005, 2006
#              Shuji SHIGENOBU <shige@nibb.ac.jp>,
#              Toshiaki Katayama <k@bioruby.org>,
#              Mitsuteru C. Nakao <n@bioruby.org>,
#              Jan Aerts <jan.aerts@bbsrc.ac.uk>
# License::    The Ruby License
#
# $Id: fastacmd.rb,v 1.16 2007/04/05 23:35:41 trevor Exp $
#

require 'bio/db/fasta'
require 'bio/io/flatfile'
require 'bio/command'

module Bio
class Blast

# = DESCRIPTION
#
# Retrieves FASTA formatted sequences from a blast database using 
# NCBI fastacmd command.
# 
# This class requires 'fastacmd' command and a blast database  
# (formatted using the '-o' option of 'formatdb').
#
# = USAGE
#  require 'bio'
#  
#  fastacmd = Bio::Blast::Fastacmd.new("/db/myblastdb")
#
#  entry = fastacmd.get_by_id("sp:128U_DROME")
#  fastacmd.fetch("sp:128U_DROME")
#  fastacmd.fetch(["sp:1433_SPIOL", "sp:1432_MAIZE"])
#
#  fastacmd.fetch(["sp:1433_SPIOL", "sp:1432_MAIZE"]).each do |fasta|
#    puts fasta
#  end
#
# = REFERENCES
#
# * NCBI tool
#   ftp://ftp.ncbi.nih.gov/blast/executables/LATEST/ncbi.tar.gz
#
# * fastacmd.html
#   http://biowulf.nih.gov/apps/blast/doc/fastacmd.html
#
class Fastacmd

  include Enumerable

  # Database file path.
  attr_accessor :database

  # fastacmd command file path.
  attr_accessor :fastacmd

  # This method provides a handle to a BLASTable database, which you can then
  # use to retrieve sequences.
  # 
  # Prerequisites:
  # * You have created a BLASTable database with the '-o T' option.
  # * You have the NCBI fastacmd tool installed.
  #
  # For example, suppose the original input file looks like:
  #  >my_seq_1
  #  ACCGACCTCCGGAACGGATAGCCCGACCTACG
  #  >my_seq_2
  #  TCCGACCTTTCCTACCGCACACCTACGCCATCAC
  #  ...
  # and you've created a BLASTable database from that with the command
  #  cd /my_dir/
  #  formatdb -i my_input_file -t Test -n Test -o T
  # then you can get a handle to this database with the command
  #  fastacmd = Bio::Blast::Fastacmd.new("/my_dir/Test")
  # ---
  # *Arguments*:
  # * _database_:: path and name of BLASTable database
  def initialize(blast_database_file_path)
    @database = blast_database_file_path
    @fastacmd = 'fastacmd'
  end


  # Get the sequence of a specific entry in the BLASTable database.
  # For example:
  #  entry = fastacmd.get_by_id("sp:128U_DROME")
  # ---
  # *Arguments*:
  # * _id_: id of an entry in the BLAST database
  # *Returns*:: a Bio::FastaFormat object
  def get_by_id(entry_id)
    fetch(entry_id).shift
  end

  # Get the sequence for a _list_ of IDs in the database.
  #
  # For example:
  #  p fastacmd.fetch(["sp:1433_SPIOL", "sp:1432_MAIZE"])
  #
  # This method always returns an array of Bio::FastaFormat objects, even when 
  # the result is a single entry.
  # ---
  # *Arguments*:
  # * _ids_: list of IDs to retrieve from the database
  # *Returns*:: array of Bio::FastaFormat objects
  def fetch(list)
    if list.respond_to?(:join)
      entry_id = list.join(",")
    else
      entry_id = list
    end

    cmd = [ @fastacmd, '-d', @database, '-s', entry_id ]
    Bio::Command.call_command(cmd) do |io|
      io.close_write
      Bio::FlatFile.new(Bio::FastaFormat, io).to_a
    end
  end

  # Iterates over _all_ sequences in the database.
  #
  #  fastacmd.each_entry do |fasta|
  #    p [ fasta.definition[0..30], fasta.seq.size ]
  #  end
  # ---
  # *Returns*:: a Bio::FastaFormat object for each iteration
  def each_entry
    cmd = [ @fastacmd, '-d', @database, '-D', '1' ]
    Bio::Command.call_command(cmd) do |io|
      io.close_write
      Bio::FlatFile.open(Bio::FastaFormat, io) do |f|
        f.each_entry do |entry|
          yield entry
        end
      end
    end
    self
  end
  alias each each_entry

end # class Fastacmd

end # class Blast
end # module Bio

if $0 == __FILE__
  fastacmd = Bio::Blast::Fastacmd.new("/path_to_my_db/db_name")
  seq = fastacmd.get_by_id('id_of_entry1')
  puts seq.class
  puts seq
  
  seqs = fastacmd.fetch(['id_of_entry1','id_of_entry2'])
  seqs.each do |seq|
    puts seq
  end

  fastacmd.each_entry do |fasta|
    puts fasta.seq.size.to_s + "\t" + fasta.definition
  end
end
