#
# = bio/db/kegg/common.rb - Common methods for KEGG database classes
#
# Copyright::  Copyright (C) 2001-2007 Toshiaki Katayama <k@bioruby.org>
# Copyright::  Copyright (C) 2003 Masumi Itoh <m@bioruby.org>
# Copyright::  Copyright (C) 2009 Kozo Nishida <kozo-ni@is.naist.jp>
# License::    The Ruby License
#
#
#
# == Description
#
# Note that the modules in this file are intended to be Bio::KEGG::* 
# internal use only.
#
# This file contains modules that implement methods commonly used from
# KEGG database parser classes.
#

module Bio
class KEGG

  # Namespace for methods commonly used in the Bio::KEGG::* classes.
  module Common

    # The module provides references method.
    module References
      # REFERENCE -- Returns contents of the REFERENCE records as an Array of
      # Bio::Reference objects.
      def references
        unless @data['REFERENCE']
          ary = []
          toptag2array(get('REFERENCE')).each do |ref|
            hash = Hash.new
            subtag2array(ref).each do |field|
              case tag_get(field)
              when /REFERENCE/
                cmnt = tag_cut(field).chomp
                if /^\s*PMID\:(\d+)\s*/ =~ cmnt then
                  hash['pubmed'] = $1
                  cmnt = $'
                end
                if cmnt and !cmnt.empty? then
                  hash['comments'] ||= []
                  hash['comments'].push(cmnt)
                end
              when /AUTHORS/
                authors = truncate(tag_cut(field))
                authors = authors.split(/\, /)
                authors[-1] = authors[-1].split(/\s+and\s+/) if authors[-1]
                authors = authors.flatten.map { |a| a.sub(',', ', ') }
                hash['authors']	= authors
              when /TITLE/
                hash['title']	= truncate(tag_cut(field))
              when /JOURNAL/
                journal = truncate(tag_cut(field))
                case journal
                  # KEGG style
                when /(.*) (\d*(?:\([^\)]+\))?)\:(\d+\-\d+) \((\d+)\)$/
                  hash['journal'] = $1
                  hash['volume']  = $2
                  hash['pages']   = $3
                  hash['year']    = $4
                  # old KEGG style
                when /(.*) (\d+):(\d+\-\d+) \((\d+)\) \[UI:(\d+)\]$/
                  hash['journal'] = $1
                  hash['volume']  = $2
                  hash['pages']   = $3
                  hash['year']    = $4
                  hash['medline'] = $5
                  # Only journal name and year are available
                when /(.*) \((\d+)\)$/
                  hash['journal'] = $1
                  hash['year']    = $2
                else
                  hash['journal'] = journal
                end
              end
            end
            ary.push(Reference.new(hash))
          end
          @data['REFERENCE'] = ary #.extend(Bio::References::BackwardCompatibility)

        end
        @data['REFERENCE']
      end
    end #module References

    # The module providing dblinks_as_hash methods.
    #
    # Bio::KEGG::* internal use only.
    module DblinksAsHash

      # Returns a Hash of the DB name and an Array of entry IDs in
      # DBLINKS field.
      def dblinks_as_hash
        unless defined? @dblinks_as_hash
          hash = {}
          dblinks_as_strings.each do |line|
            db, ids = line.split(/\:\s*/, 2)
            list = ids.split(/\s+/)
            hash[db] = list
          end
          @dblinks_as_hash = hash
        end
        @dblinks_as_hash
      end
    end #module DblinksAsHash

    # The module providing pathways_as_hash method.
    #
    # Bio::KEGG::* internal use only.
    module PathwaysAsHash

      # Returns a Hash of the pathway ID and name in PATHWAY field.
      def pathways_as_hash
        unless defined? @pathways_as_hash then
          hash = {}
          pathways_as_strings.each do |line|
            line = line.sub(/\APATH\:\s+/, '')
            entry_id, name = line.split(/\s+/, 2)
            hash[entry_id] = name
          end
          @pathways_as_hash = hash
        end
        @pathways_as_hash
      end
    end #module PathwaysAsHash

    # This module provides orthologs_as_hash method.
    #
    # Bio::KEGG::* internal use only.
    module OrthologsAsHash

      # Returns a Hash of the orthology ID and definition in ORTHOLOGY field.
      def orthologs_as_hash
        unless defined? @orthologs_as_hash
          kos = {}
          orthologs_as_strings.each do |line|
            ko = line.sub(/\AKO\:\s+/, '')
            entry_id, definition = ko.split(/\s+/, 2)
            kos[entry_id] = definition
          end
          @orthologs_as_hash = kos
        end
        @orthologs_as_hash
      end
    end #module OrthologsAsHash

    # This module provides genes_as_hash method.
    #
    # Bio::KEGG::* internal use only.
    module GenesAsHash

      # Returns a Hash of the organism ID and an Array of entry IDs in
      # GENES field.
      def genes_as_hash
        unless defined? @genes_as_hash
          hash = {}
          genes_as_strings.each do |line|
            name, *list = line.split(/\s+/)
            org = name.downcase.sub(/:/, '')
            genes = list.map {|x| x.sub(/\(.*\)/, '')}
            #names = list.map {|x| x.scan(/.*\((.*)\)/)}
            hash[org] = genes
          end
          @genes_as_hash = hash
        end
        @genes_as_hash
      end
    end #module GenesAsHash

    # This module provides modules_as_hash method.
    #
    # Bio::KEGG::* internal use only.
    module ModulesAsHash
      # Returns MODULE field as a Hash.
      # Each key of the hash is KEGG MODULE ID,
      # and each value is the name of the Pathway Module.
      # ---
      # *Returns*:: Hash
      def modules_as_hash
        unless defined? @modules_s_as_hash then
          hash = {}
          modules_as_strings.each do |line|
            entry_id, name = line.split(/\s+/, 2)
            hash[entry_id] = name
          end
          @modules_as_hash = hash
        end
        @modules_as_hash
      end
    end #module ModulesAsHash

    # This module provides strings_as_hash private method.
    #
    # Bio::KEGG::* internal use only.
    module StringsAsHash
      # (Private) Creates a hash from lines.
      # Each line is consisted of two components, ID and description,
      # separated with spaces. IDs must be unique with each other.
      def strings_as_hash(lines)
        hash = {}
        lines.each do |line|
          entry_id, definition = line.split(/\s+/, 2)
          hash[entry_id] = definition
        end
        return hash
      end
      private :strings_as_hash
    end #module StringsAsHash

    # This module provides diseases_as_hash method.
    #
    # Bio::KEGG::* internal use only.
    module DiseasesAsHash 
      include StringsAsHash
      # Returns a Hash of the disease ID and its definition
      def diseases_as_hash
        unless (defined? @diseases_as_hash) && @diseases_as_hash
          @diseases_as_hash = strings_as_hash(diseases_as_strings)
        end
        @diseases_as_hash
      end
    end #module DiseasesAsHash

  end #module Common
end #class KEGG
end #module Bio

