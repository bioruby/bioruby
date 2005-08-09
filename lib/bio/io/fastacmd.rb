#
# bio/io/fastacmd.rb - NCBI fastacmd wrapper class
#
#   Copyright (C) 2005 Shuji SHIGENOBU <shige@nibb.ac.jp>
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
#  $Id: fastacmd.rb,v 1.1 2005/08/09 07:52:45 k Exp $
#

require 'bio/db/fasta'
require 'bio/io/flatfile'
require 'open3'

module Bio

  class BlastDB

    include Enumerable

    FASTACMD = 'fastacmd'

    def initialize(db)
      @database = db
    end

    def get_by_id(id)
      cmd = "#{FASTACMD} -d #{@database} -s #{id}"
      begin
        inn, out, err = Open3.popen3(cmd)
        result = out.read
        err_msg = err.read
        fas = Bio::FastaFormat.new(result)
        return fas
      rescue
        raise "[Error] command execution failed : #{cmd}\n#{err_msg}"
      ensure
        inn.close; out.close; err.close
      end
    end

    def get_by_ids(ids) # ids: Array object
      cmd = "#{FASTACMD} -d #{@database} -s #{ids.join(',')}"
      begin
        inn, out, err = Open3.popen3(cmd)
        err_msg = err.read
        fas_set = Bio::FlatFile.new(Bio::FastaFormat, out).to_a
        return fas_set
      rescue
        raise "[Error] command execution failed : #{cmd}\n#{err_msg}"
      ensure
        inn.close; out.close; err.close
      end
    end

    def each_entry
      cmd = "#{FASTACMD} -d #{@database} -D T"
      io = IO.popen(cmd)
      f = Bio::FlatFile.new(Bio::FastaFormat, io)
      f.each_entry do |e|
        yield e
      end
      io.close
    end

    alias :each :each_entry

  end

end


if __FILE__ == $0

  # test code

  bdb = Bio::BlastDB.new("/db/myblastdb")

  # Retrieve one sequence
  puts bdb.get_by_id("P25724")

  # Retrieve one more sequences
  bdb.get_by_ids(["P25724", "AAB59189", "AAA28715"]).each do |fas|
    puts fas
  end

  # Iterate all sequences
  bdb.each do |fas|
    p [fas.definition[0..30], fas.seq.size]
  end

end

