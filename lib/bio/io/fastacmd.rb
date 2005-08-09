#
# bio/io/fastacmd.rb - NCBI fastacmd wrapper class
#
#   Copyright (C) 2005 Shuji SHIGENOBU <shige@nibb.ac.jp>
#   Copyright (C) 2005 Toshiaki Katayama <k@bioruby.org>
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
#  $Id: fastacmd.rb,v 1.3 2005/08/09 09:40:27 ngoto Exp $
#

require 'bio/db/fasta'
require 'bio/io/flatfile'
require 'open3'

module Bio

  class Fastacmd

    include Enumerable

    def initialize(db)
      @database = db
      @fastacmd = 'fastacmd'
    end
    attr_accessor :database, :fastacmd

    # get an entry_id and returns a Bio::FastaFormat object
    def get_by_id(entry_id)
      fetch(entry_id).shift
    end

    # get one or more entry_id and returns an Array of Bio::FastaFormat objects
    def fetch(list)
      if list.respond_to?(:join)
        entry_id = list.join(",")
      else
        entry_id = list
      end

      cmd = [ @fastacmd, '-d', @database, '-s', entry_id ]
      Open3.popen3(cmd) do |inn, out, err|
        inn.close
        t = Thread.start { err.read }
        results = Bio::FlatFile.new(Bio::FastaFormat, out).to_a
        t.join
        results
      end
    end

    def each_entry
      cmd = [ @fastacmd, '-d', @database, '-D', 'T' ]
      Open3.popen3(*cmd) do |inn, out, err|
        inn.close
        t = Thread.start { err.read }
        f = Bio::FlatFile.new(Bio::FastaFormat, out)
        f.each_entry do |e|
          yield e
        end
        t.join
      end
    end
    alias :each :each_entry

  end

end


if __FILE__ == $0

  database = ARGV.shift || "/db/myblastdb"
  entry_id = ARGV.shift || "sp:128U_DROME"
  ent_list = ["sp:1433_SPIOL", "sp:1432_MAIZE"]

  fastacmd = Bio::Fastacmd.new(database)

  ### Retrieve one sequence
  entry = fastacmd.get_by_id(entry_id)

  # Bio::Fastacmd#get_by_id(entry_id) returns a Bio::FastaFormat object.
  p entry

  # Bio::FastaFormat becomes a fasta format string when printed by puts.
  puts entry

  # Bio::Fastacmd#fetch(entry_id) returns an Array of a Bio::FastaFormat
  # object even when the result is a single entry.
  p fastacmd.fetch(entry_id)

  ### Retrieve more sequences

  # Bio::Fastacmd#fetch method also accepts a list of entry_id and returns
  # an Array of Bio::FastaFormat objects.
  p fastacmd.fetch(ent_list)

  # So, you can iterate on the results.
  fastacmd.fetch(ent_list).each do |fasta|
    puts fasta
  end


  ### Iterates on all entries

  # You can also iterate on all sequences in the database!
  fastacmd.each do |fasta|
    p [ fasta.definition[0..30], fasta.seq.size ]
  end

end

