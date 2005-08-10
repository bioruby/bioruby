#
# bio/io/flatfile.rb - flatfile access wrapper class
#
#   Copyright (C) 2001-2005 GOTO Naohisa <ngoto@gen-info.osaka-u.ac.jp>
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
#  $Id: flatfile.rb,v 1.34 2005/08/10 12:51:15 k Exp $
#

module Bio

  class FlatFile

    include Enumerable

    def self.to_a(*args)
      self.auto(*args) do |ff|
        raise 'cannot determine file format' unless ff.dbclass
        ff.to_a
      end
    end

    # Bio::FlatFile.auto(filename/io[, [mode, parm,] opts]) [{block}]
    def self.auto(*args, &block)
      self.open(nil, *args, &block)
    end

    # Bio::FlatFile.open(filename/io, dbclass[, [mode, parm,] opts]) [{block}]
    #  or
    # Bio::FlatFile.open(dbclass, filename/io[, [mode, parm,] opts]) [{block}]
    def self.open(*args)
      ff = self.new(*args)
      if block_given?
        yield ff
        ff.close
      else
        ff
      end
    end

    # Bio::FlatFile.new(filename/io, dbclass[, [mode, parm,] opts])
    #  or
    # Bio::FlatFile.new(dbclass, filename/io[, [mode, parm,] opts])
    def initialize(file, dbclass, *args)
      if file.nil? or file.kind_of?(Module)
        # swap first two arguments if needed for the backward compatibility
        dbclass, file = file, dbclass
      end
      openmode = parse_opts(args)	# args is always an Array

      if file.respond_to?(:gets)	# 'file' is already an IO object
        @io = file
      else				# 'file' is a filename
        @io = File.open(file, *openmode)
      end

      @prefetch = ''			# initialize prefetch buffer
      if dbclass
	self.dbclass = dbclass
      else
	autodetect			# file format autodetection
      end
    end
    attr_reader :io

    # 1. if the 1st element is not a Hash or true, assume it as a "mode"
    #    for File.open
    # 2. if the 2nd element is not a Hash or true, assume it as a "parm"
    #    for File.open
    # 3. if the 3rd element is a Hash and have a key ':raw', use its value
    #    to specify the raw mode (other keys are not in the FlatFile spec yet).
    # 4. elsif the 3rd element is true, treat it as 'raw = true' is specified
    #    for the backward compatibility
    def parse_opts(args)
      # openmode = args.reject {|x| x.is_a?(Hash) or x.is_a?(TrueClass)}
      mode = args.shift unless args[0].is_a?(Hash) or args[0].is_a?(TrueClass)
      perm = args.shift unless args[0].is_a?(Hash) or args[0].is_a?(TrueClass)
      opts = args.shift
      openmode = [mode, perm].compact

      self.raw = false
      if opts.is_a?(Hash) and opts.has_key?(:raw)
        self.raw = opts[:raw]
      else
        self.raw = opts			# true or nil 
      end

      return openmode
    end
    private :parse_opts


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
	  if io_rs == '' then
	    sp_rs = /\n\n/n
	    sp_rs_orig = "\n\n"
	  else
	    sp_rs = Regexp.new(Regexp.escape(io_rs, 'n'), 0, 'n')
	    sp_rs_orig = io_rs
	  end
	  a = @prefetch.split(sp_rs, 2)
	  if a.size > 1 then
	    r = a[0] + sp_rs_orig
	    @prefetch = a[1]
	  else
	    @prefetch << @io.gets(io_rs).to_s
	    a = @prefetch.split(sp_rs, 2)
	    if a.size > 1 then
	      r = a[0] + sp_rs_orig
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
	
      when /^ENTRY       .+ KO\s*$/
	Bio::KEGG::KO
      when /^ENTRY       .+ Glycan\s*$/
        Bio::KEGG::GLYCAN
      when /^ENTRY       .+ (CDS|gene|.*RNA) /
	Bio::KEGG::GENES
      when /^ENTRY       EC [0-9\.]+$/
	Bio::KEGG::ENZYME
      when /^ENTRY       C[A-Za-z0-9\._]+$/
	Bio::KEGG::COMPOUND
      when /^ENTRY       R[A-Za-z0-9\._]+$/
	Bio::KEGG::REACTION
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

      when /^HEADER    .{40}\d\d\-[A-Z]{3}\-\d\d   [0-9A-Z]{4}/
	Bio::PDB

      when /^CLUSTAL .*\(.*\).*sequence +alignment/
	Bio::ClustalW::Report

      when /\<\!DOCTYPE BlastOutput PUBLIC /
        Bio::Blast::Report

      when /^BLAST.? +[\-\.\w]+\-WashU +\[[\-\.\w ]+\]/
	Bio::Blast::WU::Report
      when /^TBLAST.? +[\-\.\w]+\-WashU +\[[\-\.\w ]+\]/
	Bio::Blast::WU::Report_TBlast

      when /^BLAST.? +[\-\.\w]+ +\[[\-\.\w ]+\]/
	Bio::Blast::Default::Report
      when /^TBLAST.? +[\-\.\w]+ +\[[\-\.\w ]+\]/
	Bio::Blast::Default::Report_TBlast

      when /^psLayout version \d+\s*$/
        Bio::Blat::Report
      when /^\-\-SPIDEY version .+\-\-$/
	Bio::Spidey::Report

      when /^seq1 \= .*\, \d+ bp(\r|\r?\n)seq2 \= .*\, \d+ bp(\r|\r?\n)/
        Bio::Sim4::Report

      when /^>.+$/
	if text =~ /^>([PF]1|[DR][LC]|N[13]|XX)\;.+/ then
	  Bio::NBRF
	elsif text =~ /^>.+$\s+(^\#.*$\s*)*^\s*\d*\s*[-a-zA-Z_\.\[\]\(\)\*\+\$]+/ then
	  Bio::FastaFormat
	elsif text =~ /^>.+$\s+^\s*\d+(\s+\d+)*\s*$/ then
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

--- Bio::FlatFile.new(filename_or_stream, dbclass[, [mode, parm,] options])
--- Bio::FlatFile.new(dbclass, filename_or_stream[, [mode, parm,] options])

      Prepare to read a file or a IO stream specified in 'filename_or_stream'.
      If the 'filename_or_stream' is a filename, this method opens the local
      file as File.open(filename, mode, perm).  See the documentations on
      Ruby's Kernel#open method for the 'mode' and 'parm' options.

      The 'dbclass' must be a one of the BioRuby's database class name
      (e.g. Bio::GenBank, Bio::FastaFormat).
      If nil is given to the 'dbclass', try to determine database class
      (file format) automatically.  It is recommended to set 'dbclass'
      using FlatFile#dbclass= method if the automatic determination failed.
      Otherwise, 'dbclass' is set to nil and FlatFile#next_entry can act same
      as the IO#gets method only when the raw mode is on (raw = true).

      The last argument 'options' is a Hash (or nil to omit) containing
      flags to determine the behavior of the Bio::FlatFile instance.
      Currently, only the ':raw' flag is recognized as the key.
      If the value of options[:raw] is true, "raw mode" is on (defalut is off).
      You can also change this flag by Bio::FlatFile#raw = true afterwards.

      Backward compatibility:
      The order of the first two arguments is automatically recognized.

      * Example 1
          Bio::FlatFile.new(ARGF, Bio::GenBank)
          Bio::FlatFile.new(Bio::GenBank, ARGF)
      * Example 2
          Bio::FlatFile.new(IO.popen("gzip -dc nc1101.flat.gz"), Bio::GenBank)
      * Example 3
          Bio::FlatFile.new($stdin, nil, :raw => true)
          # following notation was also used in the old BioRuby to specify
          # the raw mode (deprecated).
          Bio::FlatFile.new($stdin, nil, true)

--- Bio::FlatFile.open(filename_or_stream, dbclass[, [mode, perm,] options])
--- Bio::FlatFile.open(dbclass, filename_or_stream[, [mode, perm,] options])

      Open a file as a flat file database in the specified 'dbclass' format.
      Similar to Bio::FlatFile.new but also accepts block.

      Refer to the document of Bio::FlatFile.new for the other options.

      Backward compatibilities:
      It is not recommended because the name of this method is resemble to
      the Ruby's File.open, but the 'filename_or_stream' can be an already
      opened IO stream.  It is also not recommended but if nil is specified
      to the 'dbclass', this method acts as the Bio::FlatFile.auto method.

      * Example 1
          ff = Bio::FlatFile.open("genbank/gbest40.seq", Bio::GenBank)
      * Example 2
          ff = Bio::FlatFile.open("embl/est_hum17.dat", nil)
      * Example 3
          ff = Bio::FlatFile.open($stdin, Bio::GenBank)

      If it is called with block, the block is passed to the newly opened
      Bio::FlatFile instance and the file will be automatically closed
      when leaving the block.

      * Example 4
          Bio::FlatFile.open('test4.fst', Bio::FastaFormat) do |ff|
            ff.each { |e| puts e.definition }
          end

--- Bio::FlatFile.auto(filename_or_stream[, [mode, perm,] options])

      Open a file or an IO stream by auto detection of the database format.
      Similar to Bio::FlatFile.open but no need to specify the 'dbclass'. 
      This method would be most useful one among the 'new', 'open' and 'auto'.
      Refer to the document of Bio::FlatFile.new for other options.

      * Example 1
          flatfile = Bio::FlatFile.auto(ARGF)
          flatfile.each do |entry|
            # do something on entry
            puts entry.entry_id
          end
      * Example 2
          Bio::FlatFile.auto("embl/est_hum17.dat")
      * Example 3
          Bio::FlatFile.auto(IO.popen("gzip -dc nc1101.flat.gz"))
      * Example 4
          Bio::FlatFile.auto(ARGF) do |flatfile|
            flatfile.each do |entry|
              # do something on entry
              puts entry.entry_id
            end
          end

--- Bio::FlatFile.to_a(filename_or_stream, *arg)

      Same as FlatFile.auto(filename_or_stream, *arg).to_a

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

