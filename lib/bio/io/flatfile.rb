#
# bio/io/flatfile.rb - flatfile access wrapper class
#
#   Copyright (C) 2001 GOTO Naohisa <ngoto@gen-info.osaka-u.ac.jp>
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
#  $Id: flatfile.rb,v 1.2 2001/11/06 16:58:53 okuji Exp $
#

=begin

= Bio::FlatFile

--- Bio::FlatFile.open(dbclass, filename)

      Opens a local file 'filename' which conteins 'dbclass' format data.
      'dbclass' shoud be a class. e.g. Bio::GenBank, Bio::FastaFormat

      * Example
        Bio::FlatFile.open(Bio::GenBank, "genbank/gbest40.seq")

--- Bio::FlatFile.new(dbclass, stream)

      Same as FlatFile.open, except that 'stream' should be a opened
      stream object (IO, File, ..., who have the 'gets' method).

      * Example 1
        Bio::FlatFile.new(Bio::GenBank, $<)
      * Example 2
        Bio::FlatFile.new(Bio::GenBank, IO.popen("gzip -dc nc1101.flat.gz"))

--- next_entry

      Get next entry.

--- each_entry { |entry| ... }
--- each { |entry| ... }

      Iterates over each entry in the flatfile.

      * Example
        include Bio
        ff = FlatFile.open(GenBank, "genbank/gbhtg14.seq")
        ff.each_entry do |x|
          print x.definition, "\n"
        end

--- to_a

      Creates an array that contains all entries in the flatfile.

--- rewind

      Resets file pointer to the start of the flatfile.
      (Same as IO#rewind)

--- close

      Closes input stream.
      (Same as IO#close)

=end


module Bio

  class FlatFile

    def self.open(dbclass, filename)
      ios = File.open(filename)
      self.new(dbclass, ios)
    end

    def initialize(dbclass, stream)
      @ios	= stream
      @dbclass	= dbclass
      @rs	= dbclass::DELIMITER
    end

    def next_entry
      if e = @ios.gets(@rs) then
	@dbclass.new(e)
      else
	nil
      end
    end

    def each_entry
      while e = self.next_entry
	yield e
      end
    end
    alias :each :each_entry

    def to_a
      ary = []
      while e = self.next_entry
	ary << e
      end
      ary
    end

    def rewind
      @ios.rewind
    end

    def close
      @ios.close
    end

  end

end

