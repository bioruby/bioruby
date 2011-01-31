#
# = bio/db/sanger_chromatogram/chromatogram_to_biosequence.rb - Bio::SangerChromatogram to Bio::Sequence adapter module
#
# Copyright::	Copyright (C) 2009 Anthony Underwood <anthony.underwood@hpa.org.uk>, <email2ants@gmail.com>
# License::	The Ruby License
#
# $Id:$
#

require 'bio/sequence'
require 'bio/sequence/adapter'

# Internal use only. Normal users should not use this module.
#
# Bio::SangerChromatogram to Bio::Sequence adapter module.
# It is internally used in Bio::SangerChromatogram#to_biosequence.
#
module Bio::Sequence::Adapter::SangerChromatogram

  extend Bio::Sequence::Adapter

  private

  def_biosequence_adapter :seq

  # primary accession
  def_biosequence_adapter :primary_accession do |orig|
    orig.version
  end

end #module Bio::Sequence::Adapter::SangerChromatogram

