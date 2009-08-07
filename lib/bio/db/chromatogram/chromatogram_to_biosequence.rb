#
# = bio/db/chromatogram/chromatogram_to_biosequence.rb - Bio::Chromatogram to Bio::Sequence adapter module
#
# Copyright::   Copyright (C) 2009
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
  


end #module Bio::Sequence::Adapter::Chromatogram

