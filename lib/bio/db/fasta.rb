#
# bio/db/fasta.rb - FASTA format class
#
#   Copyright (C) 2001 GOTO Naohisa <ngoto@gen-info.osaka-u.ac.jp>
#   Copyright (C) 2001, 2002 KATAYAMA Toshiaki <k@bioruby.org>
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
#  $Id: fasta.rb,v 1.12 2003/04/21 06:40:02 ng Exp $
#

require 'bio/db'
require 'bio/sequence'

module Bio

  class FastaFormat < DB

    DELIMITER	= RS = "\n>"

    def initialize(str)
      @definition = str[/.*/].sub(/^>/, '').strip	# 1st line
      @data = str.sub(/.*/, '')				# rests
      @data.sub!(/^>.*/m, '')	# remove trailing entries for sure
      @entry_overrun = $&
    end
    attr_accessor :definition, :data
    attr_reader :entry_overrun

    def entry
      @entry = ">#{@definition}\n#{@data.strip}\n"
    end
    alias :to_s :entry

    def query(factory)
      factory.query(@entry)
    end
    alias :fasta :query
    alias :blast :query

    def seq
      unless defined?(@seq)
        @seq = Sequence.new(@data.tr(" \t\r\n0-9", ''))	# lazy clean up
      end
      @seq
    end

    def length
      seq.length
    end

    def naseq
      Sequence::NA.new(seq)
    end

    def nalen
      self.naseq.length
    end

    def aaseq
      Sequence::AA.new(seq)
    end

    def aalen
      self.aaseq.length
    end

    def identifiers
      unless defined?(@ids) then
	@ids = FastaDefline.new(@definition)
      end
      @ids
    end

    def entry_id
      identifiers.entry_id
    end

    def gi
      identifiers.gi
    end

    def accession
      identifiers.accession
    end

    def accessions
      identifiers.accessions
    end

    def acc_version
      identifiers.acc_version
    end

    def locus
      identifiers.locus
    end

  end #class FastaFormat

  class FastaNumericFormat < FastaFormat

    undef query, blast, fasta, seq, naseq, nalen, aaseq, aalen

    def data
      unless @list
	@list = @data.strip.split(/\s+/).map {|x| x.to_i}
      end
      @list
    end

    def length
      data.length
    end

    def each
      data.each do |x|
        yield x
      end
    end

    def [](n)
      data[n]
    end

  end #class FastaNumericFormat

  class FastaDefline

    # specs are described in:
    # ftp://ftp.ncbi.nih.gov/blast/documents/README.formatdb
    # http://blast.wustl.edu/doc/FAQ-Indexing.html#Identifiers

    NSIDs = {
      # NCBI and WU-BLAST
      'gi'  => [ 'gi' ],                      # NCBI GI
      'gb'  => [ 'acc_version', 'locus' ],      # GenBank
      'emb' => [ 'acc_version', 'locus' ],      # EMBL
      'dbj' => [ 'acc_version', 'locus' ],      # DDBJ
      'sp'  => [ 'accession', 'entry_id' ],   # SWISS-PROT
      'pdb' => [ 'entry_id', 'chain' ],       # PDB
      'bbs' => [ 'number' ],                  # GenInfo Backbone Id
      'gnl' => [ 'database' , 'entry_id' ],   # General database identifier
      'ref' => [ 'acc_version' , 'locus' ],     # NCBI Reference Sequence
      'lcl' => [ 'entry_id' ],                # Local Sequence identifier

      # WU-BLAST and NCBI
      'pir' => [ 'accession', 'entry_id' ],   # PIR
      'prf' => [ 'accession', 'entry_id' ],   # Protein Research Foundation
      'pat' => [ 'country', 'number', 'serial' ], # Patents

      # WU-BLAST only
      'bbm' => [ 'number' ],      # NCBI GenInfo Backbone database identifier
      'gim' => [ 'number' ],      # NCBI GenInfo Import identifier
      'gp'  => [ 'acc_version', 'locus' ],      # GenPept
      'oth' => [ 'accession', 'name', 'release' ],  # Other (user-definable) identifier
      'tpd' => [ 'accession', 'name' ],       # Third party annotation, DDBJ
      'tpe' => [ 'accession', 'name' ],       # Third party annotation, EMBL
      'tpg' => [ 'accession', 'name' ],       # Third party annotation, GenBank

      # Original
      'ri'  => [ 'entry_id', 'rearray_id', 'len' ], # RIKEN FANTOM DB
    }

    def initialize(str)
      @deflines = []
      @info = {}
      @list_ids = []

      @entry_id = nil

      lines = str.split("\x01")
      lines.each do |line|
	add_defline(line)
      end
    end #def initialize

    attr_reader :list_ids, :info
    attr_reader :entry_id

    def add_defline(str)
      case str
      when /^\>?((?:[^\|\s]*\|)+[^\s]+)\s*(.*)$/
	# NSIDs
	# examples:
	# >gi|9910844|sp|Q9UWG2|RL3_METVA 50S ribosomal protein L3P
	#
	# note: regexp (:?) means grouping without backreferences
	i = $1
	d = $2
	tks = i.split('|')
	tks << '' if i[-1,1] == '|'
	a = parse_NSIDs(tks)
	i = a[0].join('|')
	a.unshift('|')
	d = tks.join('|') + ' ' + d unless tks.empty?
	a << d
	this_line = a
	match_EC(d)
	parse_square_brackets(d).each do |x|
	  if !match_EC(x, false) and x =~ /\A[A-Z]/ then
	    di = [  x ]
	    @list_ids << di
	    @info['organism'] = di unless @info['organism']
	  end
	end

      when /^\>?([a-zA-Z0-9]+\:[^\s]+)\s*(.*)$/
	# examples:
	# >sce:YBR160W  CDC28, SRM5; cyclin-dependent protein kinase catalytic subunit [EC:2.7.1.-] [SP:CC28_YEAST]
	# >emb:CACDC28 [X80034] C.albicans CDC28 gene 
	i = $1
	d = $2
	a = parse_ColonSepID(i)
	i = a.join(':')
	this_line = [ ':', a , d ]
	match_EC(d)
	parse_square_brackets(d).each do |x|
	  if !match_EC(x, false) and x =~ /:/ then
	    parse_ColonSepID(x)
	  elsif x =~ /\A\s*([A-Z][A-Z0-9_\.]+)\s*\z/ then
	    @list_ids << [ $1 ]
	  end
	end

      when /^\>?([^\s.]+)(?:\s+(.+))?$/
	# examples:
	# >ABC12345 this is test
	i = $1
	d = $2
	@list_ids << [ i ]
	this_line = [  '', [ i ], d ]
	match_EC(d)
      else
	i = line
	d = ''
	this_line = [ '', [ i ], d ]
      end

      @deflines << this_line
      @entry_id = i unless @entry_id
    end

    def match_EC(str, write_flag = true)
      di = nil
      str.scan /EC\:((:?[\-\d]+\.){3}(:?[\-\d]+))/i do |x|
	di = [ 'EC', $1 ]
	if write_flag then
	  @info['ec'] = di if (!@info['ec'] or @info['ec'].to_s =~ /\-/)
	  @list_ids << di
	end
      end
      di
    end
    private :match_EC

    def parse_square_brackets(str)
      r = []
      str.scan(/\[([^\]]*)\]/) do |x|
	r << x[0]
      end
      r
    end
    private :parse_square_brackets

    def parse_ColonSepID(str)
      di = str.split(':', 2)
      di << nil if di.size <= 1 
      @list_ids << di
      @info[di[0].downcase] = di unless @info[di[0]]
      di
    end
    private :parse_ColonSepID

    def parse_NSIDs(ary)
      # this method destroys ary
      data = []
      while token = ary.shift
	if labels = self.class::NSIDs[token] then
	  di = [ token ]
	  idtype = token
	  labels.each do |x|
	    token = ary.shift
	    break unless token
	    if self.class::NSIDs[token] then
	      ary.unshift(token)
	      break #each
	    end
	    if token.length > 0 then
	      di << token
	    else
	      di << nil
	    end
	  end
	  data << di
	  @info[idtype] = di unless @info[idtype]
	else
	  if token.length > 0 then
	    # UCID (uncontrolled identifiers)
	    di = [ token ]
	    data << di
	    idtype = 'ucid'
	    @info[idtype] = di unless @info[idtype]
	  end
	  break #while
	end
      end #while
      @list_ids.concat data
      data
    end #def parse_NSIDs
    private :parse_NSIDs

    def to_s
      @deflines.collect { |a|
	s = a[0]
	(a[1..-2].collect { |x| x.join(s) }.join(s) + ' ' + a[-1]).strip
      }.join("\x01")
    end

    def description
      @deflines[0].to_a[-1]
    end

    def descriptions
      @deflines.collect do |a|
	a[-1]
      end
    end

    def id_strings
      r = []
      @list_ids.each do |a|
	if a.size >= 2 then
	  r.concat a[1..-1].find_all { |x| x }
	else
	  if a[0].to_s.size > 0 and a[0] =~ /\A[A-Za-z0-9\.\-\_]+\z/
	    r << a[0]
	  end
	end
      end
      r
    end

    def words(case_sensitive = nil)
      a = descriptions.join(' ').split(/[\.\,\;\:\(\)\[\]\{\}\"\'\/\s]+/)
      a.collect! { |x| x.downcase } unless case_sensitive
      r = a.find_all do |x|
	if x.size <= 1 then
	  nil
	else
	  case x
	  when 'an', 'is', 'are', 'were', 'the', 'id', 'protein'
	    nil
	  else
	    true
	  end
	end
      end
      r.uniq!
      r
    end

    def get_all(db)
      if di = @info[db.to_s] then
	di
      else
	nil
      end
    end

    def get(db)
      r = nil
      if di = @info[db.to_s] then
	if di.size <= 2 then
	  r = di[-1]
	else
	  labels = self.class::NSIDs[db.to_s]
	  [ 'acc_version', 'entry_id',
	    'locus', 'accession', 'number'].each do |x|
	    if i = labels.index(x) then
	      r = di[i+1]
	      break if r
	    end
	  end
	  r = di[1..-1].find { |x| x } unless r
	end
      else
	r = nil
      end
      r
    end

    def get_by_type(tstr)
      @list_ids.each do |x|
	if labels = self.class::NSIDs[x[0]] then
	  if i = labels.index(tstr) then
	    return x[i+1]
	  end
	end
      end
      nil
    end

    def get_all_id_by_type(*tstrarg)
      d = []
      @list_ids.each do |x|
	if labels = self.class::NSIDs[x[0]] then
	  tstrarg.each do |y|
	    if i = labels.index(y) then
	      d << x[i+1] if x[i+1]
	    end
	  end
	end
      end
      d
    end

    def locus
      unless defined?(@locus)
	@locus = get_by_type('locus')
      end
      @locus
    end

    def gi
      unless defined?(@gi) then
	@gi = get_by_type('gi')
      end
      @gi
    end

    def acc_version
      unless defined?(@acc_version) then
	@acc_version = get_by_type('acc_version')
      end
      @acc_version
    end

    def accessions
      unless defined?(@accessions) then
	@accessions = get_all_id_by_type('accession', 'acc_version')
	@accessions.collect! { |x| x.sub(/\..*\z/, '') }
      end
      @accessions
    end

    def accession
      unless defined?(@accession) then
	if acc_version then
	  @accession = acc_version.split('.')[0]
	else
	  @accession = accessions[0]
	end
      end
      @accession
    end
    
    def method_missing(name, *args)
      # raise ArgumentError,
      # "wrong # of arguments(#{args.size} for 1)" if args.size >= 2
      r = get(name, *args)
      if !r and !(self.class::NSIDs[name.to_s]) then
	raise "NameError: undefined method `#{name.inspect}'"
      end
      r
    end

  end #class FastaDefline

end #module Bio

if __FILE__ == $0

  f_str = <<END
>sce:YBR160W  CDC28, SRM5; cyclin-dependent protein kinase catalytic subunit [EC:2.7.1.-] [SP:CC28_YEAST]
MSGELANYKRLEKVGEGTYGVVYKALDLRPGQGQRVVALKKIRLESEDEG
VPSTAIREISLLKELKDDNIVRLYDIVHSDAHKLYLVFEFLDLDLKRYME
GIPKDQPLGADIVKKFMMQLCKGIAYCHSHRILHRDLKPQNLLINKDGNL
KLGDFGLARAFGVPLRAYTHEIVTLWYRAPEVLLGGKQYSTGVDTWSIGC
IFAEMCNRKPIFSGDSEIDQIFKIFRVLGTPNEAIWPDIVYLPDFKPSFP
QWRRKDLSQVVPSLDPRGIDLLDKLLAYDPINRISARRAAIHPYFQES
>sce:YBR274W  CHK1; probable serine/threonine-protein kinase [EC:2.7.1.-] [SP:KB9S_YEAST]
MSLSQVSPLPHIKDVVLGDTVGQGAFACVKNAHLQMDPSIILAVKFIHVP
TCKKMGLSDKDITKEVVLQSKCSKHPNVLRLIDCNVSKEYMWIILEMADG
GDLFDKIEPDVGVDSDVAQFYFQQLVSAINYLHVECGVAHRDIKPENILL
DKNGNLKLADFGLASQFRRKDGTLRVSMDQRGSPPYMAPEVLYSEEGYYA
DRTDIWSIGILLFVLLTGQTPWELPSLENEDFVFFIENDGNLNWGPWSKI
EFTHLNLLRKILQPDPNKRVTLKALKLHPWVLRRASFSGDDGLCNDPELL
AKKLFSHLKVSLSNENYLKFTQDTNSNNRYISTQPIGNELAELEHDSMHF
QTVSNTQRAFTSYDSNTNYNSGTGMTQEAKWTQFISYDIAALQFHSDEND
CNELVKRHLQFNPNKLTKFYTLQPMDVLLPILEKALNLSQIRVKPDLFAN
FERLCELLGYDNVFPLIINIKTKSNGGYQLCGSISIIKIEEELKSVGFER
KTGDPLEWRRLFKKISTICRDIILIPN
END

  f = Bio::FastaFormat.new(f_str)
  puts "### FastaFormat"
  puts "# entry"
  puts f.entry
  puts "# entry_id"
  p f.entry_id
  puts "# definition"
  p f.definition
  puts "# data"
  p f.data
  puts "# seq"
  p f.seq
  puts "# seq.type"
  p f.seq.type
  puts "# length"
  p f.length
  puts "# aaseq"
  p f.aaseq
  puts "# aaseq.type"
  p f.aaseq.type
  puts "# aaseq.composition"
  p f.aaseq.composition
  puts "# aalen"
  p f.aalen

  puts

  n_str = <<END
>CRA3575282.F 
24 15 23 29 20 13 20 21 21 23 22 25 13 22 17 15 25 27 32 26  
32 29 29 25
END

  n = Bio::FastaNumericFormat.new(n_str)
  puts "### FastaNumericFormat"
  puts "# entry"
  puts n.entry
  puts "# entry_id"
  p n.entry_id
  puts "# definition"
  p n.definition
  puts "# data"
  p n.data
  puts "# length"
  p n.length
  puts "# percent to ratio by yield"
  n.each do |x|
    p x/100.0
  end
  puts "# first three"
  p n[0]
  p n[1]
  p n[2]
  puts "# last one"
  p n[-1]

end

=begin

= Bio::FastaFormat

Treats a FASTA formatted entry, such as:

  >id and/or some comments                    <== comment line
  ATGCATGCATGCATGCATGCATGCATGCATGCATGC        <== sequence lines
  ATGCATGCATGCATGCATGCATGCATGCATGCATGC
  ATGCATGCATGC

The precedent '>' can be omitted and the trailing '>' will be removed
automatically.

--- Bio::FastaFormat.new(entry)

      Stores the comment and sequence information from one entry of the
      FASTA format string.  If the argument contains more than one
      entry, only the first entry is used.

--- Bio::FastaFormat#entry

      Returns the stored one entry as a FASTA format. (same as to_s)

--- Bio::FastaFormat#definition
--- Bio::FastaFormat#entry_id

      Returns the comment line of the FASTA formatted data.

--- Bio::FastaFormat#seq

      Returns a joined sequence line as a String.

--- Bio::FastaFormat#query(factory)
--- Bio::FastaFormat#fasta(factory)
--- Bio::FastaFormat#blast(factory)

      Executes FASTA/BLAST search by using a Bio::Fasta or a Bio::Blast
      factory object.

        #!/usr/bin/env ruby

        require 'bio'

        factory = Bio::Fasta.local('fasta34', 'db/swissprot.f')
        flatfile = Bio::FlatFile.open(Bio::FastaFormat, 'queries.f')
        flatfile.each do |entry|
          p entry.definition
          result = entry.fasta(factory)
          result.each do |hit|
            print "#{hit.query_id} : #{hit.evalue}\t#{hit.target_id} at "
            p hit.lap_at
          end
        end

--- Bio::FastaFormat#length

      Returns sequence length.

--- Bio::FastaFormat#naseq
--- Bio::FastaFormat#nalen
--- Bio::FastaFormat#aaseq
--- Bio::FastaFormat#aalen

      If you know whether the sequence is NA or AA, use these methods.
      'naseq' and 'aaseq' methods returen the Bio::Sequence::NA or
      Bio::Sequence::AA object respectively. 'nalen' and 'aalen' methods
      return the length of them.


= Bio::FastaNumericFormat

Treats a FASTA formatted numerical entry, such as:

  >id and/or some comments                    <== comment line
  24 15 23 29 20 13 20 21 21 23 22 25 13      <== numerical data
  22 17 15 25 27 32 26 32 29 29 25

The precedent '>' can be omitted and the trailing '>' will be removed
automatically.

--- Bio::FastaNumericFormat.new(entry)

      Stores the comment and the list of the numerical data.

--- Bio::FastaNumericFormat#definition
--- Bio::FastaNumericFormat#entry_id

      The comment line of the FASTA formatted data.

--- Bio::FastaNumericFormat#data

      Returns the list of the numerical data (typically the quality score
      of its corresponding sequence) as an Array.

--- Bio::FastaNumericFormat#length

      Returns the number of elements in the numerical data.

--- Bio::FastaNumericFormat#each

      Yields on each elements of the numerical data.

--- Bio::FastaNumericFormat#[](n)

      Returns the n-th element.

=end


