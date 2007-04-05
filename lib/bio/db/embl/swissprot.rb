#
# = bio/db/embl/swissprot.rb - SwissProt database class
# 
# Copyright::   Copyright (C) 2001, 2002 Toshiaki Katayama <k@bioruby.org>
# License::     The Ruby License
#
#  $Id: swissprot.rb,v 1.7 2007/04/05 23:35:40 trevor Exp $
#

require 'bio/db/embl/sptr'

module Bio

# == Description
# 
# Parser class for SwissProt database entry. See also Bio::SPTR class.
# This class holds name space for SwissProt specific methods.
#
# SwissProt (before UniProtKB/SwissProt) specific methods are defined in 
# this class. Shared methods for UniProtKB/SwissProt and TrEMBL classes 
# are defined in Bio::SPTR class.
#
# == Examples
#
#   str = File.read("p53_human.swiss")
#   obj = Bio::SwissProt.new(str)
#   obj.entry_id #=> "P53_HUMAN"
#
# == Referencees
#
# * Swiss-Prot Protein knowledgebase
#   http://au.expasy.org/sprot/
#
# * Swiss-Prot Protein Knowledgebase User Manual
#   http://au.expasy.org/sprot/userman.html
# 
class SwissProt < SPTR
  # Nothing to do (SwissProt format is abstracted in SPTR)
end

end

