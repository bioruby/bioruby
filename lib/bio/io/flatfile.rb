#
# bio/io/flatfile.rb - flatfile access wrapper class
#
#   Copyright (C) 2001, 2002 GOTO Naohisa <ngoto@gen-info.osaka-u.ac.jp>
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
#  $Id: flatfile.rb,v 1.4 2002/08/16 17:17:51 k Exp $
#

module Bio

  class FlatFile

    def self.open(dbclass, filename, *mode)
      ios = File.open(filename, *mode)
      self.new(dbclass, ios)
    end

    def initialize(dbclass, stream, raw = false)
      @io	= stream
      @dbclass	= dbclass
      @rs	= dbclass::DELIMITER
      self.raw	= raw
    end
    attr_reader :dbclass, :io

    def next_entry
      if @entry_raw = @io.gets(@rs) then
	if raw then
	  @entry_raw
	else
	  @dbclass.new(@entry_raw)
	end
      else
	nil
      end
    end
    attr_reader :entry_raw

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
      @io.rewind
    end

    def close
      @io.close
    end

    def raw=(bool)
      @raw = (bool ? true : false)
    end
    attr_reader :raw

  end

end


if __FILE__ == $0
  if ARGV.size == 2
    require 'bio'
    p Bio::FlatFile.open(eval(ARGV.shift), ARGV.shift).next_entry
  end
end


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
          Bio::FlatFile.new(Bio::GenBank, ARGF)
      * Example 2
          Bio::FlatFile.new(Bio::GenBank, IO.popen("gzip -dc nc1101.flat.gz"))

--- Bio::FlatFile#next_entry

      Get next entry.

--- Bio::FlatFile#each_entry { |entry| ... }
--- Bio::FlatFile#each { |entry| ... }

      Iterates over each entry in the flatfile.

      * Example
          include Bio
          ff = FlatFile.open(GenBank, "genbank/gbhtg14.seq")
          ff.each_entry do |x|
            puts x.definition
          end

--- Bio::FlatFile#to_a

      Creates an array that contains all entries in the flatfile.

--- Bio::FlatFile#rewind

      Resets file pointer to the start of the flatfile.
      (Same as IO#rewind)

--- Bio::FlatFile#close

      Closes input stream.
      (Same as IO#close)

--- Bio::FlatFile#raw=

      Assign true or false.  If true, the next_entry method returns
      a entry as a text, whereas if false, as a parsed object.

--- Bio::FlatFile#raw

      Returns current state of the raw mode.

--- Bio::FlatFile#entry_raw

      Returns the current entry as a text.

=end


