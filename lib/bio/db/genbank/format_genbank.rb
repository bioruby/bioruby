#
# = bio/db/genbank/format_genbank.rb - GenBank format generater
#
# Copyright::  Copyright (C) 2008 Naohisa Goto <ng@bioruby.org>
# License::    The Ruby License
#
# $Id: format_genbank.rb,v 1.1.2.2 2008/05/07 06:17:52 ngoto Exp $
#

require 'bio/sequence/format'

module Bio::Sequence::Format::NucFormatter

  # INTERNAL USE ONLY, YOU SHOULD NOT USE THIS CLASS.
  # GenBank format output class for Bio::Sequence.
  class Genbank < Bio::Sequence::Format::FormatterBase

    # helper methods
    include Bio::Sequence::Format::INSDFeatureHelper
    
    private

    # string wrapper for GenBank format
    def genbank_wrap(str)
      wrap(str.to_s, 67).gsub(/\n/, "\n" + " " * 12)
    end

    # string wrap with adding a dot at the end of the string
    def genbank_wrap_dot(str)
      str = str.to_s
      str = str + '.' unless /\.\z/ =~ str
      genbank_wrap(str)
    end

    # formats sequence lines as GenBank
    def each_genbank_seqline(str) #:yields: counter, seqline
      i = 1
      a = str.scan(/.{1,60}/) do |s|
        yield i, s.gsub(/(.{1,10})/, " \\1")
        i += 60
      end
    end

    # Erb template of GenBank format for Bio::Sequence
    erb_template <<'__END_OF_TEMPLATE__'
LOCUS       <%= sprintf("%-16s", entry_id) %> <%= sprintf("%11d", length) %> bp <%= sprintf("%3s", '') %><%= sprintf("%-6s", molecule_type) %>  <%= sprintf("%-8s", topology) %><%= sprintf("%4s", division) %> <%= sprintf("%-11s", date_modified) %>
DEFINITION  <%= genbank_wrap_dot(definition.to_s) %>
ACCESSION   <%= genbank_wrap(([ primary_accession ] + (secondary_accessions or [])).join(" ")) %>
VERSION     <%= primary_accession %>.<%= sequence_version %><% unless true or gi_number.to_s.empty? %>GI:<%= gi_number %><% end %>
KEYWORDS    <%= genbank_wrap_dot((keywords or []).join('; ')) %>
SOURCE      <%= genbank_wrap(species) %>
  ORGANISM  <%= genbank_wrap(species) %>
            <%= genbank_wrap_dot((classification or []).join('; ')) %>
<% 
    n = 0
    (references or []).each do |ref|
      n += 1
      pos = ref.sequence_position.to_s.gsub(/\s/, '')
      pos.gsub!(/(\d+)\-(\d+)/, "\\1 to \\2")
      pos.gsub!(/\s*\,\s*/, '; ')
      if pos.empty?
        pos = ''
      else
        pos = " (bases #{pos})"
      end
      volissue = "#{ref.volume.to_s}"
      volissue += " (#{ref.issue})" unless ref.issue.to_s.empty? 
      journal = "#{ref.journal.to_s}"
      journal += " #{volissue}" unless volissue.empty? 
      journal += ", #{ref.pages}" unless ref.pages.to_s.empty?
      journal += " (#{ref.year})" unless ref.year.to_s.empty?

      alist = ref.authors.collect { |x| x.gsub(/\, /, ',') }
      lastauthor = alist.pop
      authorsline = alist.join(', ')
      authorsline.concat(" and ") unless alist.empty?
      authorsline.concat lastauthor.to_s
      
%>REFERENCE   <%= genbank_wrap(sprintf('%-2d%s', n, pos)) %>
  AUTHORS   <%= genbank_wrap(authorsline) %>
  TITLE     <%= genbank_wrap(ref.title.to_s) %>
  JOURNAL   <%= genbank_wrap(journal) %>
<%   unless ref.pubmed.to_s.empty?
 %>  PUBMED    <%= ref.pubmed %>
<%   end
    end
%>FEATURES             Location/Qualifiers
<%= format_features_genbank(features || [])
 %>ORIGIN
<% each_genbank_seqline(seq) do |i, s|
 %><%= sprintf('%9d', i) %><%= s %>
<% end %>//
__END_OF_TEMPLATE__

  end #class Genbank
end #module Bio::Sequence::Format::NucFormatter

