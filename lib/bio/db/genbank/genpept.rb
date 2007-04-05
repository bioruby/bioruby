#
# = bio/db/genbank/genpept.rb - GenPept database class
#
# Copyright::  Copyright (C) 2002-2004 Toshiaki Katayama <k@bioruby.org>
# License::    The Ruby License
#
# $Id: genpept.rb,v 1.12 2007/04/05 23:35:40 trevor Exp $
#

require 'bio/db/genbank/common'
require 'bio/db/genbank/genbank'

module Bio
class GenPept < NCBIDB

  include Bio::NCBIDB::Common

  # LOCUS
  class Locus
    def initialize(locus_line)
      @entry_id = locus_line[12..27].strip
      @length   = locus_line[29..39].to_i
      @circular = locus_line[55..62].strip	# always linear
      @division = locus_line[63..66].strip
      @date     = locus_line[68..78].strip
    end
    attr_accessor :entry_id, :length, :circular, :division, :date
  end

  def locus
    @data['LOCUS'] ||= Locus.new(get('LOCUS'))
  end
  def entry_id;		locus.entry_id;		end
  def length;		locus.length;		end
  def circular;		locus.circular;		end
  def division;		locus.division;		end
  def date;		locus.date;		end


  # ORIGIN
  def seq
    unless @data['SEQUENCE']
      origin
    end
    Bio::Sequence::AA.new(@data['SEQUENCE'])
  end
  alias aaseq seq
  alias aalen length

  def seq_len
    seq.length
  end

  # DBSOURCE
  def dbsource
    get('DBSOURCE')
  end

end # GenPept
end # Bio
