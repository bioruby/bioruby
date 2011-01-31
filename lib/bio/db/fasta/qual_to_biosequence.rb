#
# = bio/db/fasta/qual_to_biosequence.rb - Bio::FastaNumericFormat to Bio::Sequence adapter module
#
# Copyright::   Copyright (C) 2010
#               Naohisa Goto <ng@bioruby.org>
# License::     The Ruby License
#

require 'bio/sequence'
require 'bio/sequence/adapter'
require 'bio/db/fasta/fasta_to_biosequence'

# Internal use only. Normal users should not use this module.
#
# Bio::FastaNumericFormat to Bio::Sequence adapter module.
# It is internally used in Bio::FastaNumericFormat#to_biosequence.
#
module Bio::Sequence::Adapter::FastaNumericFormat

  extend Bio::Sequence::Adapter

  include Bio::Sequence::Adapter::FastaFormat

  private

  def_biosequence_adapter :quality_scores, :data

end #module Bio::Sequence::Adapter::FastaNumericFormat

