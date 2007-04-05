#
# = bio/appl/gcg/seq.rb - GCG sequence file format class (.seq/.pep file)
#
# Copyright::   Copyright (C) 2003, 2006
#               Naohisa Goto <ng@bioruby.org>
# License::     The Ruby License
#
# $Id: seq.rb,v 1.3 2007/04/05 23:35:39 trevor Exp $
#
# = About Bio::GCG::Seq
#
# Please refer document of Bio::GCG::Seq.
#

module Bio
  module GCG

    # 
    # = Bio::GCG::Seq
    # 
    # This is GCG sequence file format (.seq or .pep) parser class.
    #
    # = References
    #
    # * Information about GCG Wisconsin Package(R)
    # http://www.accelrys.com/products/gcg_wisconsin_package .
    # * EMBOSS sequence formats
    # http://www.hgmp.mrc.ac.uk/Software/EMBOSS/Themes/SequenceFormats.html
    # * BioPerl document
    # http://docs.bioperl.org/releases/bioperl-1.2.3/Bio/SeqIO/gcg.html
    class Seq #< DB

      # delimiter used by Bio::FlatFile
      DELIMITER = RS = nil

      # Creates new instance of this class.
      # str must be a GCG seq formatted string.
      def initialize(str)
        @heading = str[/.*/] # '!!NA_SEQUENCE 1.0' or like this
        str = str.sub(/.*/, '')
        str.sub!(/.*\.\.$/m, '')
        @definition = $&.to_s.sub(/^.*\.\.$/, '').to_s
        desc = $&.to_s
        if m = /(.+)\s+Length\:\s+(\d+)\s+(.+)\s+Type\:\s+(\w)\s+Check\:\s+(\d+)/.match(desc) then
          @entry_id = m[1].to_s.strip
          @length   = (m[2] ? m[2].to_i : nil)
          @date     = m[3].to_s.strip
          @seq_type = m[4]
          @checksum = (m[5] ? m[5].to_i : nil)
        end
        @data = str
        @seq = nil
        @definition.strip!
      end

      # ID field.
      attr_reader :entry_id

      # Description field.
      attr_reader :definition

      # "Length:" field.
      # Note that sometimes this might differ from real sequence length.
      attr_reader :length

      # Date field of this entry.
      attr_reader :date

      # "Type:" field, which indicates sequence type.
      # "N" means nucleic acid sequence, "P" means protein sequence.
      attr_reader :seq_type

      # "Check:" field, which indicates checksum of current sequence.
      attr_reader :checksum

      # heading
      # ('!!NA_SEQUENCE 1.0' or whatever like this)
      attr_reader :heading

      #---
      ## data (internally used, will be obsoleted)
      #attr_reader :data
      #+++

      # Sequence data.
      # The class of the sequence is Bio::Sequence::NA, Bio::Sequence::AA
      # or Bio::Sequence::Generic, according to the sequence type.
      def seq
        unless @seq then
          case @seq_type
          when 'N', 'n'
            k = Bio::Sequence::NA
          when 'P', 'p'
            k = Bio::Sequence::AA
          else
            k = Bio::Sequence
          end
          @seq = k.new(@data.tr('^-a-zA-Z.~', ''))
        end
        @seq
      end

      # If you know the sequence is AA, use this method.
      # Returns a Bio::Sequence::AA object.
      #
      # If you call naseq for protein sequence,
      # or aaseq for nucleic sequence, RuntimeError will be raised.
      def aaseq
        if seq.is_a?(Bio::Sequence::AA) then
          @seq
        else
          raise 'seq_type != \'P\''
        end
      end

      # If you know the sequence is NA, use this method.
      # Returens a Bio::Sequence::NA object.
      #
      # If you call naseq for protein sequence,
      # or aaseq for nucleic sequence, RuntimeError will be raised.
      def naseq
        if seq.is_a?(Bio::Sequence::NA) then
          @seq
        else
          raise 'seq_type != \'N\''
        end
      end

      # Validates checksum.
      # If validation succeeds, returns true.
      # Otherwise, returns false.
      def validate_checksum
        checksum == self.class.calc_checksum(seq)
      end

      #---
      # class methods
      #+++

      # Calculates checksum from given string.
      def self.calc_checksum(str)
        # Reference: Bio::SeqIO::gcg of BioPerl-1.2.3
        idx = 0
        sum = 0
        str.upcase.tr('^A-Z.~', '').each_byte do |c|
          idx += 1
          sum += idx * c
          idx = 0 if idx >= 57
        end
        (sum % 10000)
      end

      # Creates a new GCG sequence format text.
      # Parameters can be omitted.
      #
      # Examples:
      #  Bio::GCG::Seq.to_gcg(:definition=>'H.sapiens DNA',
      #                       :seq_type=>'N', :entry_id=>'gi-1234567',
      #                       :seq=>seq, :date=>date)
      #
      def self.to_gcg(hash)
        seq = hash[:seq]
        if seq.is_a?(Bio::Sequence::NA) then
          seq_type = 'N'
        elsif seq.is_a?(Bio::Sequence::AA) then
          seq_type = 'P'
        else
          seq_type = (hash[:seq_type] or 'P')
        end
        if seq_type == 'N' then
          head = '!!NA_SEQUENCE 1.0'
        else
          head = '!!AA_SEQUENCE 1.0'
        end
        date = (hash[:date] or Time.now.strftime('%B %d, %Y %H:%M'))
        entry_id = hash[:entry_id].to_s.strip
        len = seq.length
        checksum = self.calc_checksum(seq)
        definition = hash[:definition].to_s.strip
        seq = seq.upcase.gsub(/.{1,50}/, "\\0\n")
        seq.gsub!(/.{10}/, "\\0 ")
        w = len.to_s.size + 1
        i = 1
        seq.gsub!(/^/) { |x| s = sprintf("\n%*d ", w, i); i += 50; s }

        [ head, "\n", definition, "\n\n",
          "#{entry_id}  Length: #{len}  #{date}  " \
          "Type: #{seq_type}  Check: #{checksum}  ..\n",
          seq, "\n" ].join('')
      end

    end #class Seq
  end #module GCG
end #module Bio

