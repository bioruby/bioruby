#
# = bio/db/chromatogram/chromatogram_to_biosequence.rb - Bio::Chromatogram to Bio::Sequence adapter module
#
# Copyright::   Copyright (C) 2008
#               Anthony Underwood <email2ants@gmail.com>
# License::     The Ruby License
#
# $Id:$
#

require 'bio/sequence'
require 'bio/sequence/adapter'

# Internal use only. Normal users should not use this module.
#
# Bio::Chromatogram to Bio::Sequence adapter module.
# It is internally used in Bio::Chromatogram#to_biosequence.
#
module Bio::Sequence::Adapter::Chromatogram

  extend Bio::Sequence::Adapter

  private

  def_biosequence_adapter :seq

  # primary accession
  def_biosequence_adapter :primary_accession do |orig|
    orig.version
  end
  
  # # secondary accessions
  # def_biosequence_adapter :secondary_accessions do |orig|
  #   orig.identifiers.accessions[1..-1]
  # end
  # 
  # # entry_id
  # def_biosequence_adapter :entry_id do |orig|
  #   orig.identifiers.locus or orig.identifiers.accessions.first or
  #     orig.identifiers.entry_id
  # end
  # 
  # # NCBI GI is stored on other_seqids
  # def_biosequence_adapter :other_seqids do |orig|
  #   other = []
  #   if orig.identifiers.gi then
  #     other.push Bio::Sequence::DBLink.new('GI', orig.identifiers.gi)
  #   end
  #   other.empty? ? nil : other
  # end
  # 
  # # definition
  # def_biosequence_adapter :definition do |orig|
  #   if orig.identifiers.accessions.empty? and
  #       !(orig.identifiers.gi) then
  #     orig.definition
  #   else
  #     orig.identifiers.description
  #   end
  # end

end #module Bio::Sequence::Adapter::Chromatogram

