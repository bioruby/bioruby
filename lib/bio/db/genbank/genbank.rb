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
#  $Id: genbank.rb,v 0.16 2001/08/06 19:25:36 katayama Exp $
#

require 'bio/db'

class GenBank < NCBIDB

  DELIMITER	= RS = "\n//\n"
  TAGSIZE	= 12

  def initialize(entry)
    super(entry, TAGSIZE)
  end


  # LOCUS  - A short mnemonic name for the entry, chosen to suggest the
  #  sequence's definition. Mandatory keyword/exactly one record.
  #
  # The pieces of information contained in the LOCUS record are always
  # found in fixed positions.
  #
  # The detailed format for the LOCUS record is as follows:
  #
  # Positions  Contents
  # ---------  --------
  # 01-05      LOCUS
  # 06-12      spaces
  # 13-21      Locus name
  # 22-22      space
  # 23-29      Length of sequence, right-justified
  # 31-32      bp
  # 34-36      Blank, ss- (single-stranded), ds- (double-stranded), or
  #            ms- (mixed-stranded)
  # 37-42      Blank, DNA, RNA, tRNA (transfer RNA), rRNA (ribosomal RNA),
  #            mRNA (messenger RNA), uRNA (small nuclear RNA), snRNA
  # 43-52      Blank (implies linear) or circular
  # 53-55      The division code (see Section 3.3)
  # 63-73      Date, in the form dd-MMM-yyyy (e.g., 15-MAR-1991)
  # 
  # The format change in GenBank 126.0 as follows:
  #
  # Positions  Contents
  # ---------  --------
  # 01-05      LOCUS
  # 06-12      spaces
  # 13-30      Locus name
  # 31-31      space
  # 32-42      Length of sequence, right-justified
  # 43-43      space
  # 44-45      bp
  # 46-46      space
  # 47-49      Blank, ss- (single-stranded), ds- (double-stranded), or
  #            ms- (mixed-stranded)
  # 50-54      Blank, DNA, RNA, tRNA (transfer RNA), rRNA (ribosomal RNA),
  #            mRNA (messenger RNA), uRNA (small nuclear RNA), snRNA
  # 55-55      space
  # 56-63      Blank (implies linear) or circular
  # 64-64      space
  # 65-67      The division code (see Section 3.3)
  # 68-68      space
  # 69-79      Date, in the form dd-MMM-yyyy (e.g., 15-MAR-1991)
  #
  # locus - returns pieces of the LOCUS record as Hash of String or Fixnum
  #   (key : name, length, strand, natype, circular, gbdiv, date)
  #
  # len > 61 => unpack('@12 A10 @22 A7 @33 A3 @36 A3 @42 A10 @52 A3 @62 A11')
  #
  def locus(key = nil)
    unless @data['LOCUS']
      hash = Hash.new('')
      if @orig['LOCUS'].length > 75
	hash['name']     = @orig['LOCUS'][12..30].strip
	hash['length']   = @orig['LOCUS'][31..41].to_i
	hash['strand']   = @orig['LOCUS'][46..48].strip
	hash['natype']   = @orig['LOCUS'][49..54].strip
	hash['circular'] = @orig['LOCUS'][55..63].strip
	hash['gbdiv']    = @orig['LOCUS'][64..67].strip
	hash['date']     = @orig['LOCUS'][68..78].strip
      else
	hash['name']     = @orig['LOCUS'][12..21].strip
	hash['length']   = @orig['LOCUS'][22..28].to_i
	hash['strand']   = @orig['LOCUS'][33..35].strip
	hash['natype']   = @orig['LOCUS'][36..39].strip
	hash['circular'] = @orig['LOCUS'][42..51].strip
	hash['gbdiv']    = @orig['LOCUS'][52..54].strip
	hash['date']     = @orig['LOCUS'][62..72].strip
      end
      @data['LOCUS'] = hash
    end

    if block_given?
      @data['LOCUS'].each do |k, v|
        yield(k, v)		# each contents of LOCUS
      end
    elsif key
      @data['LOCUS'][key]	# contents of key's LOCUS
    else
      @data['LOCUS']		# Hash of whole LOCUS field
    end
  end
  def id
    locus('name')
  end
  def nalen
    locus('length')
  end
  def strand
    locus('strand')
  end
  def natype
    locus('natype')
  end
  def circular
    locus('circular')
  end
  def division
    locus('gbdiv')
  end
  def date
    locus('date')
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
  # definition - returns contents of the DEFINITION record as String
  #
  def definition
    field_fetch('DEFINITION')
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
  # accession - returns contents of the ACCESSION record as String
  #
  def accession
    field_fetch('ACCESSION')
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
  # version - returns contents of the VERSION record as Array of String
  #
  def version(num = nil)
    unless @data['VERSION']
      @data['VERSION'] = field_fetch('VERSION').split(/\s+/)
    end
    if num
      @data['VERSION'][num]
    else
      @data['VERSION']
    end
  end
  def acc_version
    version(0)
  end
  def gi
    version(1)
  end


  # NID  - An alternative method of presenting the NCBI GI identifier
  #  (described above). The NID is obsolete and was removed from the
  #  GenBank flatfile format in December 1999.
  #
  # In maintaining GenBank, NCBI generates a new gi if a sequence has changed.
  #
  def nid
    field_fetch('NID')
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
  # keywords - returns contents of the KEYWORDS record as Array of String
  #
  def keywords
    unless @data['KEYWORDS']
      @data['KEYWORDS'] = field_fetch('KEYWORDS').chomp('.').split('; ')
    end

    if block_given?
      @data['KEYWORDS'].each do |k|
        yield(k)
      end
    else			# returns the whole KEYWORDS as Array
      @data['KEYWORDS']
    end
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
  # segment - returns contents of the SEGMENT record as String (m/n)
  #
  def segment
    unless @data['SEGMENT']
      @data['SEGMENT'] = field_fetch('SEGMENT').scan(/\d+/).join("/")
    end
    @data['SEGMENT']
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
  # source - returns contents of the SOURCE record as Hash of String
  #   (key : name, organism, taxonomy)
  #
  def source(key = nil)
    unless @data['SOURCE']
      name, org = get('SOURCE').split('ORGANISM')
      if org[/\S+;/]
	organism = $`
	taxonomy = $& + $'
      elsif org[/\S+\./]	# NC_001741 etc.
	organism = $`
	taxonomy = $& + $'
      else
	organism = org
	taxonomy = ''
      end
      @data['SOURCE'] = {
	'common_name'	=> truncate(tag_cut(name)),
	'organism'	=> truncate(organism),
	'taxonomy'	=> truncate(taxonomy),
      }
    end

    if block_given?
      @data['SOURCE'].each do |k, v|
        yield(k, v)		# each contents of SOURCE
      end
    elsif key
      @data['SOURCE'][key]	# contents of key's SOURCE
    else
      @data['SOURCE']		# Hash of whole SOURCE field
    end
  end
  def common_name
    source('common_name')
  end
  alias varnacular_name common_name
  def organism
    source('organism')
  end
  def taxonomy
    source('taxonomy')
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
  # reference - returns contents of the REFERENCE record as Array of Hash
  #   (key : AUTHORS, TITLE, JOURNAL, MEDLINE, PUBMED, REMARK)
  #
  def reference(num = nil, key = nil)
    field_multi_sub('REFERENCE')

    if block_given?
      @data['REFERENCE'].each do |ref|
	yield(ref)			# Hash of each REFERENCE
      end				#   obj.reference do |r| r['TITLE'] end
    elsif num
      if key
	@data['REFERENCE'][num-1][key]	# key contents of num'th REFERENCE
      else				#   obj.reference(1, 'JOURNAL') -> 1st
	@data['REFERENCE'][num-1]	# Hash of num'th REFERENCE
      end				#   obj.reference(2) -> 2nd REFERENCE
    else
      @data['REFERENCE']		# Array of Hash of REFERENCE (default)
    end					#   obj.reference
  end


  # COMMENT  - Cross-references to other sequence entries, comparisons
  #  to other collections, notes of changes in LOCUS names, and other
  #  remarks.  Optional keyword/one or more records/may include blank
  #  records.
  #
  # comment - returns contents of the COMMENT record as String
  #
  def comment
    field_fetch('COMMENT')
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
  # features - returns contents of the FEATURES record as Array of Hash
  #   (key : feature, position, ...)
  #
  def features(num = nil, key = nil)
    unless @data['FEATURES']
      @data['FEATURES'] = []
      ary = []
      @orig['FEATURES'].each_line do |line|
	next if line =~ /^FEATURES/
	head = line[0,20].strip		# feature key (source, CDS, ...)
	body = line[20,60].chomp	# feature value (position, /qualifier=)
	if line =~ /^ {5}\S/
	  ary.push([ head, body ])	# [ feature, position, /q="data", ... ]
	elsif body =~ /^ \//
	  ary.last.push(body)		# /q="data..., /q=data, /q
	else
	  ary.last.last << body		# ...data..., ...data..."
	end
      end
      ary.each do |feature|		# feature is Array
	@data['FEATURES'].push(parse_qualifiers(feature))
      end
    end

    if block_given?
      @data['FEATURES'].each do |feature|
	yield(feature)			# Hash of each FEATURES
      end				#   obj.features do |f| f['gene'] end
    elsif num				#     f.has_key?('virion'), p f, ...
      if key
	@data['FEATURES'][num-1][key]	# key contents of num'th FEATURES
      else				#   obj.features(3, 'feature') -> 3rd
	@data['FEATURES'][num-1]	# Hash of num'th FEATURES
      end				#   obj.features(2) -> 2nd FEATURES
    else
      @data['FEATURES']			# Array of Hash of FEATURES (default)
    end					#   obj.features
  end
  def each_cds
    features do |feature|
      if feature['feature'] == 'CDS'
        yield(feature)			# iterate only for the 'CDS' FEATURES
      end
    end
  end
  def each_gene
    features.each do |feature|
      if feature['feature'] == 'gene'
        yield(feature)			# iterate only for the 'gene' FEATURES
      end
    end
  end


  # BASE COUNT  - Summary of the number of occurrences of each base
  #  code in the sequence. Mandatory keyword/exactly one record.
  #
  # basecount - returns the BASE COUNT of the base as Fixnum
  #   (base : a, t, g, c and o for others)
  #
  def basecount(base = nil)
    unless @data['BASE COUNT']
      # defaults to 0 because others ('o') is not always existing
      hash = Hash.new(0)
      @orig['BASE COUNT'].scan(/(\d+) (\w)/).each do |c, b|
	hash[b] = c.to_i
      end
      @data['BASE COUNT'] = hash
    end

    if block_given?
      @data['BASE COUNT'].each do |base, count|
        yield(base, count)	# each base count pair
      end
    elsif base
      base.downcase!
      @data['BASE COUNT'][base]	# counts of the given base
    else
      @data['BASE COUNT']	# Hash of BASE COUNT
    end
  end
  def gc
    num_gc = basecount('g') + basecount('c')
    num_at = basecount('a') + basecount('t')
    return format("%.1f", num_gc * 100.0 / (num_at + num_gc)).to_f
  end


  # ORIGIN  - Specification of how the first base of the reported
  #  sequence is operationally located within the genome. Where
  #  possible, this includes its location within a larger genetic
  #  map. Mandatory keyword/exactly one record.
  #
  #  - The ORIGIN line is followed by sequence data (multiple records).
  #
  # origin - returns contents of the ORIGIN record as String
  # naseq - returns DNA sequence in the ORIGIN record as NAseq object
  #
  def origin
    unless @data['ORIGIN']
      ori = @orig['ORIGIN'][/.*/]			# 1st line
      seq = @orig['ORIGIN'].sub(/.*/, '')		# sequence lines
      @data['ORIGIN']   = truncate(tag_cut(ori))
      @data['SEQUENCE'] = NAseq.new(seq.tr('^a-z', ''))	# without [\s\d\/]+
    end
    @data['ORIGIN']
  end
  def naseq
    unless @data['SEQUENCE']
      origin
    end
    @data['SEQUENCE']
  end


  ### private methods

  private

  def parse_qualifiers(feature)
    hash = Hash.new('')

    hash['feature'] = feature.shift
    hash['position'] = feature.shift.gsub(/\s/, '')

    feature.each do |f|
      if f =~ %r{/([^=]+)=?"?([^"]*)"?}
	qualifier, data = $1, $2
#	qualifier, data = $1, truncate($2)

	if data.empty?
	  data = qualifier
	end

	case qualifier
	when 'translation'
	  hash[qualifier] = AAseq.new(data.gsub(/\s/, ''))
#	  hash[qualifier] = AAseq.new(data.tr('^A-Z', ''))
	when 'db_xref'
	  if hash[qualifier].empty?
	    hash[qualifier] = []
	  end
	  hash[qualifier].push(data)
	when 'codon_start'
	  hash[qualifier] = data.to_i
	else
	  hash[qualifier] = data
	end
      end
    end

    return hash
  end

end

