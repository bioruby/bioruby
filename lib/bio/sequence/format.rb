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
# $Id: format.rb,v 1.4.2.5 2008/02/20 13:54:19 aerts Exp $
#


module Bio

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
  private

  def format_features(prefix, indent, width)
    result = ''
    @features.each do |feature|
      result << prefix + sprintf("%-16s", feature.feature)

      position = feature.position
      #position = feature.locations.to_s

      head = ''
      (position).wrap(width).each_line do |line|
        result << head << line
        head = indent
      end

      result << "\n"
      result << format_qualifiers(feature.qualifiers, indent, width)
      result << "\n"
    end
    return result
  end

  def format_qualifiers(qualifiers, indent, width)
    qualifiers.collect do |qualifier|
      q = qualifier.qualifier
      v = qualifier.value.to_s

      if v == true
        lines =('/' + q).wrap(width)
      elsif q == 'translation'
        lines = ('/' + q + '="' + v + '"').fold(width)
      else
        if ( v[/\D/] or q == 'chromosome' )
          #v.delete!("\x00-\x1f\x7f-\xff")
          v.gsub!(/"/, '""')
          v = '"' + v + '"'
        end
        lines = ('/' + q + '=' + v).wrap(width)
      end

      lines.gsub!(/^/, indent)
      lines
    end.join("\n")
  end


end # Format

end # Sequence

end # Bio

