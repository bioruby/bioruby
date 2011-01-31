#
# = bio/db/litdb.rb - LITDB database class
#
# Copyright::  Copyright (C) 2001 Toshiaki Katayama <k@bioruby.org>
# License::    The Ruby License
#
# $Id:$
#

require 'bio/db'

module Bio

  # = LITDB class
  class LITDB < NCBIDB

    # Delimiter
    DELIMITER = "\nEND\n"

    # Delimiter
    RS = DELIMITER

    #
    TAGSIZE = 12

    #
    def initialize(entry)
      super(entry, TAGSIZE)
    end

    # Returns
    def reference
      hash = Hash.new('') 

      hash['authors'] = author.split(/;/).map {|x| x.sub(/,/, ', ')}
      hash['title']   = title 
      hash['journal'] = journal.gsub(/\./, '. ').strip

      vol = volume.split(/,\s+/)
      if vol.size > 1
        hash['volume'] = vol.shift.sub(/Vol\./, '')
        hash['pages'],
        hash['year'] = vol.pop.split(' ')
        hash['issue'] = vol.shift.sub(/No\./, '') unless vol.empty?
      end

      return Reference.new(hash) 
    end

    # CODE
    def entry_id
      field_fetch('CODE')
    end

    # TITLE
    def title
      field_fetch('TITLE')
    end

    # FIELD
    def field
      field_fetch('FIELD')
    end

    # JOURNAL
    def journal
      field_fetch('JOURNAL')
    end

    # VOLUME
    def volume
      field_fetch('VOLUME')
    end

    # KEYWORD ';;'
    def keyword
      unless @data['KEYWORD']
        @data['KEYWORD'] = fetch('KEYWORD').split(/;;\s*/)
      end
      @data['KEYWORD']
    end

    # AUTHOR
    def author
      field_fetch('AUTHOR')
    end

  end

end


