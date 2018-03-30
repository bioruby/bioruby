#
# = bio/db/embl/swissprot.rb - (deprecated) SwissProt database class
# 
# Copyright::   Copyright (C) 2013 BioRuby Project
# License::     The Ruby License
#

warn "Bio::SwissProt is deprecated. Use Bio::UniProtKB."

module Bio

require 'bio/db/embl/uniprotkb' unless const_defined?(:UniProtKB)

# Bio::SwissProt is deprecated. Use Bio::UniProtKB.
class SwissProt < SPTR

  # Bio::SwissProt is deprecated. Use Bio::UniProtKB.
  def initialize(str)
    warn "Bio::SwissProt is deprecated. Use Bio::UniProtKB."
    super(str)
  end
end

end

