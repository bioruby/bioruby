#
# bio/db/fasta.rb - FASTA format class
#
#   Copyright (C) 2001 GOTO Naohisa <ngoto@gen-info.osaka-u.ac.jp>
#
#  This library is free software; you can redistribute it and/or
#  modify it under the terms of the GNU Library General Public
#  License as published by the Free Software Foundation; either
#  version 2 of the License, or (at your option) any later version.
#
#  This library is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
#  Library General Public License for more details.
#
#  $Id: fasta.rb,v 1.1 2001/11/01 11:55:16 katayama Exp $
#

require 'bio/db'
require 'bio/sequence'

module Bio

  class FastaFormat < DB

    DELIMITER	= RS = "\n>"
    
    def initialize(str)
      @header = str[/.*/].sub(/^>/, '').strip		# 1st line
      @seq    = str.sub(/.*/, '').gsub(/\s+/, '')	# seq line
    end
    attr_accessor :header
    
    def definition
      @header
    end

    def length
      @seq.length
    end
    
    def naseq
      @naseq = Sequence::NA.new(@seq) unless @naseq
      @naseq
    end
    
    def nalen
      self.naseq.length
    end
    
    def aaseq
      @aaseq = Sequence::AA.new(@seq) unless @aaseq
      @aaseq
    end
    
    def aalen
      self.aaseq.length
    end

  end

end

