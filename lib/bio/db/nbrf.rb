#
# bio/db/nbrf.rb - NBRF/PIR format sequence data class
#
#   Copyright (C) 2001-2003 GOTO Naohisa <ngoto@gen-info.osaka-u.ac.jp>
#   Copyright (C) 2001-2002 KATAYAMA Toshiaki <k@bioruby.org>
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
#  $Id: nbrf.rb,v 1.2 2003/10/10 11:49:43 ng Exp $
#

require 'bio/db'
require 'bio/sequence'

module Bio
  class NBRF < DB
    # based on Bio::FastaFormat class

    DELIMITER	= RS = "*\n"

    def initialize(str)
      str = str.sub(/\A[\r\n]+/, '') # remove first void lines
      line1, line2, rest = str.split(/^/, 3)

      rest = rest.to_s
      rest.sub!(/^>.*/m, '') # remove trailing entries for sure
      @entry_overrun = $&
      rest.sub!(/\*\s*\z/, '') # remove last '*' and "\n"
      @data = rest

      @definition = line2.to_s.chomp
      if /^>?([A-Za-z0-9]{2})\;(.*)/ =~ line1.to_s then
	@seq_type = $1
	@entry_id = $2
      end
    end
    attr_accessor :seq_type, :entry_id, :definition, :data
    attr_reader :entry_overrun

    alias :accession :entry_id

    def entry
      @entry = ">#{@seq_type or 'XX'};#{@entry_id}\n#{definition}\n#{@data}*\n"
    end
    alias :to_s :entry

    def seq_class
      case @seq_type
      when /[PF]1/
	# protein
	Sequence::AA
      when /[DR][LC]/, /N[13]/
	# nucleic
	Sequence::NA
      else
	Sequence
      end
    end

    def seq
      unless defined?(@seq)
	@seq = seq_class.new(@data.tr(" \t\r\n0-9", '')) # lazy clean up
      end
      @seq
    end

    def length
      seq.length
    end

    def naseq
      if seq.is_a?(Bio::Sequence::AA) then
	raise 'not nucleic but protein sequence'
      elsif seq.is_a?(Bio::Sequence::NA) then
	seq
      else
	Bio::Sequence::NA.new(seq)
      end
    end
      
    def nalen
      naseq.length
    end

    def aaseq
      if seq.is_a?(Bio::Sequence::NA) then
	raise 'not nucleic but protein sequence'
      elsif seq.is_a?(Bio::Sequence::AA) then
	seq
      else
	Bio::Sequence::AA.new(seq)
      end
    end

    def aalen
      aaseq.length
    end

    #class method
    def self.to_nbrf(hash)
      seq_type = hash[:seq_type]
      seq = hash[:seq]
      unless seq_type
	if seq.is_a?(Bio::Sequence::AA) then
	  seq_type = 'P1'
	elsif seq.is_a?(Bio::Sequence::NA) then
	  seq_type = /u/i =~ seq ? 'RL' : 'DL'
	else
	  seq_type = 'XX'
	end
      end
      width = hash.has_key?(:width) ? hash[:width] : 70
      if width then
	seq = seq.to_s + "*"
	seq.gsub!(Regexp.new(".{1,#{width}}"), "\\0\n")
      else
	seq = seq.to_s + "*\n"
      end
      ">#{seq_type};#{hash[:entry_id]}\n#{hash[:definition]}\n#{seq}"
    end

  end #class NBRF
end #module Bio

=begin

= Bio::NBRF

 This is a sequence data class for NBRF/PIR flatfile format.

 http://pir.georgetown.edu/pirwww/otherinfo/doc/techbulletin.html
 http://www.sander.embl-ebi.ac.uk/Services/webin/help/webin-align/align_format_help.html#pir
 http://www.cmbi.kun.nl/bioinf/tools/crab_pir.html

The precedent '>' can be omitted and the trailing '>' will be removed
automatically.

--- Bio::NBRF.new(entry)

      Stores the comment and sequence information from one entry of the
      NBRF/PIR format string.  If the argument contains more than one
      entry, only the first entry is used.

--- Bio::NBRF#entry

      Returns the stored one entry as a NBRF/PIR format. (same as to_s)


--- Bio::NBRF#seq_type

      Returns sequence type described in the entry.

      * P1 (protein), F1 (protein fragment)
      * DL (DNA linear), DC (DNA circular)
      * RL (DNA linear), RC (DNA circular)
      * N3 (tRNA), N1 (other functional RNA)

--- Bio::NBRF#seq_class

      Returns Bio::Sequence::AA, Bio::Sequence::NA, or Bio::Sequence,
      depending on sequence type.

--- Bio::NBRF#entry_id

      Returns ID described in the entry.

--- Bio::NBRF#accession

      Same as Bio::NBRF#entry_id.

--- Bio::NBRF#definition

      Returns the description line of the NBRF/PIR formatted data.

--- Bio::NBRF#seq

      Returns a joined sequence line as a String.
      Returns Bio::Sequence::NA, Bio::Sequence::AA or Bio::Sequence,
      according to the sequence type.

--- Bio::NBRF#length

      Returns sequence length.

--- Bio::NBRF#naseq
--- Bio::NBRF#nalen
--- Bio::NBRF#aaseq
--- Bio::NBRF#aalen

      If you know whether the sequence is NA or AA, use these methods.
      'naseq' and 'aaseq' methods returen the Bio::Sequence::NA or
      Bio::Sequence::AA object respectively. 'nalen' and 'aalen' methods
      return the length of them.

      If you call naseq for protein sequence, or aaseq for nucleic sequence,
      a RuntimeError will be occurred.

--- Bio::NBRF.to_nbrf(:seq_type=>'P1', :entry_id=>'XXX00000',
                      :definition=>'xxx protein',
                      :seq=>seq, :width=>70)

      Creates a NBRF/PIR formatted text.
      Parameters can be omitted.

=end

