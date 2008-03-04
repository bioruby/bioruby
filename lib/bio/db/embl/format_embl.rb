#
# = bio/db/embl/format_embl.rb - EMBL format generater
#
# Copyright::  Copyright (C) 2008 Jan Aerts <jandot@bioruby.org>
# License::    The Ruby License
#
# $Id: format_embl.rb,v 1.1.2.1 2008/03/04 11:16:57 ngoto Exp $
#

require 'bio/sequence/format'

module Bio::Sequence::Format::NucFormatter

  # INTERNAL USE ONLY, YOU SHOULD NOT USE THIS CLASS.
  # Embl format output class for Bio::Sequence.
  class Embl < Bio::Sequence::Format::FormatterBase

    # helper methods
    include Bio::Sequence::Format::INSDFeatureHelper
    
    private

    def embl_wrap(prefix, str)
      wrap(str.to_s, 80, prefix)
    end

    def seq_format_embl(seq)
      output_lines = Array.new
      counter = 0
      remainder = seq.window_search(60,60) do |subseq|
        counter += 60
        subseq.gsub!(/(.{10})/, '\1 ')
        output_lines.push(' '*5 + subseq + counter.to_s.rjust(9))
      end
      counter += remainder.length
      remainder = (remainder.to_s + ' '*(60-remainder.length))
      remainder.gsub!(/(.{10})/, '\1 ')
      output_lines.push(' '*5 + remainder + counter.to_s.rjust(9))
      return output_lines.join("\n")
    end

    # Erb template of EMBL format for Bio::Sequence
    erb_template <<'__END_OF_TEMPLATE__'
ID   <%= entry_id %>; SV <%= sequence_version %>; <%= topology %>; <%= molecule_type %>; <%= data_class %>; <%= division %>; <%= seq.length %> BP.
XX
<%= embl_wrap('AC   ', accessions.reject{|a| a.nil?}.join('; ') + ';') %>
XX
DT   <%= date_created %>
DT   <%= date_modified %>
XX
<%= embl_wrap('DE   ', definition) %>
XX
<%= embl_wrap('KW   ', keywords.join('; ') + '.') %>
XX
OS   <%= species %>
<%= embl_wrap('OC   ', classification.join('; ') + '.') %>
XX   
<%= references.collect{|ref| ref.format('embl')}.join("\n") %>
XX
FH   Key             Location/Qualifiers
FH
<%= format_features_embl(features) %>XX
SQ   Sequence <%= seq.length %> BP; <%= seq.composition.collect{|k,v| "#{v} #{k.upcase}"}.join('; ') + '; ' + (seq.gsub(/[ACTGactg]/, '').length.to_s ) + ' other;' %>
<%= seq_format_embl(seq) %>
//
__END_OF_TEMPLATE__

  end #class Embl

end #module Bio::Sequence::Format::NucFormatter

