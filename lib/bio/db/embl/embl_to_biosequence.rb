#
# = bio/db/embl/embl_to_biosequence.rb - Bio::EMBL to Bio::Sequence adapter module
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
# Bio::EMBL to Bio::Sequence adapter module.
# It is internally used in Bio::EMBL#to_biosequence.
#
module Bio::Sequence::Adapter::EMBL

  extend Bio::Sequence::Adapter

  private

  def_biosequence_adapter :seq

  def_biosequence_adapter :id_namespace do |orig|
    'EMBL'
  end

  def_biosequence_adapter :entry_id
  
  def_biosequence_adapter :primary_accession do |orig|
    orig.accessions[0]
  end

  def_biosequence_adapter :secondary_accessions do |orig|
    orig.accessions[1..-1] || []
  end

  def_biosequence_adapter :molecule_type

  def_biosequence_adapter :data_class

  def_biosequence_adapter :definition, :description

  def_biosequence_adapter :topology

  def_biosequence_adapter :date_created

  def_biosequence_adapter :date_modified

  def_biosequence_adapter :release_created

  def_biosequence_adapter :release_modified

  def_biosequence_adapter :entry_version

  def_biosequence_adapter :division

  def_biosequence_adapter :sequence_version, :version

  def_biosequence_adapter :keywords

  def_biosequence_adapter :species

  def_biosequence_adapter :classification

  #--
  # unsupported yet
  # def_biosequence_adapter :organelle do |orig|
  #   orig.fetch('OG')
  # end
  #++

  def_biosequence_adapter :references

  def_biosequence_adapter :features

  def_biosequence_adapter :comments, :cc

  def_biosequence_adapter :dblinks

end #module Bio::Sequence::Adapter::EMBL

