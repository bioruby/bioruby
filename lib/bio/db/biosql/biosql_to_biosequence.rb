#
# = bio/db/biosql/biosql_to_biosequence.rb - Bio::SQL::Sequence to Bio::Sequence adapter module
#
# Copyright::   Copyright (C) 2008
#               Naohisa Goto <ng@bioruby.org>,
#               Raoul Jean Pierre Bonnal
# License::     The Ruby License
#
# $Id:$
#

require 'bio/sequence'
require 'bio/sequence/adapter'

# Internal use only. Normal users should not use this module.
#
# Bio::SQL::Sequence to Bio::Sequence adapter module.
# It is internally used in Bio::SQL::Sequence#to_biosequence.
#
module Bio::Sequence::Adapter::BioSQL

  extend Bio::Sequence::Adapter

  private

  def_biosequence_adapter :seq 
  
  def_biosequence_adapter :entry_id

  def_biosequence_adapter :primary_accession

  def_biosequence_adapter :secondary_accessions

  def_biosequence_adapter :molecule_type

  #--
  #TODO: identify where is stored data_class in biosql      
  #++

  def_biosequence_adapter :data_class

  def_biosequence_adapter :definition, :description

  def_biosequence_adapter :topology

  def_biosequence_adapter :date_created

  def_biosequence_adapter :date_modified

  def_biosequence_adapter :division

  def_biosequence_adapter :sequence_version

  def_biosequence_adapter :keywords

  def_biosequence_adapter :species

  def_biosequence_adapter :classification, :taxonomy

  def_biosequence_adapter :references

  def_biosequence_adapter :features
  
  def_biosequence_adapter :comments

  #--
  #TODO: .to_biosequence.output(:genbank) some major and minor problems.
  #1) Major. GI: is not exported IN(VERSION     X64011.1  GI:44010),OUT(VERSION     X64011.1)
  #1.1) Db storage is ok, GI is saved into identifier of bioentry
  #2) Moderate. date wrong format IN(26-SEP-2006), OUT(2006-09-26)
  #3) Minor. Organism in output as more terms.
  #4) Minor. Title has a dot at the end, input was without
  #++
  #def_biosequence_adapter :other_seqids, :identifier

end #module Bio::Sequence::Adapter::BioSQL

