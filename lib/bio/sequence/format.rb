#
# = bio/sequence/format.rb - various output format of the biological sequence
#
# Copyright::   Copyright (C) 2006
#               Toshiaki Katayama <k@bioruby.org>,
#               Naohisa Goto <ng@bioruby.org>
# License::     Ruby's
#
# = TODO
#
# porting from N. Goto's feature-output.rb on BioRuby list.
#
# $Id: format.rb,v 1.2 2006/02/06 14:20:35 k Exp $
#


module Bio

  autoload :Sequence, 'bio/sequence'

class Sequence

module Format

  # Output the FASTA format string of the sequence.  The 1st argument is
  # used in the comment line.  If the 2nd argument (integer) is given,
  # the output sequence will be folded.
  def format_fasta(header = nil, width = nil)
    header ||= "#{@entry_id} #{@definition}"

    ">#{header}\n" +
    if width
      @seq.to_s.gsub(Regexp.new(".{1,#{width}}"), "\\0\n")
    else
      @seq.to_s + "\n"
    end
  end

  def format_gff
    raise NotImplementedError
  end

  def format_genbank
    prefix = ' ' * 5
    indent = prefix + ' ' * 16
    fwidth = 79 - indent.length

    format_features(prefix, indent, fwidth)
  end

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

