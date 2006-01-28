#
# = bio/io/fastacmd.rb - NCBI fastacmd wrapper class
#
# Copyright::  Copyright (C) 2005, 2006
#              Shuji SHIGENOBU <shige@nibb.ac.jp>,
#              Toshiaki Katayama <k@bioruby.org>,
#              Mitsuteru C. Nakao <n@bioruby.org>
# Lisence::    LGPL
#
# $Id: fastacmd.rb,v 1.10 2006/01/28 08:12:21 nakao Exp $
#
# == Description
#
# Retrives FASTA formatted sequences from a blast database using 
# NCBI fastacmd command.
# 
# This class requires 'fastacmd' command and a blast database  
# (formatted using the '-o' option of 'formatdb').
#
# == Examples
#
#    database = ARGV.shift || "/db/myblastdb"
#    entry_id = ARGV.shift || "sp:128U_DROME"
#    ent_list = ["sp:1433_SPIOL", "sp:1432_MAIZE"]
#
#    fastacmd = Bio::Blast::Fastacmd.new(database)
#
#    entry = fastacmd.get_by_id(entry_id)
#    fastacmd.fetch(entry_id)
#    fastacmd.fetch(ent_list)
#
#    fastacmd.fetch(ent_list).each do |fasta|
#      puts fasta
#    end
#
# == References
#
# * NCBI tool
#   ftp://ftp.ncbi.nih.gov/blast/executables/LATEST/ncbi.tar.gz
#
# * fastacmd.html
#   http://biowulf.nih.gov/apps/blast/doc/fastacmd.html
#
#--
#
#  This library is free software; you can redistribute it and/or
#  modify it under the terms of the GNU Lesser General Public
#  License as published by the Free Software Foundation; either
#  version 2 of the License, or (at your option) any later version.
#
#  This library is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
#  Lesser General Public License for more details.
#
#  You should have received a copy of the GNU Lesser General Public
#  License along with this library; if not, write to the Free Software
#  Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307  USA
#
#++
#

require 'bio/db/fasta'
require 'bio/io/flatfile'
require 'bio/command'

module Bio
class Blast

# NCBI fastacmd wrapper class
#
class Fastacmd

  include Enumerable
  include Bio::Command::Tools

  # Database file path.
  attr_accessor :database

  # fastcmd command file path.
  attr_accessor :fastacmd

  # 
  attr_accessor :errorlog

  # Initalize a fastacmd object.
  #    
  #    fastacmd = Bio::Blast::Fastacmd.new("/db/myblastdb")
  def initialize(blast_database_file_path)
    @database = blast_database_file_path
    @fastacmd = 'fastacmd'
  end


  # get an entry_id and returns a Bio::FastaFormat object.
  #
  #   entry_id = "sp:128U_DROME"
  #   entry = fastacmd.get_by_id(entry_id)
  def get_by_id(entry_id)
    fetch(entry_id).shift
  end

  # get one or more entry_id and returns an Array of Bio::FastaFormat objects.
  #
  # Fastacmd#fetch(entry_id) returns an Array of a Bio::FastaFormat
  # object even when the result is a single entry.
  #
  #    p fastacmd.fetch(entry_id)
  #
  # Fastacmd#fetch method also accepts a list of entry_id and returns
  # an Array of Bio::FastaFormat objects.
  #    
  #    ent_list = ["sp:1433_SPIOL", "sp:1432_MAIZE"]
  #    p fastacmd.fetch(ent_list)
  #
  def fetch(list)
    if list.respond_to?(:join)
      entry_id = list.join(",")
    else
      entry_id = list
    end

    cmd = [ @fastacmd, '-d', @database, '-s', entry_id ]
    call_command_local(cmd) do |inn, out|
      inn.close_write
      Bio::FlatFile.new(Bio::FastaFormat, out).to_a
    end
  end

  # Iterates each entry.
  #
  # You can also iterate on all sequences in the database!
  #    fastacmd.each do |fasta|
  #      p [ fasta.definition[0..30], fasta.seq.size ]
  #    end
  #
  def each_entry
    cmd = [ @fastacmd, '-d', @database, '-D', 'T' ]
    call_command_local(cmd) do |inn, out|
      inn.close_write
      Bio::FlatFile.open(Bio::FastaFormat, out) do |f|
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


