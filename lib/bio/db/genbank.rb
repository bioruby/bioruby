#
# bio/db/genbank.rb - GenBank database class
#
#   Copyright (C) 2000, 2001 KATAYAMA Toshiaki <k@bioruby.org>
#
#  This library is free software; you can redistribute it and/or
#  modify it under the terms of the GNU Library General Public
#  License as published by the Free Software Foundation; either
#  version 2 of the License, or (at your option) any later version.
#
#  This library is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
#  Library General Public License for more details.
#

require 'bio/sequence'

class GenBank

  DELIMITER = "\n//\n"
  TAGSIZE = 12

  def initialize(entry)
    @orig = {}					# Hash of the original entry
    @data = {}					# Hash of the parsed entry

    tag = ''					# temporal key
    @orig[tag] = ''

    entry.each_line do |line|
      # to avoid null line (especially at the 1st line - gb:AARPOB2)
      next if line =~ /^$/

      if line =~ /^\w/
	tag = tag_get(line)
	@orig[tag] = '' unless @orig[tag]	# String
      end
      @orig[tag] << line
    end

    return @orig
  end


  ### general method to return block of the tag and contens as is
  def get(tag)
    @orig[tag]			# returns nil when not found
  end


  ### general method to return contens without tag and extra white spaces
  def fetch(tag)
    if get(tag)
      str = ''
      get(tag).each_line do |line|
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
    parse_LOCUS unless @data['LOCUS']
    if key			# returns the LOCUS value of the key
      @data['LOCUS'][key]
    elsif block_given?		# acts as each_locus()
      @data['LOCUS'].each do |k, v|
	yield(k, v)
      end
    else			# returns the whole LOCUS as Hash
      @data['LOCUS']
    end
  end
  alias l locus
  alias each_locus locus


  # definition - returns contents of the DEFINITION record as String
  def definition
    parse_DEFINITION unless @data['DEFINITION']
    @data['DEFINITION']
  end
  alias d definition


  # accession - returns contents of the ACCESSION record as String
  def accession
    parse_ACCESSION unless @data['ACCESSION']
    @data['ACCESSION']
  end
  alias a accession


  # version - returns contents of the VERSION record as Array of String
  def version(gi_only = nil)
    parse_VERSION unless @data['VERSION']
    if gi_only
      @data['VERSION'][1]		# returns GI: as String
    else
      @data['VERSION']			# returns A.V and GI: as Array
    end
  end
  alias v version


  # keywords - returns contents of the KEYWORDS record as Array of String
  def keywords
    parse_KEYWORDS unless @data['KEYWORDS']
    if block_given?		# acts as each_keyword()
      @data['KEYWORDS'].each do |k|
	yield(k)
      end
    else			# returns the whole KEYWORDS as Array
      @data['KEYWORDS']
    end
  end
  alias k keywords
  alias each_keyword keywords


  # segment - returns contents of the SEGMENT record as Array of Fixnum
  def segment
    parse_SEGMENT unless @data['SEGMENT']
    @data['SEGMENT']
  end


  # source - returns contents of the SOURCE record as Hash of String
  #   (key : name, organism, taxonomy)
  def source(key = nil)
    parse_SOURCE unless @data['SOURCE']
    if key			# returns the SOURCE value of the key
      @data['SOURCE'][key]
    elsif block_given?		# acts as each_source()
      @data['SOURCE'].each do |k, v|
	yield(k, v)
      end
    else			# returns the whole SOURCE as Hash
      @data['SOURCE']
    end
  end
  alias s source
  alias each_source source


  # reference - returns contents of the REFERENCE record as Array of Hash
  #   (key : AUTHORS, TITLE, JOURNAL, MEDLINE, PUBMED, REMARK)
  def reference(num = 0, key = 'REFERENCE')
    parse_REFERENCE unless @data['REFERENCE']
    num -= 1
    if num >= 0			# returns one value of the REFERENCE Hash
      @data['REFERENCE'][num][key] if @data['REFERENCE'][num]
    elsif block_given?		# acts as each_reference()
      @data['REFERENCE'].each do |r|
	yield(r)
      end
    else			# returns the whole REFERENCE Hash as Array
      @data['REFERENCE']
    end
  end
  alias r reference
  alias each_ref reference
  alias each_reference reference


  # comment - returns contents of the COMMENT record as String
  def comment
    parse_COMMENT unless @data['COMMENT']
    @data['COMMENT']
  end


  # features - returns contents of the FEATURES record as Array of Hash
  #   (key : feature, position, ...)
  def features(num = 0, key = 'position')
    parse_FEATURES unless @data['FEATURES']
    num -= 1
    if num >= 0			# returns one value of the FEATURES Hash
      @data['FEATURES'][num][key] if @data['FEATURES'][num]
    elsif block_given?		# acts as each_feature()
      @data['FEATURES'].each do |f|
	yield(f)
      end
    else			# returns the whole FEATURES Hash as Array
      @data['FEATURES']
    end
  end
  alias f features
  alias each_feature features

  def each_cds
    parse_FEATURES unless @data['FEATURES']
    @data['FEATURES'].each do |f|
      if f['feature'] == 'CDS'
	yield(f)		# iterate only for the 'CDS' features
      end
    end
  end

  def each_gene
    parse_FEATURES unless @data['FEATURES']
    @data['FEATURES'].each do |f|
      if f['feature'] == 'gene'
	yield(f)		# iterate only for the 'gene' features
      end
    end
  end


  # basecount - returns the BASE COUNT of the base as Fixnum
  #   (base : a, t, g, c and o for others)
  def basecount(base = nil)
    parse_BASE_COUNT unless @data['BASE COUNT']
    if base			# returns the BASE COUNT of the given base
      base.downcase!
      @data['BASE COUNT'][base]
    elsif block_given?		# acts as each_basecount()
      %w{ a t g c o }.each do |b|
	yield(b, @data['BASE COUNT'][b]) if @data['BASE COUNT'][b]
      end
    else			# returns the whole BASE COUNT Hash
      @data['BASE COUNT']
    end
  end
  alias bc basecount
  alias each_bc basecount
  alias each_basecount basecount


  # origin - returns contents of the ORIGIN record as String
  def origin
    parse_ORIGIN unless @data['ORIGIN']
    @data['ORIGIN']
  end


  # naseq - returns DNA sequence in the ORIGIN record as NAseq object
  def naseq
    parse_ORIGIN unless @data['SEQUENCE']
    @data['SEQUENCE']
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
    if str.length > TAGSIZE
      return str[TAGSIZE..str.length]
    else
      return ''			# to avoid returning nil
    end
  end

  def tag_cut!(str)
    str[0,tag_size] = ''
    return str
  end


  # get tag field of the line
  def tag_get(str)
    if str.length > TAGSIZE
      return str[0,TAGSIZE].strip
    else
      return ''			# to avoid returning nil
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
    @data['LOCUS'] = {}

    if @orig['LOCUS']
      @data['LOCUS']['name']     = @orig['LOCUS'][12..21].strip
      @data['LOCUS']['length']   = @orig['LOCUS'][22..28].to_i
      @data['LOCUS']['strand']   = @orig['LOCUS'][33..35].strip
      @data['LOCUS']['natype']   = @orig['LOCUS'][36..39].strip
      @data['LOCUS']['circular'] = @orig['LOCUS'][42..51].strip
      @data['LOCUS']['gbdiv']    = @orig['LOCUS'][52..54].strip
      @data['LOCUS']['date']     = @orig['LOCUS'][62..72].strip
    end

    return @data['LOCUS']
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
    @data['DEFINITION'] = fetch('DEFINITION')
    return @data['DEFINITION']
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
    @data['ACCESSION'] = fetch('ACCESSION')
    return @data['ACCESSION']
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
    @data['VERSION'] = []

    if @orig['VERSION']
      @data['VERSION'] = fetch('VERSION').split(/\s+/)
    end

    return @data['VERSION']
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
    @data['KEYWORDS'] = []

    if @orig['KEYWORDS']
      @data['KEYWORDS'] = fetch('KEYWORDS').sub(/\.$/, '').split("; ")
    end

    return @data['KEYWORDS']
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
    @data['SEGMENT'] = []

    if @orig['SEGMENT']    
      @data['SEGMENT'] = fetch('SEGMENT').scan(/\d+/)
    end

    return @data['SEGMENT']
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
    @data['SOURCE'] = {}

    if @orig['SOURCE']
      name, organism = @orig['SOURCE'].split("ORGANISM")
      organism = '' unless organism	# to avoid nil

      @data['SOURCE']['name']     = truncate(tag_cut(name))
      @data['SOURCE']['organism'] = truncate(organism.slice!(/.*/))
      @data['SOURCE']['taxonomy'] = truncate(organism)
    end

    return @data['SOURCE']
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
    @data['REFERENCE'] = []

    return @data['REFERENCE'] unless @orig['REFERENCE']

    hash = {}			# temporal hash
    key = ''			# temporal key

    @orig['REFERENCE'].each_line do |line|
      tag = tag_get(line)
      line.chomp!

      case tag
      when /REFERENCE/
	@data['REFERENCE'].push(hash) unless hash.empty?
	key = tag
	hash = { key => tag_cut(line) }
      when /\w+/
	key = tag
	hash[key] = tag_cut(line)
      else
	hash[key] << " " + tag_cut(line)
      end
    end
    @data['REFERENCE'].push(hash)

    return @data['REFERENCE']
  end


  # COMMENT  - Cross-references to other sequence entries, comparisons
  #  to other collections, notes of changes in LOCUS names, and other
  #  remarks.  Optional keyword/one or more records/may include blank
  #  records.
  #
  def parse_COMMENT
    @data['COMMENT'] = fetch('COMMENT')
    return @data['COMMENT']
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
    @data['FEATURES'] = []

    return @data['FEATURES'] unless @orig['FEATURES']

    head = ''			# temporal feature key (source, CDS, ...)
    body = ''			# temporal feature contents (pos, /qualifier=)

    @orig['FEATURES'].each_line do |line|
      if line =~ /^ {5}(\S+)\s+(\S+)/
	@data['FEATURES'].push(parse_qualifiers(head, body)) unless head.empty?
	head, body = $1, $2
      else
	body << line
      end
    end
    @data['FEATURES'].push(parse_qualifiers(head, body))

    return @data['FEATURES']
  end


  def parse_qualifiers(head, body)
    hash = { 'feature' => head }

    body.sub(%r{^[^/]+}) do |pos|
      hash['position'] = pos.gsub(/\s+/, '')	# before the 1st '/' without \s
    end

    body.scan(%r{ /(\S+)=("[^"]+"|\S+)}).each do |key, value|
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
    # set the default value of the hash to 0
    # because others ('o') is not always existing
    @data['BASE COUNT'] = Hash.new(0)

    if @orig['BASE COUNT']
      @orig['BASE COUNT'].scan(/(\d+) (\w)/).each do |n, b|
	@data['BASE COUNT'][b] = n.to_i
      end
    end

    return @data['BASE COUNT']
  end


  # ORIGIN  - Specification of how the first base of the reported
  #  sequence is operationally located within the genome. Where
  #  possible, this includes its location within a larger genetic
  #  map. Mandatory keyword/exactly one record.
  #
  #  - The ORIGIN line is followed by sequence data (multiple records).
  #
  def parse_ORIGIN
    @data['ORIGIN'] = ''

    seqence = ''		# temporal sequence String

    if @orig['ORIGIN']
      @data['ORIGIN'] = tag_cut(@orig['ORIGIN'][/.*/]) # before the 1st "\n"
      seqence = @orig['ORIGIN'].sub(/.*/, '').gsub(/[\s\d\/]+/, '')
    end

    @data['SEQUENCE'] = NAseq.new(seqence)

    return @data['ORIGIN']
  end

end

