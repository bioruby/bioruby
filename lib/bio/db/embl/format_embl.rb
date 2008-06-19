#
# = bio/db/embl/format_embl.rb - EMBL format generater
#
# Copyright::  Copyright (C) 2008
#              Jan Aerts <jandot@bioruby.org>,
#              Naohisa Goto <ng@bioruby.org>
# License::    The Ruby License
#
# $Id: format_embl.rb,v 1.1.2.7 2008/06/19 12:45:15 ngoto Exp $
#

require 'bio/sequence/format'

module Bio::Sequence::Format::NucFormatter

  # INTERNAL USE ONLY, YOU SHOULD NOT USE THIS CLASS.
  # Embl format output class for Bio::Sequence.
  class Embl < Bio::Sequence::Format::FormatterBase

    # helper methods
    include Bio::Sequence::Format::INSDFeatureHelper
    
    private

    # wrapping with EMBL style
    def embl_wrap(prefix, str)
      wrap(str.to_s, 80, prefix)
    end

    # Given words (an Array of String) are wrapping with EMBL style.
    # Each word is never splitted inside the word.
    def embl_wrap_words(prefix, array)
      width = 80
      result = []
      str = nil
      array.each do |x|
        if str then
          if str.length + 1 + x.length > width then
            str = nil
          else
            str.concat ' '
            str.concat x
          end
        end
        unless str then
          str = prefix + x
          result.push str
        end
      end
      result.join("\n")
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
      unless ref.authors.empty? then
        auth = ref.authors.collect do |x|
          y = x.to_s.strip.split(/\, *([^\,]+)\z/)
          y[1].gsub!(/\. +/, '.') if y[1]
          y.join(' ')
        end
        lastauth = auth.pop
        auth.each { |x| x.concat ',' }
        auth.push(lastauth.to_s + ';')
        lines << embl_wrap_words('RA   ', auth)
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
      counter = 0
      result = seq.gsub(/.{1,60}/) do |x|
        counter += x.length
        x = x.gsub(/.{10}/, '\0 ')
        sprintf("     %-66s%9d\n", x, counter)
      end
      result.chomp!
      result
    end

    def seq_composition(seq)
      { :a => seq.count('aA'),
        :c => seq.count('cC'),
        :g => seq.count('gG'),
        :t => seq.count('tTuU'),
        :other => seq.count('^aAcCgGtTuU')
      }
    end

    # moleculue type
    def mol_type_embl
      if mt = molecule_type then
        mt
      elsif f = (features or []).find { |f| f.feature == 'source' } and
          q = f.qualifiers.find { |q| q.qualifier == 'mol_type' } then
        q.value
      else
        'NA'
      end
    end

    # CC line. Comments.
    def comments_format_embl(cmnts)
      return '' if !cmnts or cmnts.empty?
      cmnts = [ cmnts ] unless cmnts.kind_of?(Array)
      a = []
      cmnts.each do |str|
        a.push embl_wrap('CC   ', str)
      end
      unless a.empty? then
        a.push "XX   "
        a.push '' # dummy to put "\n" at the end of the string
      end
      a.join("\n")
    end


    # Erb template of EMBL format for Bio::Sequence
    erb_template <<'__END_OF_TEMPLATE__'
ID   <%= primary_accession || entry_id %>; SV <%= sequence_version %>; <%= topology %>; <%= mol_type_embl %>; <%= data_class %>; <%= division %>; <%= seq.length %> BP.
XX   
<%= embl_wrap('AC   ', accessions.reject{|a| a.nil?}.join('; ') + ';') %>
XX   
DT   <%= format_date(date_created || null_date) %> (Rel. <%= release_created || 0 %>, Created)
DT   <%= format_date(date_modified || null_date) %> (Rel. <%= release_modified || 0 %>, Last updated, Version <%= entry_version || 0 %>)
XX   
<%= embl_wrap('DE   ', definition) %>
XX   
<%= embl_wrap('KW   ', (keywords || []).join('; ') + '.') %>
XX   
OS   <%= species %>
<%= embl_wrap('OC   ', (classification || []).join('; ') + '.') %>
XX   
<% hash = {}; (references || []).each do |ref| %><%= reference_format_embl(ref, hash) %>
<% end %><% (dblinks || []).each do |r|
%>DR   <%= r.database %>; <%= r.id %><% unless r.secondary_ids.empty? %>; <%= r.secondary_ids[0] %><% end %>.
<% end %><% if dblinks and !dblinks.empty? then
 %>XX   
<% end %><%= comments_format_embl(comments)
%>FH   Key             Location/Qualifiers
FH   
<%= format_features_embl(features || []) %>XX   
SQ   Sequence <%= seq.length %> BP; <% c = seq_composition(seq) %><%= c[:a] %> A; <%= c[:c] %> C; <%= c[:g] %> G; <%= c[:t] %> T; <%= c[:other] %> other;
<%= seq_format_embl(seq) %>
//
__END_OF_TEMPLATE__

  end #class Embl

end #module Bio::Sequence::Format::NucFormatter

