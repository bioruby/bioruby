#
# bio/db/lasergene.rb - Interface for DNAStar Lasergene sequence file format
#
# Author::    Trevor Wennblom  <mailto:trevor@corevx.com>
# Copyright:: Copyright (c) 2007 Center for Biomedical Research Informatics, University of Minnesota (http://cbri.umn.edu)
# License::   The Ruby License
#
#  $Id: lasergene.rb,v 1.3 2007/04/05 23:35:40 trevor Exp $
#

module Bio #:nodoc:

#
# bio/db/lasergene.rb - Interface for DNAStar Lasergene sequence file format
#
# Author::    Trevor Wennblom  <mailto:trevor@corevx.com>
# Copyright:: Copyright (c) 2007 Center for Biomedical Research Informatics, University of Minnesota (http://cbri.umn.edu)
# License::   The Ruby License
#
# = Description
#
# Bio::Lasergene reads DNAStar Lasergene formatted sequence files, or +.seq+ 
# files.  It only expects to find one sequence per file.
#
# = Usage
#
#   require 'bio'
#   filename = 'MyFile.seq'
#   lseq = Bio::Lasergene.new( IO.readlines(filename) )
#   lseq.entry_id  # => "Contig 1"
#   lseq.seq  # => ATGACGTATCCAAAGAGGCGTTACC
#
# = Comments
# 
# I'm only aware of the following three kinds of Lasergene file formats.  Feel
# free to send me other examples that may not currently be accounted for.
#
# File format 1:
# 
#   ## begin ##
#   "Contig 1" (1,934)
#     Contig Length:                  934 bases
#     Average Length/Sequence:        467 bases
#     Total Sequence Length:         1869 bases
#     Top Strand:                       2 sequences
#     Bottom Strand:                    2 sequences
#     Total:                            4 sequences
#   ^^
#   ATGACGTATCCAAAGAGGCGTTACCGGAGAAGAAGACACCGCCCCCGCAGTCCTCTTGGCCAGATCCTCCGCCGCCGCCCCTGGCTCGTCCACCCCCGCCACAGTTACCGCTGGAGAAGGAAAAATGGCATCTTCAWCACCCGCCTATCCCGCAYCTTCGGAWRTACTATCAAGCGAACCACAGTCAGAACGCCCTCCTGGGCGGTGGACATGATGAGATTCAATATTAATGACTTTCTTCCCCCAGGAGGGGGCTCAAACCCCCGCTCTGTGCCCTTTGAATACTACAGAATAAGAAAGGTTAAGGTTGAATTCTGGCCCTGCTCCCCGATCACCCAGGGTGACAGGGGAATGGGCTCCAGTGCTGWTATTCTAGMTGATRRCTTKGTAACAAAGRCCACAGCCCTCACCTATGACCCCTATGTAAACTTCTCCTCCCGCCATACCATAACCCAGCCCTTCTCCTACCRCTCCCGYTACTTTACCCCCAAACCTGTCCTWGATKCCACTATKGATKACTKCCAACCAAACAACAAAAGAAACCAGCTGTGGSTGAGACTACAWACTGCTGGAAATGTAGACCWCGTAGGCCTSGGCACTGCGTKCGAAAACAGTATATACGACCAGGAATACAATATCCGTGTMACCATGTATGTACAATTCAGAGAATTTAATCTTAAAGACCCCCCRCTTMACCCKTAATGAATAATAAMAACCATTACGAAGTGATAAAAWAGWCTCAGTAATTTATTYCATATGGAAATTCWSGGCATGGGGGGGAAAGGGTGACGAACKKGCCCCCTTCCTCCSTSGMYTKTTCYGTAGCATTCYTCCAMAAYACCWAGGCAGYAMTCCTCCSATCAAGAGcYTSYACAGCTGGGACAGCAGTTGAGGAGGACCATTCAAAGGGGGTCGGATTGCTGGTAATCAGA
#   ## end ##
# 
# 
# File format 2:
# 
#   ## begin ##
#   ^^:                                  350,935
#   Contig 1 (1,935)
#     Contig Length:                  935 bases
#     Average Length/Sequence:        580 bases
#     Total Sequence Length:         2323 bases
#     Top Strand:                       2 sequences
#     Bottom Strand:                    2 sequences
#     Total:                            4 sequences
#   ^^
#   ATGTCGGGGAAATGCTTGACCGCGGGCTACTGCTCATCATTGCTTTCTTTGTGGTATATCGTGCCGTTCTGTTTTGCTGTGCTCGTCAACGCCAGCGGCGACAGCAGCTCTCATTTTCAGTCGATTTATAACTTGACGTTATGTGAGCTGAATGGCACGAACTGGCTGGCAGACAACTTTAACTGGGCTGTGGAGACTTTTGTCATCTTCCCCGTGTTGACTCACATTGTTTCCTATGGTGCACTCACTACCAGTCATTTTCTTGACACAGTTGGTCTAGTTACTGTGTCTACCGCCGGGTTTTATCACGGGCGGTACGTCTTGAGTAGCATCTACGCGGTCTGTGCTCTGGCTGCGTTGATTTGCTTCGCCATCAGGTTTGCGAAGAACTGCATGTCCTGGCGCTACTCTTGCACTAGATACACCAACTTCCTCCTGGACACCAAGGGCAGACTCTATCGTTGGCGGTCGCCTGTCATCATAGAGAAAGGGGGTAAGGTTGAGGTCGAAGGTCATCTGATCGATCTCAAAAGAGTTGTGCTTGATGGCTCTGTGGCGACACCTTTAACCAGAGTTTCAGCGGAACAATGGGGTCGTCCCTAGACGACTTTTGCCATGATAGTACAGCCCCACAGAAGGTGCTCTTGGCGTTTTCCATCACCTACACGCCAGTGATGATATATGCCCTAAAGGTAAGCCGCGGCCGACTTTTGGGGCTTCTGCACCTTTTGATTTTTTTGAACTGTGCCTTTACTTTCGGGTACATGACATTCGTGCACTTTCGGAGCACGAACAAGGTCGCGCTCACTATGGGAGCAGTAGTCGCACTCCTTTGGGGGGTGTACTCAGCCATAGAAACCTGGAAATTCATCACCTCCAGATGCCGTTGTGCTTGCTAGGCCGCAAGTACATTCTGGCCCCTGCCCACCACGTTG
#   ## end ##
# 
# File format 3 (non-standard Lasergene header):
# 
#   ## begin ##
#   LOCUS       PRU87392               15411 bp    RNA     linear   VRL 17-NOV-2000
#   DEFINITION  Porcine reproductive and respiratory syndrome virus strain VR-2332,
#               complete genome.
#   ACCESSION   U87392 AF030244 U00153
#   VERSION     U87392.3  GI:11192298
#   [...cut...]
#        3'UTR           15261..15411
#        polyA_site      15409
#   ORIGIN      
#   ^^
#   atgacgtataggtgttggctctatgccttggcatttgtattgtcaggagctgtgaccattggcacagcccaaaacttgctgcacagaaacacccttctgtgatagcctccttcaggggagcttagggtttgtccctagcaccttgcttccggagttgcactgctttacggtctctccacccctttaaccatgtctgggatacttgatcggtgcacgtgtacccccaatgccagggtgtttatggcggagggccaagtctactgcacacgatgcctcagtgcacggtctctccttcccctgaacctccaagtttctgagctcggggtgctaggcctattctacaggcccgaagagccactccggtggacgttgccacgtgcattccccactgttgagtgctcccccgccggggcctgctggctttctgcaatctttccaatcgcacgaatgaccagtggaaacctgaacttccaacaaagaatggtacgggtcgcagctgagctttacagagccggccagctcacccctgcagtcttgaaggctctacaagtttatgaacggggttgccgctggtaccccattgttggacctgtccctggagtggccgttttcgccaattccctacatgtgagtgataaacctttcccgggagcaactcacgtgttgaccaacctgccgctcccgcagagacccaagcctgaagacttttgcccctttgagtgtgctatggctactgtctatgacattggtcatgacgccgtcatgtatgtggccgaaaggaaagtctcctgggcccctcgtggcggggatgaagtgaaatttgaagctgtccccggggagttgaagttgattgcgaaccggctccgcacctccttcccgccccaccacacagtggacatgtctaagttcgccttcacagcccctgggtgtggtgtttctatgcgggtcgaacgccaacacggctgccttcccgctgacactgtccctgaaggcaactgctggtggagcttgtttgacttgcttccactggaagttcagaacaaagaaattcgccatgctaaccaatttggctaccagaccaagcatggtgtctctggcaagtacctacagcggaggctgca[...cut...]
#   ## end ##
#
class Lasergene
  # Entire header before the sequence
  attr_reader :comments
  
  # Sequence
  # 
  # Bio::Sequence::NA or Bio::Sequence::AA object
  attr_reader :sequence
  
  # Name of sequence
  # * Parsed from standard Lasergene header
  attr_reader :name
  
  # Contig length, length of present sequence
  # * Parsed from standard Lasergene header
  attr_reader :contig_length
  
  # Average length per sequence
  # * Parsed from standard Lasergene header
  attr_reader :average_length
  
  # Length of parent sequence
  # * Parsed from standard Lasergene header
  attr_reader :total_length
  
  # Number of top strand sequences
  # * Parsed from standard Lasergene header
  attr_reader :top_strand_sequences
  
  # Number of bottom strand sequences
  # * Parsed from standard Lasergene header
  attr_reader :bottom_strand_sequences
  
  # Number of sequences
  # * Parsed from standard Lasergene header
  attr_reader :total_sequences

  DELIMITER_1 = '^\^\^:' # Match '^^:' at the beginning of a line
  DELIMITER_2 = '^\^\^'  # Match '^^' at the beginning of a line

  def initialize(lines)
    process(lines)
  end  
  
  # Is the comment header recognized as standard Lasergene format?
  #
  # ---
  # *Arguments*
  # * _none_
  # *Returns*:: +true+ _or_ +false+
  def standard_comment?
    @standard_comment
  end
  
  # Sequence
  # 
  # Bio::Sequence::NA or Bio::Sequence::AA object
  def seq
    @sequence
  end
  
  # Name of sequence
  # * Parsed from standard Lasergene header
  def entry_id
    @name
  end
  
  #########
  protected
  #########
  
  def process(lines)
    delimiter_1_indices = []
    delimiter_2_indices = []
    
    # If the data from the file is passed as one big String instead of
    # broken into an Array, convert lines to an Array
    if lines.kind_of? String
      lines = lines.tr("\r", '').split("\n")
    end

    lines.each_with_index do |line, index|
      if line.match DELIMITER_1
        delimiter_1_indices << index
      elsif line.match DELIMITER_2
        delimiter_2_indices << index
      end
    end

    raise InputError, "More than one delimiter of type '#{DELIMITER_1}'" if delimiter_1_indices.size > 1
    raise InputError, "More than one delimiter of type '#{DELIMITER_2}'" if delimiter_2_indices.size > 1
    raise InputError, "No comment to data separator of type '#{DELIMITER_2}'" if delimiter_2_indices.size < 1

    if !delimiter_1_indices.empty?
      # toss out DELIMETER_1 and anything preceding it
      @comments = lines[ (delimiter_1_indices[0] + 1) .. (delimiter_2_indices[0] - 1) ]
    else
      @comments = lines[ 0 .. (delimiter_2_indices[0] - 1) ]
    end

    @standard_comment = false
    if @comments[0] =~ %r{(.+)\s+\(\d+,\d+\)} # if we have a standard Lasergene comment
      @standard_comment = true
      @name = $1
      comments.each do |comment|
        if comment.match('Contig Length:\s+(\d+)')
          @contig_length = $1.to_i
        elsif comment.match('Average Length/Sequence:\s+(\d+)')
          @average_length = $1.to_i
        elsif comment.match('Total Sequence Length:\s+(\d+)')
          @total_length = $1.to_i
        elsif comment.match('Top Strand:\s+(\d+)')
          @top_strand_sequences = $1.to_i
        elsif comment.match('Bottom Strand:\s+(\d+)')
          @bottom_strand_sequences = $1.to_i
        elsif comment.match('Total:\s+(\d+)')
          @total_sequences = $1.to_i
        end
      end
    end

    @comments = @comments.join('')
    @sequence = Bio::Sequence.auto( lines[ (delimiter_2_indices[0] + 1) .. -1 ].join('') )
  end
end # Lasergene
end # Bio