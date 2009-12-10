#
# = bio/db/kegg/common.rb - Common methods for KEGG database classes
#
# Copyright::  Copyright (C) 2003-2007 Toshiaki Katayama <k@bioruby.org>
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
            sign, entry_id, name = line.split(/\s+/, 3)
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
          orthologs_as_strings.each do |ko|
            entry = ko.scan(/K[0-9]{5}/)[0]
            sign, entry_id, definition = ko.split(/\s+/, 3)
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

  end #module Common
end #class KEGG
end #module Bio

