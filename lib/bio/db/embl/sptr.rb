#
# = bio/db/embl/sptr.rb - Bio::SPTR is an alias of Bio::UniProtKB
# 
# Copyright::   Copyright (C) 2013 BioRuby Project
# License::     The Ruby License
#

warn "Bio::SPTR is changed to an alias of Bio::UniProtKB. Please use Bio::UniProtKB. Bio::SPTR may be deprecated in the future." if $VERBOSE

module Bio

  require "bio/db/embl/uniprotkb" unless const_defined?(:UniProtKB)

  # Bio::SPTR is changed to an alias of Bio::UniProtKB.
  # Please use Bio::UniProtKB.
  # Bio::SPTR may be deprecated in the future.
  SPTR = UniProtKB

end #module Bio

