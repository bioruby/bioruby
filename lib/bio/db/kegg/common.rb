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

    # The module providing dblinks_as_hash method.
    #
    # Bio::KEGG::* internal use only.
    module DblinksAsHash

      # Returns a Hash of the DB name and an Array of entry IDs in
      # DBLINKS field.
      def dblinks_as_hash
        hash = {}
        dblinks.each do |line|
          name, *list = line.split(/\s+/)
          db = name.sub(/\:\z/, '')
          hash[db] = list
        end
        return hash
      end
    end #module DblinksAsHash

    # The module providing pathways_as_hash method.
    #
    # Bio::KEGG::* internal use only.
    module PathwaysAsHash

      # Returns a Hash of the pathway ID and name in PATHWAY field.
      def pathways_as_hash
        hash = {}
        pathways.each do |line|
          sign, entry_id, name = line.split(/\s+/, 3)
          hash[entry_id] = name
        end
        hash
      end

    end #module PathwaysAsHash

  end #module KEGG
end #module Bio

