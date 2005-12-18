#
# = bio/db/litdb.rb - LITDB database class
#
# Copyright::  Copyright (C) 2001 KATAYAMA Toshiaki <k@bioruby.org>
# License::    LGPL
#
#  $Id: litdb.rb,v 0.7 2005/12/18 15:58:41 k Exp $
#
# == Description
#
#
# == Example
# == References
#
#--
#
#  This library is free software; you can redistribute it and/or
#  modify it under the terms of the GNU Lesser General Public
#  License as published by the Free Software Foundation; either
#  version 2 of the License, or (at your option) any later version.
#
#  This library is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
#  Lesser General Public License for more details.
#
#  You should have received a copy of the GNU Lesser General Public
#  License along with this library; if not, write to the Free Software
#  Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307  USA
#
#++
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


if __FILE__ == $0
  require 'bio/io/fetch'

  entry = Bio::Fetch.query('litdb', '0308004') 
  puts entry
  p Bio::LITDB.new(entry).reference

  entry = Bio::Fetch.query('litdb', '0309094')
  puts entry
  p Bio::LITDB.new(entry).reference

  entry = Bio::Fetch.query('litdb', '0309093')
  puts entry
  p Bio::LITDB.new(entry).reference
end
