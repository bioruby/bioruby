#
# = bio/db/embl/format_embl.rb - EMBL format generater
#
# Copyright::  Copyright (C) 2008 Jan Aerts <jandot@bioruby.org>
# License::    The Ruby License
#
# $Id: format_embl.rb,v 1.1.2.3 2008/04/23 18:52:18 ngoto Exp $
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

    # format reference
    # ref:: Bio::Reference object
    # hash:: (optional) a hash for RN (reference number) administration
    def reference_format_embl(ref, hash = nil)
      lines = Array.new
      if ref.embl_gb_record_number or hash then
        refno = ref.embl_gb_record_number.to_i
        hash ||= {}
        if refno <= 0 or hash[refno] then
          refno = hash.keys.sort[-1].to_i + 1
          hash[refno] = true
        end
        lines << embl_wrap("RN   ", "[#{refno}]")
      end
      if ref.comments then
        ref.comments.each do |cmnt|
          lines << embl_wrap("RC   ", cmnt)
        end
      end
      unless ref.sequence_position.to_s.empty? then
        lines << embl_wrap("RP   ",   "#{ref.sequence_position}")
      end
      unless ref.doi.to_s.empty? then
        lines << embl_wrap("RX   ",   "DOI; #{ref.doi}.")
      end
      unless ref.pubmed.to_s.empty? then
        lines << embl_wrap("RX   ",   "PUBMED; #{ref.pubmed}.")
      end
      unless ref.authors.empty?
        lines << embl_wrap('RA   ', ref.authors.join(', ') + ';')
      end
      lines << embl_wrap('RT   ',
                         (ref.title.to_s.empty? ? '' :
                          "\"#{ref.title}\"") + ';')
      unless ref.journal.to_s.empty? then
        volissue = "#{ref.volume.to_s}"
        volissue = "#{volissue}(#{ref.issue})" unless ref.issue.to_s.empty? 
        rl = "#{ref.journal}"
        rl += " #{volissue}" unless volissue.empty? 
        rl += ":#{ref.pages}" unless ref.pages.to_s.empty?
        rl += "(#{ref.year})" unless ref.year.to_s.empty?
        rl += '.'
        lines << embl_wrap('RL   ', rl)
      end
      lines << "XX"
      return lines.join("\n")
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
<% hash = {}; (references || []).each do |ref| %><%= reference_format_embl(ref, hash) %>
<% end %>FH   Key             Location/Qualifiers
FH   
<%= format_features_embl(features || []) %>XX   
SQ   Sequence <%= seq.length %> BP; <%= seq.composition.collect{|k,v| "#{v} #{k.upcase}"}.join('; ') + '; ' + (seq.gsub(/[ACTGactg]/, '').length.to_s ) + ' other;' %>
<%= seq_format_embl(seq) %>
//
__END_OF_TEMPLATE__

  end #class Embl

end #module Bio::Sequence::Format::NucFormatter

