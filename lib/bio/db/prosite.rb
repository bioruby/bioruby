#
# bio/db/prosite.rb - PROSITE database class
#
#   Copyright (C) 2001 KATAYAMA Toshiaki <k@bioruby.org>
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

class PROSITE

  DELIMITER = "\n//\n"
  TAGSIZE = 5

  def initialize(entry)
    @orig = {}					# Hash of the original entry
    @data = {}					# Hash of the parsed entry

    tag = ''					# temporal key
    @orig[tag] = ''

    entry.each_line do |line|
      next if line =~ /^$/

      oldtag = tag
      tag = tag_get(line)
      if tag != oldtag
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


  ### prosite pattern to regular expression
  #
  # prosite/prosuser.txt:
  #
  #  The PA  (PAttern) lines  contains the definition of a PROSITE pattern. The
  #  patterns are described using the following conventions:
  #
  # (0) The standard IUPAC one-letter codes for the amino acids are used.
  # (0) Ambiguities are  indicated by  listing the acceptable amino acids for a
  #     given position,  between square  parentheses `[  ]'. For example: [ALT]
  #     stands for Ala or Leu or Thr.
  # (1) A period ends the pattern.
  # (2) When a  pattern is  restricted to  either the  N- or  C-terminal  of  a
  #     sequence, that  pattern either starts with a `<' symbol or respectively
  #     ends with a `>' symbol.
  # (3) Ambiguities are  also indicated  by listing  between a  pair  of  curly
  #     brackets `{  }' the  amino acids  that are  not  accepted  at  a  given
  #     position. For  example: {AM}  stands for  any amino acid except Ala and
  #     Met.
  # (4) Repetition of  an element  of the pattern can be indicated by following
  #     that element  with a  numerical value  or  a  numerical  range  between
  #     parenthesis. Examples: x(3) corresponds to x-x-x, x(2,4) corresponds to
  #     x-x or x-x-x or x-x-x-x.
  # (5) The symbol `x' is used for a position where any amino acid is accepted.
  # (6) Each element in a pattern is separated from its neighbor by a `-'.
  #
  #  Examples:
  #
  #  PA   [AC]-x-V-x(4)-{ED}.
  #
  #  This pattern  is translated  as: [Ala or Cys]-any-Val-any-any-any-any-{any
  #  but Glu or Asp}
  #
  #  PA   <A-x-[ST](2)-x(0,1)-V.
  #
  #  This pattern,  which must  be in  the N-terminal of the sequence (`<'), is
  #  translated as: Ala-any-[Ser or Thr]-[Ser or Thr]-(any or none)-Val
  #
  def pa2re(pattern)
    pattern.gsub!(/\s+/, '')	# remove white spaces
    pattern.sub!(/\.$/, '')	# (1) remove tailing '.'
    pattern.sub!(/^</, '^')	# (2) restricted to the N-terminal : `<'
    pattern.sub!(/>$/, '$')	# (2) restricted to the C-terminal : `>'
    pattern.gsub!(/\{(\w+)\}/) { |m|
      '[^' + $1 + ']'		# (3) not accepted at a given position : '{}'
    }
    pattern.gsub!(/\((\w+)\)/) { |m|
      '{' + $1 + '}'		# (4) repetition of an element : (n), (n,m)
    }
    pattern.tr!('x', '.')	# (5) any amino acid is accepted : 'x'
    pattern.tr!('-', '')	# (6) each element is separated by a '-'
    Regexp.new(pattern)
  end


  ### prosite profile to regular expression
  #
  # prosite/profile.txt:
  #
  def ma2re(matrix)
  end


  # ID  Identification                     (Begins each entry; 1 per entry)
  def id
    @data['ID'] = fetch('ID') unless @data['ID']
    @data['ID']
  end

  # AC  Accession number                   (1 per entry)
  def ac
    @data['AC'] = fetch('AC') unless @data['AC']
    @data['AC'].gsub!(/;$/, '') if @data['AC']
    @data['AC']
  end

  # DT  Date                               (1 per entry)
  def dt
    @data['DT'] = fetch('DT') unless @data['DT']
    @data['DT']
  end

  # DE  Short description                  (1 per entry)
  def de
    @data['DE'] = fetch('DE') unless @data['DE']
    @data['DE']
  end

  # PA  Pattern                            (>=0 per entry)
  def pa
    @data['PA'] = fetch('PA') unless @data['PA']
    @data['PA'].gsub!(/\s+/, '') if @data['PA']
    @data['PA']
  end

  # MA  Matrix/profile                     (>=0 per entry)
  def ma
    @data['MA'] = fetch('MA') unless @data['MA']
    @data['MA']
  end

  # RU  Rule                               (>=0 per entry)
  def ru
    @data['RU'] = fetch('RU') unless @data['RU']
    @data['RU']
  end

  # NR  Numerical results                  (>=0 per entry)
  #   - statistics of true and false positives/negatives
  def nr(key = nil)
    unless @data['NR']
      hash = {}			# temporal hash
      if fetch('NR')
	fetch('NR').scan(%r{/(\S+)=([^;]+);}).each do |k, v|
	  if v =~ /^(\d+)\((\d+)\)$/
	    v = [$1, $2]
	  end
	  hash[k] = v
	end
      end
      @data['NR'] = hash
    end

    if key
      @data['NR'][key]
    else
      if block_given?
	@data['NR'].each do |k, v|
	  yield(k, v)
	end
      else
	@data['NR']
      end
    end
  end

  # CC  Comments                           (>=0 per entry)
  def cc(key = nil, expand_range = false)
    unless @data['CC']
      hash = {}			# temporal hash
      if fetch('CC')
	fetch('CC').scan(%r{/(\S+)=([^;]+);}).each do |k, v|
	  if k =~ /TAXO-RANGE/ and expand_range
	    v.gsub!(/\?/, '')
	    v.each_byte do |x|
	      case x.chr
	      when 'A'; v.sub!('A', 'archaebacteria, ') ;
	      when 'B'; v.sub!('B', 'bacteriophages, ') ;
	      when 'E'; v.sub!('E', 'eukaryotes, ') ;
	      when 'P'; v.sub!('P', 'prokaryotes, ') ;
	      when 'V'; v.sub!('V', 'eukaryotic viruses, ') ;
	      end
	    end
	    v.sub!(/, $/, '')
	  end
	  hash[k] = v
	end
      end
      @data['CC'] = hash
    end

    if key
      @data['CC'][key]
    else
      if block_given?
	@data['CC'].each do |k, v|
	  yield(k, v)
	end
      else
	@data['CC']
      end
    end
  end

  # DR  Cross-references to SWISS-PROT     (>=0 per entry)
  def dr(key = nil)
    unless @data['DR']
      hash = {}			# temporal hash
      if fetch('DR')
	fetch('DR').scan(%r{(\w+)\s*, (\w+)\s+, (.);}).each do |a, e, c|
	  hash[a] = [e, c]	# SWISS-PROT : Accession, Entry, True/False
	end
      end
      @data['DR'] = hash
    end

    if key
      @data['DR'][key]
    else
      if block_given?
	@data['DR'].each do |k, v|
	  yield(k, v)
	end
      else
	@data['DR']
      end
    end
  end

  # 3D  Cross-references to PDB            (>=0 per entry)
  def pdb
    unless @data['3D']
      array = []		# temporal array
      if fetch('3D')
	array = fetch('3D').split(/; /)
      end
      @data['3D'] = array
    end

    @data['3D']
  end

  # DO  Pointer to the documentation file  (1 per entry)
  def pdoc
    @data['DO'] = fetch('DO') unless @data['DO']
    @data['DO'].gsub!(/;$/, '') if @data['DO']
    @data['DO']
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

end

