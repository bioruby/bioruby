#
# = bio/db/embl/uniprot.rb - UniProt database class
# 
# Copyright::  Copyright (C) 2013 BioRuby Project
# License::    The Ruby License
#
#

warn "Bio::UniProt is an alias of Bio::UniProtKB. Please use Bio::UniProtKB. Bio::UniProt may be deprecated in the future." if $VERBOSE

module Bio

require 'bio/db/embl/uniprotkb' unless const_defined?(:UniProtKB)

  # Bio::UniProt is changed to an alias of Bio::UniProtKB.
  # Please use Bio::UniProtKB.
  # Bio::UniProt may be deprecated in the future.
  #
  # Note that Bio::SPTR have been renamed to Bio::UniProtKB and
  # is also an alias of Bio::UniProtKB.
  #
  UniProt = UniProtKB

end

