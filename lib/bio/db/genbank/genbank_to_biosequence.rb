#
# = bio/db/genbank/genbank_to_biosequence.rb - Bio::GenBank to Bio::Sequence adapter module
#
# Copyright::   Copyright (C) 2008
#               Naohisa Goto <ng@bioruby.org>,
# License::     The Ruby License
#
# $Id:$
#

require 'bio/sequence'
require 'bio/sequence/adapter'

# Internal use only. Normal users should not use this module.
#
# Bio::GenBank to Bio::Sequence adapter module.
# It is internally used in Bio::GenBank#to_biosequence.
#
module Bio::Sequence::Adapter::GenBank

  extend Bio::Sequence::Adapter

  private

  def_biosequence_adapter :seq

  def_biosequence_adapter :id_namespace do |orig|
    if /\_/ =~ orig.accession.to_s then
      'RefSeq'
    else
      'GenBank'
    end
  end

  def_biosequence_adapter :entry_id

  def_biosequence_adapter :primary_accession, :accession

  def_biosequence_adapter :secondary_accessions do |orig|
    orig.accessions - [ orig.accession ]
  end

  def_biosequence_adapter :other_seqids do |orig|
    if /GI\:(.+)/ =~ orig.gi.to_s then
      [ Bio::Sequence::DBLink.new('GI', $1) ]
    else
      nil
    end
  end

  def_biosequence_adapter :molecule_type, :natype

  def_biosequence_adapter :division

  def_biosequence_adapter :topology, :circular

  def_biosequence_adapter :strandedness

  def_biosequence_adapter :sequence_version, :version

  #--
  #sequence.date_created = nil #????
  #++

  def_biosequence_adapter :date_modified

  def_biosequence_adapter :definition

  def_biosequence_adapter :keywords

  def_biosequence_adapter :species, :organism

  def_biosequence_adapter :classification

  #--
  #sequence.organelle = nil # yet unsupported
  #++

  def_biosequence_adapter :comments, :comment

  def_biosequence_adapter :references

  def_biosequence_adapter :features

end #module Bio::Sequence::Adapter::GenBank

