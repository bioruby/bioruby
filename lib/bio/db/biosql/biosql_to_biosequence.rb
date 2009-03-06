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
  #do |bs|
   #   Date.parse(bs.date_modified.to_s).strftime("%d-%b-%Y").upcase
    # end

  def_biosequence_adapter :division

  def_biosequence_adapter :sequence_version

  def_biosequence_adapter :keywords

  def_biosequence_adapter :species

  def_biosequence_adapter :classification, :taxonomy

  def_biosequence_adapter :references

  def_biosequence_adapter :features
  
  def_biosequence_adapter :comments

  def_biosequence_adapter :other_seqids do |orig|
    orig.identifier.split(',').collect do |dblink|
      database, id = dblink.split(':')
      Bio::Sequence::DBLink.new(database,id)
    end
  end

end #module Bio::Sequence::Adapter::BioSQL

