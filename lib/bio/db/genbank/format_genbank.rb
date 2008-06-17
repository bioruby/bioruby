#
# = bio/db/genbank/format_genbank.rb - GenBank format generater
#
# Copyright::  Copyright (C) 2008 Naohisa Goto <ng@bioruby.org>
# License::    The Ruby License
#
# $Id: format_genbank.rb,v 1.1.2.5 2008/06/17 15:59:24 ngoto Exp $
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

    # formats comments lines as GenBank
    def comments_format_genbank(cmnts)
      return '' if !cmnts or cmnts.empty?
      cmnts = [ cmnts ] unless cmnts.kind_of?(Array)
      a = []
      cmnts.each do |str|
        a.push "COMMENT     #{ genbank_wrap(str) }\n"
      end
      a.join('')
    end

    # formats sequence lines as GenBank
    def seq_format_genbank(str)
      i = 1
      result = str.gsub(/.{1,60}/) do |s|
        s = s.gsub(/.{1,10}/, ' \0')
        y = sprintf("%9d%s\n", i, s)
        i += 60
        y
      end
      result
    end

    # formats date
    def date_format_genbank
      date_modified || date_created || null_date
    end

    # moleculue type
    def mol_type_genbank
      if /(DNA|(t|r|m|u|sn|sno)?RNA)/i =~ molecule_type.to_s then
        $1.sub(/[DR]NA/) { |x| x.upcase }
      else
        'NA'
      end
    end

    # NCBI GI number
    def ncbi_gi_number
      ids = other_seqids
      if ids and r = ids.find { |x| x.database == 'GI' } then
        r.id
      else
        nil
      end
    end

    # strandedness
    def strandedness_genbank
      return nil unless strandedness
      case strandedness
      when 'single'; 'ss-'; 
      when 'double'; 'ds-'; 
      when 'mixed';  'ms-'; 
      else; nil
      end
    end

    # Erb template of GenBank format for Bio::Sequence
    erb_template <<'__END_OF_TEMPLATE__'
LOCUS       <%= sprintf("%-16s", entry_id) %> <%= sprintf("%11d", length) %> bp <%= sprintf("%3s", strandedness_genbank) %><%= sprintf("%-6s", mol_type_genbank) %>  <%= sprintf("%-8s", topology) %><%= sprintf("%4s", division) %> <%= date_format_genbank %>
DEFINITION  <%= genbank_wrap_dot(definition.to_s) %>
ACCESSION   <%= genbank_wrap(([ primary_accession ] + (secondary_accessions or [])).join(" ")) %>
VERSION     <%= primary_accession %>.<%= sequence_version %><% if gi = ncbi_gi_number then %>  GI:<%= gi %><% end %>
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
%><%= comments_format_genbank(comments)
%>FEATURES             Location/Qualifiers
<%= format_features_genbank(features || [])
 %>ORIGIN
<%= seq_format_genbank(seq)
 %>//
__END_OF_TEMPLATE__

  end #class Genbank
end #module Bio::Sequence::Format::NucFormatter

