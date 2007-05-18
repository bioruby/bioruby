#
# = bio/db/gff.rb - GFF format class
#
# Copyright::  Copyright (C) 2003, 2005
#              Toshiaki Katayama <k@bioruby.org>
#              2006  Jan Aerts <jan.aerts@bbsrc.ac.uk>
# License::    The Ruby License
#
# $Id: gff.rb,v 1.9 2007/05/18 15:23:42 k Exp $
#

module Bio
# == DESCRIPTION
# The Bio::GFF and Bio::GFF::Record classes describe data contained in a 
# GFF-formatted file. For information on the GFF format, see 
# http://www.sanger.ac.uk/Software/formats/GFF/. Data are represented in tab- 
# delimited format, including
# * seqname
# * source
# * feature
# * start
# * end
# * score
# * strand
# * frame
# * attributes (optional)
# 
# For example:
#  SEQ1     EMBL        atg       103   105     .       +       0
#  SEQ1     EMBL        exon      103   172     .       +       0
#  SEQ1     EMBL        splice5   172   173     .       +       .
#  SEQ1     netgene     splice5   172   173     0.94    +       .
#  SEQ1     genie       sp5-20    163   182     2.3     +       .
#  SEQ1     genie       sp5-10    168   177     2.1     +       .
#  SEQ1     grail       ATG       17    19      2.1     -       0
#
# The Bio::GFF object is a container for Bio::GFF::Record objects, each 
# representing a single line in the GFF file.
class GFF
  # Creates a Bio::GFF object by building a collection of Bio::GFF::Record
  # objects.
  # 
  # Create a Bio::GFF object the hard way
  #  this_gff =  "SEQ1\tEMBL\tatg\t103\t105\t.\t+\t0\n"
  #  this_gff << "SEQ1\tEMBL\texon\t103\t172\t.\t+\t0\n"
  #  this_gff << "SEQ1\tEMBL\tsplice5\t172\t173\t.\t+\t.\n"
  #  this_gff << "SEQ1\tnetgene\tsplice5\t172\t173\t0.94\t+\t.\n"
  #  this_gff << "SEQ1\tgenie\tsp5-20\t163\t182\t2.3\t+\t.\n"
  #  this_gff << "SEQ1\tgenie\tsp5-10\t168\t177\t2.1\t+\t.\n"
  #  this_gff << "SEQ1\tgrail\tATG\t17\t19\t2.1\t-\t0\n"
  #  p Bio::GFF.new(this_gff)
  #  
  # or create one based on a GFF-formatted file:
  #  p Bio::GFF.new(File.open('my_data.gff')
  # ---
  # *Arguments*:
  # * _str_: string in GFF format
  # *Returns*:: Bio::GFF object
  def initialize(str = '')
    @records = Array.new
    str.each_line do |line|
      @records << Record.new(line)
    end
  end

  # An array of Bio::GFF::Record objects.
  attr_accessor :records

  # Represents a single line of a GFF-formatted file. See Bio::GFF for more
  # information.
  class Record

    # Name of the reference sequence
    attr_accessor :seqname
    
    # Name of the source of the feature (e.g. program that did prediction)
    attr_accessor :source
    
    # Name of the feature
    attr_accessor :feature
    
    # Start position of feature on reference sequence
    attr_accessor :start
    
    # End position of feature on reference sequence
    attr_accessor :end
    
    # Score of annotation (e.g. e-value for BLAST search)
    attr_accessor :score
    
    # Strand that feature is located on
    attr_accessor :strand
    
    # For features of type 'exon': indicates where feature begins in the reading frame
    attr_accessor :frame
    
    # List of tag=value pairs (e.g. to store name of the feature: ID=my_id)
    attr_accessor :attributes
    
    # Comments for the GFF record
    attr_accessor :comments

    # Creates a Bio::GFF::Record object. Is typically not called directly, but
    # is called automatically when creating a Bio::GFF object.
    # ---
    # *Arguments*:
    # * _str_: a tab-delimited line in GFF format
    def initialize(str)
      @comments = str.chomp[/#.*/]
      return if /^#/.match(str)
      @seqname, @source, @feature, @start, @end, @score, @strand, @frame,
        attributes, = str.chomp.split("\t")
      @attributes = parse_attributes(attributes) if attributes
    end

    private

    def parse_attributes(attributes)
      hash = Hash.new
      attributes.split(/[^\\];/).each do |atr|
        key, value = atr.split(' ', 2)
        hash[key] = value
      end
      return hash
    end
  end

  # = DESCRIPTION
  # Represents version 2 of GFF specification. Is completely implemented by the
  # Bio::GFF class.
  class GFF2 < GFF
    VERSION = 2
  end

  # = DESCRIPTION
  # Represents version 3 of GFF specification. Is completely implemented by the
  # Bio::GFF class. For more information on version GFF3, see
  # http://flybase.bio.indiana.edu/annot/gff3.html
  class GFF3 < GFF
    VERSION = 3

    private

    def parse_attributes(attributes)
      hash = Hash.new
      attributes.split(/[^\\];/).each do |atr|
        key, value = atr.split('=', 2)
        hash[key] = value
      end
      return hash
    end
  end

end # class GFF

end # module Bio


if __FILE__ == $0
  begin
    require 'pp'
    alias p pp
  rescue LoadError
  end

  this_gff =  "SEQ1\tEMBL\tatg\t103\t105\t.\t+\t0\n"
  this_gff << "SEQ1\tEMBL\texon\t103\t172\t.\t+\t0\n"
  this_gff << "SEQ1\tEMBL\tsplice5\t172\t173\t.\t+\t.\n"
  this_gff << "SEQ1\tnetgene\tsplice5\t172\t173\t0.94\t+\t.\n"
  this_gff << "SEQ1\tgenie\tsp5-20\t163\t182\t2.3\t+\t.\n"
  this_gff << "SEQ1\tgenie\tsp5-10\t168\t177\t2.1\t+\t.\n"
  this_gff << "SEQ1\tgrail\tATG\t17\t19\t2.1\t-\t0\n"
  p Bio::GFF.new(this_gff)
end
