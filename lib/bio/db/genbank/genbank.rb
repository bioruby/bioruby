#
# bio/db/genbank.rb - GenBank database class
#
#   Copyright (C) 2000, 2001 KATAYAMA Toshiaki <k@bioruby.org>
#

require 'bio/sequence'

class GenBank

  def initialize(entry)
    @data = {}					# Hash of the entry

    tag = ''					# temporal key

    entry.each_line do |line|
      if line =~ /^\w/
	tag = tag_get(line)
	@data[tag] = '' unless @data[tag]	# String
      end
      @data[tag] << line
    end

    return
  end


  ### general method to return block of the tag and contens as is
  def get(tag = 'LOCUS')
    @data[tag]			# returns nil when not found
  end


  ### general method to return contens without tag and extra white spaces
  def fetch(tag = 'DEFINITION')
    if @data[tag]
      str = ''
      @data[tag].each_line do |line|
	str << tag_cut(line)
      end
      return truncate(str)
    else
      return nil		# compatible with get()
    end
  end


  # locus - returns pieces of the LOCUS record as Hash of String or Fixnum
  #   (key : name, length, strand, natype, circular, gbdiv, date)
  def locus(key = nil)
    parse_LOCUS unless @locus
    if key			# returns the LOCUS value of the key
      @locus[key]
    else
      if block_given?		# acts as each_locus()
	@locus.each do |k, v|
	  yield(k, v)
	end
      else			# returns the whole LOCUS as Hash
	@locus
      end
    end
  end
  alias l locus
  alias each_locus locus


  # definition - returns contents of the DEFINITION record as String
  def definition
    parse_DEFINITION unless @definition
    @definition
  end
  alias d definition


  # accession - returns contents of the ACCESSION record as String
  def accession
    parse_ACCESSION unless @accession
    @accession
  end
  alias a accession


  # version - returns contents of the VERSION record as Array of String
  def version(gi_only = nil)
    parse_VERSION unless @version
    if gi_only
      @version[1]		# returns GI: as String
    else
      @version			# returns A.V and GI: as Array
    end
  end
  alias v version


  # keywords - returns contents of the KEYWORDS record as Array of String
  def keywords
    parse_KEYWORDS unless @keywords
    if block_given?		# acts as each_keyword()
      @keywords.each do |k|
	yield(k)
      end
    else			# returns the whole KEYWORDS as Array
      @keywords
    end
  end
  alias k keywords
  alias each_keyword keywords


  # segment - returns contents of the SEGMENT record as Array of Fixnum
  def segment
    parse_SEGMENT unless @segment
    @segment
  end


  # source - returns contents of the SOURCE record as Hash of String
  #   (key : name, organism, taxonomy)
  def source(key = nil)
    parse_SOURCE unless @source
    if key			# returns the SOURCE value of the key
      @source[key]
    else
      if block_given?		# acts as each_source()
	@source.each do |k, v|
	  yield(k, v)
	end
      else			# returns the whole SOURCE as Hash
	@source
      end
    end
  end
  alias s source
  alias each_source source


  # reference - returns contents of the REFERENCE record as Array of Hash
  #   (key : AUTHORS, TITLE, JOURNAL, MEDLINE, PUBMED, REMARK)
  def reference(num = 0, key = 'REFERENCE')
    parse_REFERENCE unless @references
    num = num - 1
    if num < 0
      if block_given?		# acts as each_reference()
	@references.each do |r|
	  yield(r)
	end
      else			# returns the whole REFERENCE Hash as Array
	@references
      end
    else			# returns one value of the REFERENCE Hash
      @references[num][key]
    end
  end
  alias r reference
  alias each_ref reference
  alias each_reference reference


  # comment - returns contents of the COMMENT record as String
  def comment
    parse_COMMENT unless @comment
    @comment
  end


  # features - returns contents of the FEATURES record as Array of Hash
  #   (key : feature, position, ...)
  def features(num = 0, key = 'position')
    parse_FEATURES unless @features
    num = num - 1
    if num < 0
      if block_given?		# acts as each_feature()
	@features.each do |f|
	  yield(f)
	end
      else			# returns the whole FEATURES Hash as Array
	@features
      end
    else			# returns one value of the FEATURES Hash
      @features[num][key]
    end
  end
  alias f features
  alias each_feature features

  def each_cds
    parse_FEATURES unless @features
    @features.each do |f|
      if f['feature'] == 'CDS'
	yield(f)		# iterate only for the 'CDS' features
      end
    end
  end

  def each_gene
    parse_FEATURES unless @features
    @features.each do |f|
      if f['feature'] == 'gene'
	yield(f)		# iterate only for the 'gene' features
      end
    end
  end


  # basecount - returns the BASE COUNT of the base as Fixnum
  #   (base : a, t, g, c and o for others)
  def basecount(base = nil)
    parse_BASE_COUNT unless @bc
    if base			# returns the BASE COUNT of the given base
      base.downcase!
      @bc[base]
    else
      if block_given?		# acts as each_basecount()
	%w{ a t g c o }.each do |b|
	  yield(b, @bc[b]) if @bc[b]
	end
      else			# returns the whole BASE COUNT Hash
	@bc
      end
    end
  end
  alias bc basecount
  alias each_bc basecount
  alias each_basecount basecount


  # origin - returns contents of the ORIGIN record as String
  def origin
    parse_ORIGIN unless @origin
    @origin
  end


  # naseq - returns DNA sequence in the ORIGIN record as NAseq object
  def naseq
    parse_ORIGIN unless @sequence
    @sequence
  end


  ### change the default to private method below the line
  private


  # remove extra white spaces
  def truncate(str)
    return str.gsub(/\s+/, ' ').strip
  end

  def truncate!(str)
    # do not chain these lines to avoid performing on nil
    str.gsub!(/\s+/, ' ')
    str.strip!
    return str
  end


  # remove tag field from the line
  def tag_cut(str)
    if str.length > 12		# tag field length of the GenBank is 12
      return str[12..str.length]
    else
      return ''			# to avoid returning nil
    end
  end

  def tag_cut!(str)
    str[0,12] = ''
    return str
  end


  # get tag field of the line
  def tag_get(str)
    return str[0,12].strip	# tag field length of the GenBank is 12
  end

  def parse(tag)
    case tag
    when
      parse_HOGE
    end
  end

  # LOCUS  - A short mnemonic name for the entry, chosen to suggest the
  #  sequence's definition. Mandatory keyword/exactly one record.
  #
  # The pieces of information contained in the LOCUS record are always
  # found in fixed positions.
  #
  # The detailed format for the LOCUS record is as follows:
  #
  # Positions       Contents
  #
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
  #
  def parse_LOCUS
    @locus = {}

    if @data['LOCUS']
      @locus['name']     = @data['LOCUS'][12..21].strip
      @locus['length']   = @data['LOCUS'][22..28].to_i
      @locus['strand']   = @data['LOCUS'][33..35].strip
      @locus['natype']   = @data['LOCUS'][36..39].strip
      @locus['circular'] = @data['LOCUS'][42..51].strip
      @locus['gbdiv']    = @data['LOCUS'][52..54].strip
      @locus['date']     = @data['LOCUS'][62..72].strip
    end

    return @locus
  end


  # DEFINITION  - A concise description of the sequence. Mandatory
  #  keyword/one or more records.
  #
  # There is no limit on the number of lines that may be part of the
  # DEFINITION. The last line must end with a period.
  #
  #  - DEFINITION Format for NLM Entries
  #
  #   The first part of the definition line contains information
  # describing the genes and proteins represented by the molecular
  # sequences.  This can be gene locus names, protein names and
  # descriptions that replace or augment actual names.  Gene and gene
  # product are linked by "=".  Any special identifying terms are
  # presented within brackets, such as: {promoter}, {N-terminal}, {EC
  # 2.13.2.4}, {alternatively spliced}, or {3' region}.
  #
  #   The second part of the definition line is delimited by square
  # brackets, '[]', and provides details about the molecule type and
  # length.  The biological source, i.e., genus and species or common
  # name as cited by the author.  Developmental stage, tissue type and
  # strain are included if available.  The molecule types include:
  # Genomic, mRNA, Peptide. and Other Genomic Material. Genomic
  # molecules are assumed to be partial sequence unless "Complete" is
  # specified, whereas mRNA and peptide molecules are assumed to be
  # complete unless "Partial" is noted.
  #
  def parse_DEFINITION
    @definition = fetch('DEFINITION')
    return @definition
  end


  # ACCESSION  - The primary accession number is a unique, unchanging
  #  code assigned to each entry. (Please use this code when citing
  #  information from GenBank.) Mandatory keyword/one or more records.
  #
  #   This field contains a series of six-character and/or eight-character
  # identifiers called 'accession numbers'. The six-character accession
  # number format consists of a single uppercase letter, followed by 5 digits.
  # The eight-character accession number format consists of two uppercase
  # letters, followed by 6 digits. The 'primary', or first, of the accession
  # numbers occupies positions 13 to 18 (6-character format) or positions
  # 13 to 20 (8-character format). Subsequent 'secondary' accession numbers
  # (if present) are separated from the primary, and from each other, by a
  # single space. In some cases, multiple lines of secondary accession
  # numbers might be present, starting at position 13.
  #
  def parse_ACCESSION
    @accession = fetch('ACCESSION')
    return @accession
  end


  # VERSION  - A compound identifier consisting of the primary
  #  accession number and a numeric version number associated with the
  #  current version of the sequence data in the record. This is
  #  followed by an integer key (a "GI") assigned to the sequence by
  #  NCBI.  Mandatory keyword/exactly one record.
  #
  # Accession.Version system : replacement for NID(gi) and PID(/db_xref)
  #
  #  - Compound Accession Number
  #
  # A compound accession number consists of two parts: a stable,
  # unchanging primary-accession number portion, and a sequentially
  # increasing numeric version number.  The accession and version
  # numbers are separated by a period. The initial version number
  # assigned to a new sequence is one. Compound accessions are often
  # referred to as "Accession.Version".
  #
  #  - NCBI GI identifier
  #
  # The NCBI GI identifier of the VERSION line also serves as a method
  # for identifying the sequence data that has existed for a database
  # entry over time. GI identifiers are numeric values of one or more
  # digits. Since they are integer keys, they are less human-friendly
  # than the Accession.Version system described above. Returning to
  # our example for AF181452, it was initially assigned GI 6017929. If
  # the sequence changes, a new integer GI will be assigned, perhaps
  # 7345003 . And after the second sequence change, perhaps the GI
  # would become 10456892.
  #
  def parse_VERSION
    @version = []

    if @data['VERSION']
      @version = fetch('VERSION').split(/\s+/)
    end

    return @version
  end


  # NID  - An alternative method of presenting the NCBI GI identifier
  #  (described above). The NID is obsolete and was removed from the
  #  GenBank flatfile format in December 1999.
  #
  # In maintaining GenBank, NCBI generates a new gi if a sequence has changed.
  #
  def parse_NID
  end


  # KEYWORDS  - Short phrases describing gene products and other
  #  information about an entry. Mandatory keyword in all annotated
  #  entries/one or more records.
  #
  # The KEYWORDS field does not appear in unannotated entries, but is
  # required in all annotated entries. Keywords are separated by
  # semicolons; a "keyword" may be a single word or a phrase
  # consisting of several words. Each line in the keywords field ends
  # in a semicolon; the last line ends with a period. If no keywords
  # are included in the entry, the KEYWORDS record contains only a
  # period.
  #
  def parse_KEYWORDS
    @keywords = []

    if @data['KEYWORDS']
      @keywords = fetch('KEYWORDS').sub(/\.$/, '').split("; ")
    end

    return @keywords
  end


  # SEGMENT  - Information on the order in which this entry appears in
  #  a series of discontinuous sequences from the same molecule.
  #  Optional keyword (only in segmented entries)/exactly one record.
  #
  # The SEGMENT keyword is used when two (or more) entries of known
  # relative orientation are separated by a short (<10 kb) stretch of DNA.
  # It is limited to one line of the form `n of m', where `n' is the
  # segment number of the current entry and `m' is the total number of
  # segments.
  #
  def parse_SEGMENT
    @segment = []

    if @data['SEGMENT']    
      @segment = fetch('SEGMENT').scan(/\d+/)
    end

    return @segment
  end


  # SOURCE  - Common name of the organism or the name most frequently
  #  used in the literature. Mandatory keyword in all annotated
  #  entries/one or more records/includes one subkeyword.
  #
  #   ORGANISM  - Formal scientific name of the organism (first line)
  #    and taxonomic classification levels (second and subsequent
  #    lines).  Mandatory subkeyword in all annotated entries/two or
  #    more records.
  #
  # The SOURCE field consists of two parts. The first part is found
  # after the SOURCE keyword and contains free-format information
  # including an abbreviated form of the organism name followed by a
  # molecule type; multiple lines are allowed, but the last line must
  # end with a period.  The second part consists of information found
  # after the ORGANISM subkeyword. The formal scientific name for the
  # source organism (genus and species, where appropriate) is found on
  # the same line as ORGANISM.  The records following the ORGANISM
  # line list the taxonomic classification levels, separated by
  # semicolons and ending with a period.
  #
  def parse_SOURCE
    @source = {}

    if @data['SOURCE'] =~ /SOURCE\s+([^.]+.)\s+ORGANISM\s+(.*)\s+([^.]+.)/
      @source['name'] = truncate($1)
      @source['organism'] = truncate($2)
      @source['taxonomy'] = truncate($3)
    end

    return @source
  end


  # REFERENCE  - Citations for all articles containing data reported in
  #  this entry. Includes four subkeywords and may repeat. Mandatory
  #  keyword/one or more records.
  #
  #   AUTHORS  - Lists the authors of the citation. Mandatory
  #    subkeyword/one or more records.
  #
  #   TITLE  - Full title of citation. Optional subkeyword (present in
  #    all but unpublished citations)/one or more records.
  #
  #   JOURNAL  - Lists the journal name, volume, year, and page numbers
  #    of the citation. Mandatory subkeyword/one or more records.
  #
  #   MEDLINE  - Provides the Medline unique identifier for a
  #    citation. Optional subkeyword/one record.
  #
  #   PUBMED  - Provides the PubMed unique identifier for a
  #    citation. Optional subkeyword/one record.
  #
  #   REMARK  - Specifies the relevance of a citation to an
  #    entry. Optional subkeyword/one or more records.
  #
  # The REFERENCE field consists of five parts: the keyword REFERENCE,
  # and the subkeywords AUTHORS, TITLE (optional), JOURNAL, MEDLINE
  # (optional), PUBMED (optional), and REMARK (optional).
  #
  def parse_REFERENCE
    @references = []

    return @references unless @data['REFERENCE']

    hash = {}			# temporal hash
    key = ''			# temporal key

    @data['REFERENCE'].each_line do |line|
      tag = tag_get(line)
      line.chomp!

      case tag
      when /REFERENCE/
	@references.push(hash) unless hash.empty?
	hash = { tag => tag_cut(line) }
      when /\w+/
	key = tag
	hash[key] = tag_cut(line)
      else
	hash[key] << " " + tag_cut(line)
      end
    end
    @references.push(hash)

    return @references
  end


  # COMMENT  - Cross-references to other sequence entries, comparisons
  #  to other collections, notes of changes in LOCUS names, and other
  #  remarks.  Optional keyword/one or more records/may include blank
  #  records.
  #
  def parse_COMMENT
    @comment = fetch('COMMENT')
    return @comment
  end


  # FEATURES - Table containing information on portions of the
  #  sequence that code for proteins and RNA molecules and information
  #  on experimentally determined sites of biological significance.
  #  Optional keyword/one or more records.
  #
  # GenBank releases use a feature table format designed jointly by
  # GenBank, the EMBL Nucleotide Sequence Data Library, and the DNA
  # Data Bank of Japan. This format is in use by all three databases.
  # The most complete and accurate Feature Table documentation can be
  # found on the Web at:
  #
  #   http://www.ncbi.nlm.nih.gov/collab/FT/index.html
  #
  def parse_FEATURES
    @features = []

    return @features unless @data['FEATURES']

    tag = ''			# temporal feature key  (source, CDS, ...)
    contents = ''		# temporal feature body (pos, /qualifier=)

    @data['FEATURES'].each_line do |line|
      if line =~ /^ {5}(\S+)\s+(\S+)/
	@features.push(parse_qualifiers(tag, contents)) unless tag.empty?
	tag, contents = $1, $2
      else
	contents << line
      end
    end
    @features.push(parse_qualifiers(tag, contents))

    return @features
  end


  def parse_qualifiers(tag, contents)
    hash = { 'feature' => tag }

    contents.sub(%r{^[^/]+}) do |pos|
      hash['position'] = pos.gsub(/\s+/, '')	# before the 1st '/' without \s
    end

    contents.scan(%r{ /(\S+)=("[^"]+"|\S+)}).each do |key, value|
      value.tr!('"', '')
      if key == 'translation'
	value.gsub!(/\s+/, '')
	hash[key] = AAseq.new(value)		# Amino Acid sequence object
      else
	hash[key] = value
      end
    end

    return hash
  end


  # BASE COUNT  - Summary of the number of occurrences of each base
  #  code in the sequence. Mandatory keyword/exactly one record.
  #
  def parse_BASE_COUNT
    @bc = Hash.new(0)		# set the default value of the hash to 0
				# - others ('o') is not always existing

    if @data['BASE COUNT']
      @data['BASE COUNT'].scan(/(\d+) (\w)/).each do |n, b|
	@bc[b] = n.to_i
      end
    end

    return @bc
  end


  # ORIGIN  - Specification of how the first base of the reported
  #  sequence is operationally located within the genome. Where
  #  possible, this includes its location within a larger genetic
  #  map. Mandatory keyword/exactly one record.
  #
  #  - The ORIGIN line is followed by sequence data (multiple records).
  #
  def parse_ORIGIN
    @origin = ''

    seqence = ''		# temporal sequence String

    if @data['ORIGIN']
      @origin = tag_cut(@data['ORIGIN'][/.*/]) # before the 1st "\n"
      seqence = @data['ORIGIN'].sub(/.*/, '').gsub(/[\s\d\/]+/, '')
    end

    @sequence = NAseq.new(seqence)

    return @origin
  end

end


### END


#  def initialize(entry)
#    @hash = []
#    parse(entry)
#    return @hash
#  end
#
#  def parse(entry)
#    entry.each_line do |line|
#      if line =~ /^(\w+)/
#       tag = $1
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


#  # Store start and end line numbers of tags in hash
#  # @index["LOCUS"] = [1, 1], @index["SOURCE"] = [8, 13], ...
#  def initialize(entry)
#    @entry = entry.split("\n")
#    @index = {}
#    tag = ''
#    num = 0
#
#    @entry.each do |line|
#      if line =~ /^(\w+)/
#        if num > 0		# skip first line of the entry
#          @index[tag].push(num-1)	# end line num
#	end
#	tag = $1
#	@index[tag] = []		# (*** multiple REFERENCE fails)
#	@index[tag].push(num)		# start line num
#      end
#      num += 1
#    end
#    @index[tag].push(num)	# add last line of the entry
#    return
#  end
#
#
#  def get(tag)
#    if @index[tag]
#      s = @index[tag][0]
#      e = @index[tag][1]
#      @entry[s..e]
#    end
#  end

#   # remove tag field from the line
#   def tag_cut(str)
#     str[0,12] = ''		# tag field length of the GenBank is 12
#     return str
#   end

#   def pick(tag)
#     str = get(tag).dup		# to avoid changing original @data
#     truncate(tag_cut(str))
#   end
# 
#   def pull(tag)
#     str = get(tag).dup
#     str.sub!(".{12}", '')
#     str.gsub!("\n.{12}", "\n")
#     return str			# to avoid returning nil
#   end
# 
#   def extract(tag)
#     str = get(tag).dup
#     str.sub!(".{12}", '')
#     str.gsub!("\n.{11}", '')
#     return str
#   end
# 
#   def take(tag)
#     str = tag_cut(get(tag).dup)
#     str.gsub!("\n.{12}", ' ')
#     return str
#   end

# # to avoid ruby's "[BUG] Segmentation fault"...
# unless @data['LOCUS'].length < 62
#     format = '@12 A10 @22 A7 @33 A3 @36 A3 @42 A10 @52 A3 @62 A11'
# 
#     @locus['name'],
#     @locus['length'],
#     @locus['strand'],
#     @locus['natype'],
#     @locus['circular'],
#     @locus['gbdiv'],
#     @locus['date'] = @data['LOCUS'].unpack(format)
# 
#     @locus['length'] = @locus['length'].to_i
# end

# feature = [ { feature => source, position => pos, organism => .., }, 
#             { feature => CDS, position => pos, translation => .., }, .. ]

#gb:AB009616
#     rRNA            join(<1..488,1116..1348,2111..2419,3056..3175,3209..3216,
#                     3899..>4179)
#                     /product="16S rRNA"

#   contents = truncate(contents) + ' '		# add extra space for scan()
#   contents.scan(%r{/(\S+)="?([^"]+)"? }).each do |key, value|

#   contents.scan(%r{ /(\S+)=((?=")[^"]+(?=")|\S+)}).each do |key, value|
#   contents.scan(%r{ /(\S+)=(?:"([^"])+"|(\S+))}).each do |key, value|
#     value.tr!('"', '')
#     value.gsub!(/^"|"$/, '')

#      @bc['a'], @bc['c'], @bc['g'], @bc['t'], @bc['o'] =
#	@data['BASE COUNT'].scan(/\d+/)

# TODO
#  @locus('date') -> date object
#  @reference -> reference object
