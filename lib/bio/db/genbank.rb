#
# bio/db/genbank.rb - GenBank database class
#
#   Copyright (c) 2000 KATAYAMA Toshiaki <k@bioruby.org>
#

require 'bio/db'
require 'bio/sequence'

class GenBank < BioDB

#  def initialize(entry)
#    @hash = []
#    parse(entry)
#    return @hash
#  end
#
#  def parse(entry)
#    entry.each_line do |line|
#      if line =~ /^(\w+)/
#	tag = $1
#      end
#      @hash[tag] << line
#    end
#    parse_tags()
#  end
#
#  def parse_tags
#    parse_LOCUS()
#    parse_DEFINITION()
#    parse_ACCESSION()
#    parse_NID()
#    parse_VERSION()
#    parse_KEYWORDS()
#    parse_SEGMENT()
#    parse_SOURCE()
#    parse_REFERENCE()
#    parse_COMMENT()
#    parse_FEATURES()
#    parse_BASE()
#    parse_ORIGIN()
#  end


  # Store start and end line numbers of tags in hash
  # @index["LOCUS"] = [1, 1], @index["SOURCE"] = [8, 13], ...
  def initialize(@entry)
    @index = {}
    num = 0

    @entry.each_line do |line|
      if line =~ /^(\w+)/
	if num > 0		# skip first line of the entry
	  @index[tag].push(num-1)
	end
	tag = $1
	@index[tag] = []
	@index[tag].push(num)
      end
      num += 1
    end
    @index[tag].push(num)	# add last line of the entry
    return
  end


  def get(tag)
    s = @index[tag][0]
    e = @index[tag][1]
    @hash[tag] = @entry[s..e]
  end


  # The pieces of information contained in the LOCUS record are always
  # found in fixed positions.
  #
  # The detailed format for the LOCUS record is as follows:
  #
  # Positions       Contents
  # 1-12    LOCUS
  # 13-22   Locus name
  # 23-29   Length of sequence, right-justified
  # 31-32   bp
  # 34-36   Blank, ss- (single-stranded), ds- (double-stranded), or
  #         ms- (mixed-stranded)
  # 37-40   Blank, DNA, RNA, tRNA (transfer RNA), rRNA (ribosomal RNA), 
  #         mRNA (messenger RNA), or uRNA (small nuclear RNA)
  # 43-52   Blank (implies linear) or circular
  # 53-55   The division code (see Section 3.3)
  # 63-73   Date, in the form dd-MMM-yyyy (e.g., 15-MAR-1991)
  def parse_LOCUS
    get(LOCUS)
    locus = @hash['LOCUS']
    @hash['LOCUS_NAME']		= locus.unpack('@12 A10').strip
    @hash['LOCUS_LENGTH']	= locus.unpack('@22 C7')
    @hash['LOCUS_STRAND']	= locus.unpack('@33 A3').strip
    @hash['LOCUS_NATYPE']	= locus.unpack('@36 A3').strip
    @hash['LOCUS_CIRCULAR']	= locus.unpack('@42 A10').strip
    @hash['LOCUS_GBDIV']	= locus.unpack('@52 A3').strip
    @hash['LOCUS_DATE']		= locus.unpack('@62 A11').strip
  end

  # There is no limit on the number of lines that may be part of
  # the DEFINITION. The last line must end with a period.
  def parse_DEFINITION
  end


  # In some cases, multiple lines of secondary accession numbers
  # might be present.
  def parse_ACCESSION
  end


  # In maintaining GenBank, NCBI generates a new gi if a sequence has changed.
  def parse_NID
  end


  # Accession.Version system : replacement for NID(gi) and PID(/db_xref)
  def parse_VERSION
  end


  # Keywords are separated by semicolons; the last line ends with a period.
  def parse_KEYWORDS
  end


  # limited to one line of the form `n of m', where `n' is the segment
  # number of the current entry and `m' is the total number of segments.
  def parse_SEGMENT
  end


  # The first part : contains free-format information including an abbreviated
  # form of the organism name followed by a molecule type; multiple lines are
  # allowed, but the last line must end with a period.
  # The second part : The formal scientific name for the source organism
  # (genus and species, where appropriate), the taxonomic classification
  # levels, separated by semicolons and ending with a period.
  def parse_SOURCE
    @hash["SOURCE"].each do |line|

#SOURCE      human.
#  ORGANISM  Homo sapiens
#            Eukaryota; Metazoa; Chordata; Craniata; Vertebrata; Euteleostomi;
#            Mammalia; Eutheria; Primates; Catarrhini; Hominidae; Homo.

    end
  end

  def get(tag)
#hoge
  end

  def getseq
    seq = NTseq.new
  end
end
