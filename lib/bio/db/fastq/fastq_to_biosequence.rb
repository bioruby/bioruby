#
# = bio/db/fastq/fastq_to_biosequence.rb - Bio::Fastq to Bio::Sequence adapter module
#
# Copyright::   Copyright (C) 2009
#               Naohisa Goto <ng@bioruby.org>
# License::     The Ruby License
#

require 'bio/sequence'
require 'bio/sequence/adapter'

# Internal use only. Normal users should not use this module.
#
# Bio::Fastq to Bio::Sequence adapter module.
# It is internally used in Bio::Fastq#to_biosequence.
#
module Bio::Sequence::Adapter::Fastq

  extend Bio::Sequence::Adapter

  private

  def_biosequence_adapter :seq

  def_biosequence_adapter :entry_id

  # primary accession
  def_biosequence_adapter :primary_accession do |orig|
    orig.entry_id
  end

  def_biosequence_adapter :definition

  def_biosequence_adapter :quality_scores

  def_biosequence_adapter :quality_score_type

  def_biosequence_adapter :error_probabilities

end #module Bio::Sequence::Adapter::Fastq
