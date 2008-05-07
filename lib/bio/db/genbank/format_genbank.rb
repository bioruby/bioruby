#
# = bio/db/genbank/format_genbank.rb - GenBank format generater
#
# Copyright::  Copyright (C) 2008 Naohisa Goto <ng@bioruby.org>
# License::    The Ruby License
#
# $Id: format_genbank.rb,v 1.1.2.3 2008/05/07 12:28:56 ngoto Exp $
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

    # Given words (an Array of String) are wrapping with EMBL style.
    # Each word is never splitted inside the word.
    def genbank_wrap_words(array)
      width = 67
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
          str = "#{x}"
          result.push str
        end
      end
      result.join("\n" + " " * 12)
    end

    # formats references
    def reference_format_genbank(ref, num)
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

      alist = ref.authors.collect do |x|
        y = x.to_s.strip.split(/\, *([^\,]+)\z/)
        y[1].gsub!(/\. +/, '.') if y[1]
        y.join(',')
      end
      lastauthor = alist.pop
      last2author = alist.pop
      alist.each { |x| x.concat ',' }
      alist.push last2author if last2author
      alist.push "and" unless alist.empty?
      alist.push lastauthor.to_s
      result = <<__END_OF_REFERENCE__
REFERENCE   #{ genbank_wrap(sprintf('%-2d%s', num, pos))}
  AUTHORS   #{ genbank_wrap_words(alist) }
  TITLE     #{ genbank_wrap(ref.title.to_s) }
  JOURNAL   #{ genbank_wrap(journal) }
__END_OF_REFERENCE__
      unless ref.pubmed.to_s.empty? then
        result.concat "   PUBMED   #{ genbank_wrap(ref.pubmed) }\n"
      end
      if ref.comments and !(ref.comments.empty?) then
        ref.comments.each do |c|
          result.concat "  REMARK    #{ genbank_wrap(c) }\n"
        end
      end
      result
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
%><%= reference_format_genbank(ref, n) %><%
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

