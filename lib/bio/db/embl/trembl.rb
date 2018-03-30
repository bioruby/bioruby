#
# = bio/db/embl/trembl.rb - (deprecated) TrEMBL database class
# 
# Copyright::  Copyright (C) 2013 BioRuby Project
# License::    The Ruby License
#

warn "Bio::TrEMBL is deprecated. Use Bio::UniProtKB."

module Bio

require 'bio/db/embl/uniprotkb' unless const_defined?(:UniProtKB)

# Bio::TrEMBL is deprecated. Use Bio::UniProtKB.
class TrEMBL < UniProtKB

  # Bio::TrEMBL is deprecated. Use Bio::UniProtKB.
  def initialize(str)
    warn "Bio::TrEMBL is deprecated. Use Bio::UniProtKB."
    super(str)
  end
end

end
