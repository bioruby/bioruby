#
# = bio/sequence/format.rb - various output format of the biological sequence
#
# Copyright::   Copyright (C) 2006
#               Toshiaki Katayama <k@bioruby.org>,
#               Naohisa Goto <ng@bioruby.org>,
#               Ryan Raaum <ryan@raaum.org>
# License::     The Ruby License
#
# = TODO
#
# porting from N. Goto's feature-output.rb on BioRuby list.
#
# $Id: format.rb,v 1.4 2007/04/05 23:35:41 trevor Exp $
#


module Bio

  autoload :Sequence, 'bio/sequence'

class Sequence

# = DESCRIPTION
# A Mixin[http://www.rubycentral.com/book/tut_modules.html]
# of methods used by Bio::Sequence#output to output sequences in 
# common bioinformatic formats.  These are not called in isolation.
#
# = USAGE
#   # Given a Bio::Sequence object,
#   puts s.output(:fasta)
#   puts s.output(:genbank)
#   puts s.output(:embl)
module Format

  # INTERNAL USE ONLY, YOU SHOULD NOT CALL THIS METHOD. (And in any
  # case, it would be difficult to successfully call this method outside
  # its expected context).
  #
  # Output the FASTA format string of the sequence.  
  #
  # UNFORTUNATLY, the current implementation of Bio::Sequence is incapable of 
  # using either the header or width arguments.  So something needs to be
  # changed...
  #
  # Currently, this method is used in Bio::Sequence#output like so,
  #
  #   s = Bio::Sequence.new('atgc')
  #   puts s.output(:fasta)                   #=> "> \natgc\n"
  # ---
  # *Arguments*:
  # * (optional) _header_: String (default nil)
  # * (optional) _width_: Fixnum (default nil)
  # *Returns*:: String object
  def format_fasta(header = nil, width = nil)
    header ||= "#{@entry_id} #{@definition}"

    ">#{header}\n" +
    if width
      @seq.to_s.gsub(Regexp.new(".{1,#{width}}"), "\\0\n")
    else
      @seq.to_s + "\n"
    end
  end

  # Not yet implemented :)
  # Remove the nodoc command after implementation!
  # ---
  # *Returns*:: String object
  def format_gff #:nodoc:
    raise NotImplementedError
  end

  # INTERNAL USE ONLY, YOU SHOULD NOT CALL THIS METHOD. (And in any
  # case, it would be difficult to successfully call this method outside
  # its expected context).
  #
  # Output the Genbank format string of the sequence.  
  # Used in Bio::Sequence#output.
  # ---
  # *Returns*:: String object
  def format_genbank
    prefix = ' ' * 5
    indent = prefix + ' ' * 16
    fwidth = 79 - indent.length

    format_features(prefix, indent, fwidth)
  end

  # INTERNAL USE ONLY, YOU SHOULD NOT CALL THIS METHOD. (And in any
  # case, it would be difficult to successfully call this method outside
  # its expected context).
  #
  # Output the EMBL format string of the sequence.  
  # Used in Bio::Sequence#output.
  # ---
  # *Returns*:: String object
  def format_embl
    prefix = 'FT   '
    indent = prefix + ' ' * 16
    fwidth = 80 - indent.length

    format_features(prefix, indent, fwidth)
  end


  private

  def format_features(prefix, indent, width)
    result = ''
    @features.each do |feature|
      result << prefix + sprintf("%-16s", feature.feature)

      position = feature.position
      #position = feature.locations.to_s

      head = ''
      wrap(position, width).each_line do |line|
        result << head << line
        head = indent
      end

      result << format_qualifiers(feature.qualifiers, width)
    end
    return result
  end

  def format_qualifiers(qualifiers, indent, width)
    qualifiers.each do |qualifier|
      q = qualifier.qualifier
      v = qualifier.value.to_s

      if v == true
        lines = wrap('/' + q, width)
      elsif q == 'translation'
        lines = fold('/' + q + '=' + val, width)
      else
        if v[/\D/]
          #v.delete!("\x00-\x1f\x7f-\xff")
          v.gsub!(/"/, '""')
          v = '"' + v + '"'
        end
        lines = wrap('/' + q + '=' + val, width)
      end

      return lines.gsub(/^/, indent)
    end
  end

  def fold(str, width)
    str.gsub(Regexp.new("(.{1,#{width}})"), "\\1\n")
  end

  def wrap(str, width)
    result = []
    left = str.dup
    while left and left.length > width
      line = nil
      width.downto(1) do |i|
        if left[i..i] == ' ' or /[,;]/ =~ left[(i-1)..(i-1)]  then
          line = left[0..(i-1)].sub(/ +\z/, '')
          left = left[i..-1].sub(/\A +/, '')
          break
        end
      end
      if line.nil? then
        line = left[0..(width-1)]
        left = left[width..-1]
      end
      result << line
    end
    result << left if left
    return result.join("\n")
  end

end # Format

end # Sequence

end # Bio

