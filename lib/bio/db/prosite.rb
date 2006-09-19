#
# = bio/db/prosite.rb - PROSITE database class
#
# Copyright::  Copyright (C) 2001 Toshiaki Katayama <k@bioruby.org>
# Licence::    Ruby's
#
# $Id: prosite.rb,v 0.16 2006/09/19 06:03:51 k Exp $
#

require 'bio/db'

module Bio

class PROSITE < EMBLDB

  # Delimiter
  DELIMITER = "\n//\n"

  # Delimiter
  RS = DELIMITER

  # Bio::DB API
  TAGSIZE = 5


  def initialize(entry)
    super(entry, TAGSIZE)
  end


  # ID  Identification                     (Begins each entry; 1 per entry)
  #
  #  ID   ENTRY_NAME; ENTRY_TYPE.  (ENTRY_TYPE : PATTERN, MATRIX, RULE)
  #
  # Returns
  def name
    unless @data['ID']
      @data['ID'], @data['TYPE'] = fetch('ID').chomp('.').split('; ')
    end
    @data['ID']
  end

  # Returns
  def division
    unless @data['TYPE']
      name
    end
    @data['TYPE']
  end


  # AC  Accession number                   (1 per entry)
  #
  #  AC   PSnnnnn;
  #
  # Returns
  def ac
    unless @data['AC']
      @data['AC'] = fetch('AC').chomp(';')
    end
    @data['AC']
  end

  alias entry_id ac


  # DT  Date                               (1 per entry)
  #
  #  DT   MMM-YYYY (CREATED); MMM-YYYY (DATA UPDATE); MMM-YYYY (INFO UPDATE).
  #
  # Returns
  def dt
    field_fetch('DT')
  end

  alias date dt


  # DE  Short description                  (1 per entry)
  #
  #  DE   Description.
  #
  # Returns
  def de
    field_fetch('DE')
  end

  alias definition de


  # PA  Pattern                            (>=0 per entry)
  #
  #  see - pa2re method
  #
  # Returns
  def pa
    field_fetch('PA')
    @data['PA'] = fetch('PA') unless @data['PA']
    @data['PA'].gsub!(/\s+/, '') if @data['PA']
    @data['PA']
  end

  alias pattern pa


  # MA  Matrix/profile                     (>=0 per entry)
  #
  #  see - ma2re method
  #
  # Returns
  def ma
    field_fetch('MA')
  end

  alias profile ma


  # RU  Rule                               (>=0 per entry)
  #
  #  RU   Rule_Description.
  #
  #  The rule is described in ordinary English and is free-format.
  #
  # Returns
  def ru
    field_fetch('RU')
  end

  alias rule ru


  # NR  Numerical results                  (>=0 per entry)
  #
  #   - SWISS-PROT scan statistics of true and false positives/negatives
  #
  # /RELEASE     SWISS-PROT release  number and  total  number  of  sequence
  #              entries in that release.
  # /TOTAL       Total number of hits in SWISS-PROT.
  # /POSITIVE    Number of  hits on proteins that are known to belong to the
  #              set in consideration.
  # /UNKNOWN     Number of  hits on  proteins that  could possibly belong to
  #              the set in consideration.
  # /FALSE_POS   Number of false hits (on unrelated proteins).
  # /FALSE_NEG   Number of known missed hits.
  # /PARTIAL     Number of  partial sequences  which belong  to the  set  in
  #              consideration, but  which  are  not  hit  by the pattern or
  #              profile because they are partial (fragment) sequences.
  #
  # Returns
  def nr
    unless @data['NR']
      hash = {}			# temporal hash
      fetch('NR').scan(%r{/(\S+)=([^;]+);}).each do |k, v|
        if v =~ /^(\d+)\((\d+)\)$/
          hits = $1.to_i		# the number of hits
          seqs = $2.to_i		# the number of sequences
          v = [hits, seqs]
        elsif v =~ /([\d\.]+),(\d+)/
          sprel = $1			# the number of SWISS-PROT release
          spseq = $2.to_i		# the number of SWISS-PROT sequences
          v = [sprel, spseq]
        else
          v = v.to_i
        end
        hash[k] = v
      end
      @data['NR'] = hash
    end
    @data['NR']
  end

  alias statistics nr

  # Returns
  def release
    statistics['RELEASE']
  end

  # Returns
  def swissprot_release_number
    release.first
  end

  # Returns
  def swissprot_release_sequences
    release.last
  end

  # Returns
  def total
    statistics['TOTAL']
  end

  # Returns
  def total_hits
    total.first
  end

  # Returns
  def total_sequences
    total.last
  end

  # Returns
  def positive
    statistics['POSITIVE']
  end

  # Returns
  def positive_hits
    positive.first
  end

  # Returns
  def positive_sequences
    positive.last
  end

  # Returns
  def unknown
    statistics['UNKNOWN']
  end

  # Returns
  def unknown_hits
    unknown.first
  end

  # Returns
  def unknown_sequences
    unknown.last
  end

  # Returns
  def false_pos
    statistics['FALSE_POS']
  end

  # Returns
  def false_positive_hits
    false_pos.first
  end

  # Returns
  def false_positive_sequences
    false_pos.last
  end

  # Returns
  def false_neg
    statistics['FALSE_NEG']
  end
  alias false_negative_hits false_neg

  # Returns
  def partial
    statistics['PARTIAL']
  end


  # CC  Comments                           (>=0 per entry)
  #
  #  CC   /QUALIFIER=data; /QUALIFIER=data; .......
  #
  # /TAXO-RANGE  Taxonomic range.
  # /MAX-REPEAT  Maximum known  number of  repetitions of  the pattern  in a
  #              single protein.
  # /SITE        Indication of an `interesting' site in the pattern.
  # /SKIP-FLAG   Indication of  an entry that can be, in some cases, ignored
  #              by a program (because it is too unspecific).
  #
  # Returns
  def cc
    unless @data['CC']
      hash = {}			# temporal hash
      fetch('CC').scan(%r{/(\S+)=([^;]+);}).each do |k, v|
        hash[k] = v
      end
      @data['CC'] = hash
    end
    @data['CC']
  end

  alias comment cc

  # Returns
  def taxon_range(expand = nil)
    range = comment['TAXO-RANGE']
    if range and expand
      expand = []
      range.scan(/./) do |x|
        case x
        when 'A'; expand.push('archaebacteria')
        when 'B'; expand.push('bacteriophages')
        when 'E'; expand.push('eukaryotes')
        when 'P'; expand.push('prokaryotes')
        when 'V'; expand.push('eukaryotic viruses')
        end
      end
      range = expand
    end
    return range
  end

  # Returns
  def max_repeat
    comment['MAX-REPEAT'].to_i
  end

  # Returns
  def site
    if comment['SITE']
      num, desc = comment['SITE'].split(',')
    end
    return [num.to_i, desc]
  end

  # Returns
  def skip_flag
    if comment['SKIP-FLAG'] == 'TRUE'
      return true
    end
  end


  # DR  Cross-references to SWISS-PROT     (>=0 per entry)
  #
  #  DR   AC_NB, ENTRY_NAME, C; AC_NB, ENTRY_NAME, C; AC_NB, ENTRY_NAME, C;
  #
  # - `AC_NB' is the SWISS-PROT primary accession number of the entry to
  #   which reference is being made.
  # - `ENTRY_NAME' is the SWISS-PROT entry name.
  # - `C' is a one character flag that can be one of the following:
  #
  # T For a true positive.
  # N For a false negative; a sequence which belongs to the set under
  #   consideration, but which has not been picked up by the pattern or
  #   profile.
  # P For a `potential' hit; a sequence that belongs to the set under
  #   consideration, but which was not picked up because the region(s) that
  #   are used as a 'fingerprint' (pattern or profile) is not yet available
  #   in the data bank (partial sequence).
  # ? For an unknown; a sequence which possibly could belong to the set under
  #   consideration.
  # F For a false positive; a sequence which does not belong to the set in
  #   consideration.
  #
  # Returns
  def dr
    unless @data['DR']
      hash = {}			# temporal hash
      if fetch('DR')
        fetch('DR').scan(/(\w+)\s*, (\w+)\s*, (.);/).each do |a, e, c|
          hash[a] = [e, c]	# SWISS-PROT : accession, entry, true/false
        end
      end
      @data['DR'] = hash
    end
    @data['DR']
  end

  alias sp_xref dr

  # Returns
  def list_xref(flag, by_name = nil)
    ary = []
    sp_xref.each do |sp_acc, value|
      if value[1] == flag
        if by_name
          sp_name = value[0]
          ary.push(sp_name)
        else
          ary.push(sp_acc)
        end
      end
    end
    return ary
  end

  # Returns
  def list_truepositive(by_name = nil)
    list_xref('T', by_name)
  end

  # Returns
  def list_falsenegative(by_name = nil)
    list_xref('F', by_name)
  end

  # Returns
  def list_falsepositive(by_name = nil)
    list_xref('P', by_name)
  end

  # Returns
  def list_potentialhit(by_name = nil)
    list_xref('P', by_name)
  end

  # Returns
  def list_unknown(by_name = nil)
    list_xref('?', by_name)
  end


  # 3D  Cross-references to PDB            (>=0 per entry)
  #
  #  3D   name; [name2;...]
  #
  # Returns
  def pdb_xref
    unless @data['3D']
      @data['3D'] = fetch('3D').split(/; */)
    end
    @data['3D']
  end


  # DO  Pointer to the documentation file  (1 per entry)
  #
  #  DO   PDOCnnnnn;
  #
  # Returns
  def pdoc_xref
    @data['DO'] = fetch('DO').chomp(';')
  end


  ### prosite pattern to regular expression
  #
  # prosite/prosuser.txt:
  #
  # The PA (PAttern) lines contains the definition of a PROSITE pattern. The
  # patterns are described using the following conventions:
  #
  # 0) The standard IUPAC one-letter codes for the amino acids are used.
  # 0) Ambiguities are indicated by listing the acceptable amino acids for a
  #   given position, between square parentheses `[ ]'. For example: [ALT]
  #   stands for Ala or Leu or Thr.
  # 1) A period ends the pattern.
  # 2) When a pattern is restricted to either the N- or C-terminal of a
  #   sequence, that pattern either starts with a `<' symbol or respectively
  #   ends with a `>' symbol.
  # 3) Ambiguities are also indicated by listing between a pair of curly
  #   brackets `{ }' the amino acids that are not accepted at a given
  #   position. For example: {AM} stands for any amino acid except Ala and
  #   Met.
  # 4) Repetition of an element of the pattern can be indicated by following
  #   that element with a numerical value or a numerical range between
  #   parenthesis. Examples: x(3) corresponds to x-x-x, x(2,4) corresponds to
  #   x-x or x-x-x or x-x-x-x.
  # 5) The symbol `x' is used for a position where any amino acid is accepted.
  # 6) Each element in a pattern is separated from its neighbor by a `-'.
  #
  # Examples:
  #
  # PA  [AC]-x-V-x(4)-{ED}.
  #
  # This pattern is translated as: [Ala or Cys]-any-Val-any-any-any-any-{any
  # but Glu or Asp}
  #
  # PA  <A-x-[ST](2)-x(0,1)-V.
  #
  # This pattern, which must be in the N-terminal of the sequence (`<'), is
  # translated as: Ala-any-[Ser or Thr]-[Ser or Thr]-(any or none)-Val
  #
  def self.pa2re(pattern)
    pattern.gsub!(/\s/, '')	# remove white spaces
    pattern.sub!(/\.$/, '')	# (1) remove trailing '.'
    pattern.sub!(/^</, '^')	# (2) restricted to the N-terminal : `<'
    pattern.sub!(/>$/, '$')	# (2) restricted to the C-terminal : `>'
    pattern.gsub!(/\{(\w+)\}/) { |m|
      '[^' + $1 + ']'		# (3) not accepted at a given position : '{}'
    }
    pattern.gsub!(/\(([\d,]+)\)/) { |m|
      '{' + $1 + '}'		# (4) repetition of an element : (n), (n,m)
    }
    pattern.tr!('x', '.')	# (5) any amino acid is accepted : 'x'
    pattern.tr!('-', '')	# (6) each element is separated by a '-'
    Regexp.new(pattern, Regexp::IGNORECASE)
  end

  def pa2re(pattern)
    self.class.pa2re(pattern)
  end

  def re
    self.class.pa2re(self.pa)
  end


  ### prosite profile to regular expression
  #
  # prosite/profile.txt:
  #
  # Returns
  def ma2re(matrix)
    raise NotImplementedError
  end

end # PROSITE

end # Bio


if __FILE__ == $0

  begin
    require 'pp'
    alias p pp
  rescue LoadError
  end

  ps = Bio::PROSITE.new(ARGF.read)

  list = %w(
    name
    division
    ac
    entry_id
    dt
    date
    de
    definition
    pa
    pattern
    ma
    profile
    ru
    rule
    nr
    statistics
    release
    swissprot_release_number
    swissprot_release_sequences
    total
    total_hits
    total_sequences
    positive
    positive_hits
    positive_sequences
    unknown
    unknown_hits
    unknown_sequences
    false_pos
    false_positive_hits
    false_positive_sequences
    false_neg
    false_negative_hits
    partial
    cc
    comment
    max_repeat
    site
    skip_flag
    dr
    sp_xref
    pdb_xref
    pdoc_xref
  )

  list.each do |method|
    puts ">>> #{method}"
    p ps.send(method)
  end

  puts ">>> taxon_range"
  p ps.taxon_range
  puts ">>> taxon_range(expand)"
  p ps.taxon_range(true)

  puts ">>> list_truepositive"
  p ps.list_truepositive
  puts ">>> list_truepositive(by_name)"
  p ps.list_truepositive(true)

  puts ">>> list_falsenegative"
  p ps.list_falsenegative
  puts ">>> list_falsenegative(by_name)"
  p ps.list_falsenegative(true)

  puts ">>> list_falsepositive"
  p ps.list_falsepositive
  puts ">>> list_falsepositive(by_name)"
  p ps.list_falsepositive(true)

  puts ">>> list_potentialhit"
  p ps.list_potentialhit
  puts ">>> list_potentialhit(by_name)"
  p ps.list_potentialhit(true)

  puts ">>> list_unknown"
  p ps.list_unknown
  puts ">>> list_unknown(by_name)"
  p ps.list_unknown(true)

end
