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
#  $Id: flatfile.rb,v 1.19 2003/07/29 09:22:18 ng Exp $
#

module Bio

  class FlatFile

    include Enumerable

    def self.open(dbclass, f, *mode)
      raw = false
      openmode = []
      while x = mode.shift and !x.is_a?(Hash)
	openmode << x
      end
      if x.is_a?(Hash) then
	raw = x[:raw]
      end
      unless f.respond_to?(:gets)
	f = File.open(f, *openmode)
	op = true
      end
      ff = self.new(dbclass, f, raw)
      if block_given? then
	r = yield ff
	f.close if op
	r
      else
	ff
      end
    end

    def self.auto(f, *mode, &block)
      self.open(nil, f, *mode, &block)
    end

    def self.to_a(f, *mode)
      ff = self.auto(f, *mode)
      a = ff.to_a
      ff.close unless f.respond_to?(:gets)
      a
    end

    def initialize(dbclass, stream, raw = false)
      @io	= stream
      self.raw	= raw
      @prefetch = ''
      if dbclass then
	self.dbclass = dbclass
      else
	autodetect
      end
    end
    attr_reader :io

    def next_entry
      @entry_raw = gets(@rs)
      return nil unless @entry_raw
      if raw then
	@entry_raw
      else
	e = @dbclass.new(@entry_raw)
	begin
	  s = e.entry_overrun
	rescue NameError
	  s = nil
	end
	if s then
	  @entry_raw[-(s.length), s.length] = ''
	  ungets(s)
	end
	e
      end
    end
    attr_reader :entry_raw

    def each_entry
      while e = self.next_entry
	yield e
      end
    end
    alias :each :each_entry

    def rewind
      r = @io.rewind
      @prefetch = ''
      r
    end

    def close
      @io.close
    end

    def pos
      @io.pos - @prefetch.size
    end

    def pos=(p)
      r = (@io.pos = p)
      @prefetch = ''
      r
    end

    def eof?
      if @prefetch.size > 0
	false
      else
	@io.eof?
      end
    end

    def gets(io_rs = $/)
      if @prefetch.size > 0
	if io_rs == nil then
	  r = @prefetch + @io.gets(nil).to_s
	  @prefetch = ''
	else
	  sp_rs = io_rs
	  sp_rs = "\n\n" if io_rs == ''
	  a = @prefetch.split(sp_rs, 2)
	  if a.size > 1 then
	    r = a[0] + sp_rs
	    @prefetch = a[1]
	  else
	    @prefetch << @io.gets(io_rs).to_s
	    a = @prefetch.split(sp_rs, 2)
	    if a.size > 1 then
	      r = a[0] + sp_rs
	      @prefetch = a[1].to_s
	    else
	      r = @prefetch
	      @prefetch = ''
	    end
	  end
	end
	r
      else
	@io.gets(io_rs)
      end
    end

    def ungets(str)
      @prefetch = str + @prefetch
      nil
    end

    def getc
      if @prefetch.size > 0 then
	r = @prefetch[0]
	@prefetch = @prefetch[1..-1]
      else
	r = @io.getc
      end
      r
    end

    def ungetc(c)
      @prefetch = sprintf("%c", c) + @prefetch
      nil
    end

    def raw=(bool)
      @raw = (bool ? true : false)
    end
    attr_reader :raw

    def dbclass=(k)
      if k then
	@dbclass = k
	@rs = @dbclass::DELIMITER
      else
	@dbclass = nil
	@rs = $/
      end
    end
    attr_reader :dbclass

    # format autodetection
    def autodetect(lines = 31)
      r = nil
      1.upto(lines) do |x|
	if line = @io.gets then
	  @prefetch << line
	  if line and line.strip.size > 0 then
	    r = self.class.autodetect(@prefetch)
	    if r then
	      self.dbclass = r
	      return r
	    end
	  end
	end
      end
      self.dbclass = nil unless dbclass
      r
    end

    def self.autodetect_file(filename)
      ff = self.open(nil, filename)
      r = ff.dbclass
      ff.close
      r
    end

    def self.autodetect_stream(io)
      ff = self.new(nil, io)
      r = ff.dbclass
      r
    end

    def self.autodetect(text)
      require 'bio'
      case text
      when /^LOCUS       .+ bp .*[a-z]*[DR]?NA/
	Bio::GenBank
      when /^LOCUS       .+ aa .+/
	Bio::GenPept
      when /^UI  \- [0-9]+$/
	Bio::MEDLINE
	
      when /^ID   .+\; *(DNA|RNA|XXX)\;/
	Bio::EMBL
      when /^ID   .+\; *PRT\;/
	Bio::SPTR
      when /^ID   [-A-Za-z0-9_\.]+\; (PATTERN|RULE|MATRIX)\.$/
	Bio::PROSITE
      when /^AC  [-A-Za-z0-9_\.]+$/
	Bio::TRANSFAC

      when /^H [-A-Z0-9_\.]+$/
	if text =~ /^M [rc]/ then
	  Bio::AAindex2
	elsif text =~ /^I    A\/L/ then
	  Bio::AAindex1
	else
	  false #fail to determine
	end

      when /^CODE        [0-9]+$/
	Bio::LITDB
      when /^Entry           [A-Z0-9]+/
	Bio::KEGG::BRITE
	
      when /^ENTRY       .+ CDS /
	Bio::KEGG::GENES
      when /^ENTRY       EC [0-9\.]+$/
	Bio::KEGG::ENZYME
      when /^ENTRY       [A-Z0-9\._]+$/
	Bio::KEGG::COMPOUND
      when /^ENTRY       [a-z]+$/
	Bio::KEGG::GENOME

      when /\<\!DOCTYPE\s+maxml\-(sequences|clusters)\s+SYSTEM/
	if $1 == 'clusters'
	  Bio::FANTOM::MaXML::Cluster
	elsif $1 == 'sequences'
	  Bio::FANTOM::MaXML::Sequence
	else
	  nil #unknown
	end

      when /^CLUSTAL .*\(.*\).*sequence +alignment/
	Bio::ClustalW::Report

      when /^>.+$/
	if text =~ /^>.+$\s^\s*[-a-zA-Z_\.\[\]\(\)\*\+\$]+/ then
	  Bio::FastaFormat
	elsif text =~ /^>.+$\s^\s*[0-9]+/ then
	  Bio::FastaNumericFormat
	else
	  false #fail to determine
	end

      else
	nil #not found
      end
    end

  end #class FlatFile

end #module Bio


if __FILE__ == $0
  if ARGV.size == 2
    require 'bio'
    p Bio::FlatFile.open(eval(ARGV.shift), ARGV.shift).next_entry
  end
end


=begin

= Bio::FlatFile

--- Bio::FlatFile.auto(filename_or_stream, *mode)

      Same as Bio::FlatFile.open(nil, filename_or_stream, *mode).

      * Example 1
          Bio::FlatFile.auto(ARGF)
      * Example 2
          Bio::FlatFile.auto("embl/est_hum17.dat")
      * Example 3
          Bio::FlatFile.auto(IO.popen("gzip -dc nc1101.flat.gz"))

--- Bio::FlatFile.open(dbclass, filename_or_stream, *mode)

      Prepare to read a file or a stream 'filename_or_stream'
      which contains 'dbclass'-style formatted data.

      If 'filename_or_stream' is a filename (which doesn't have gets method),
      the method opens a local file named 'filename_or_stream'
      with mode '*mode'.

      'dbclass' shoud be a class. e.g. Bio::GenBank, Bio::FastaFormat.

      When nil is given to dbclass, trying to determine database class
      (file format) automatically. If fails to determine, dbclass is
      set to nil and FlatFile#next_entry works same as IO#gets when
      raw = true. It is recommended to set dbclass using
      FlatFile#dbclass= method if fails to determine automatically.

      * Example 1
          Bio::FlatFile.open(Bio::GenBank, "genbank/gbest40.seq")
      * Example 2
          Bio::FlatFile.open(nil, "embl/est_hum17.dat")
      * Example 3
          Bio::FlatFile.open(Bio::GenBank, STDIN)

      If it is called with block, the block will be executed with
      a newly opened Bio::FlatFile instance object. If filename
      is given, the file is automatically closed when leaving the block.

      * Example 4
          Bio::FlatFile.open(nil, 'test4.fst') do |ff|
              ff.each { |e| print e.definition, "\n" }
          end

--- Bio::FlatFile.new(dbclass, stream)

      Same as FlatFile.open, except that 'stream' should be a opened
      stream object (IO, File, ..., who have the 'gets' method).

      * Example 1
          Bio::FlatFile.new(Bio::GenBank, ARGF)
      * Example 2
          Bio::FlatFile.new(Bio::GenBank, IO.popen("gzip -dc nc1101.flat.gz"))

--- Bio::FlatFile.to_a(filename_or_stream, *mode)

      Same as FlatFile.auto(filename_or_stream, *mode).to_a


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

--- Bio::FlatFile#io

      Returns input stream (IO object).

--- Bio::FlatFile#pos

      Returns current position of input stream.
      (Same as IO#pos, but may not be equal to io.pos,
       because  FlatFile#autodetect may pre-read some lines.)

--- Bio::FlatFile#eof?

      Returns true if input stream is end-of-file.
      Otherwise, returns false.
      (Same as IO#eof?, but may not be equal to io.eof?,
       because  FlatFile#autodetect may pre-read some lines.)

--- Bio::FlatFile#dbclass

      Returns database class given in FlatFile#initialize
      (FlatFile.new or FlatFile.open).

--- Bio::FlatFile#dbclass=(klass)

      Sets database class. (Plese use only if autodetect fails.)

--- Bio::FlatFile#autodetect([lines])

      Performs determination of database class (file format).
      Pre-reads 'lines' lines for format determination (default 31 lines).
      If fails, returns nil or false. Otherwise, returns database class.
      It may be useful if input file is a mixture of muitiple format data.

--- Bio::FlatFile.autodetect(str)

      Determines database class (== file format) of given string.
      If fails to determine, returns false or nil.

--- Bio::FlatFile.autodetect_file(filename)

      Determines database class (== file format) of given file.
      If fails to determine, returns nil.

--- Bio::FlatFile.autodetect_stream(io)

      Determines database class (== file format) of given input stream.
      If fails to determine, returns nil.
      Caution: the method reads some data from the input stream,
      and the data will be lost.

=end

