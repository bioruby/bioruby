#
# = bio/db/embl/uniprot.rb - UniProt database class
# 
# Copyright::  Copyright (C) 2005 Toshiaki Katayama <k@bioruby.org>
# License::    Ruby's
#
#  $Id: uniprot.rb,v 1.4 2006/09/19 06:01:48 k Exp $
#

require 'bio/db/embl/sptr'

module Bio

# == Description
# 
# Parser class for SwissProt database entry.# See also Bio::SPTR class.
# This class holds name space for UniProtKB/SwissProt specific methods.
#
# UniProtKB/SwissProt specific methods are defined in this class. 
# Shared methods for UniProtKB/SwissProt and TrEMBL classes are 
# defined in Bio::SPTR class.
#
# == Examples
#
#   str = File.read("p53_human.swiss")
#   obj = Bio::UniProt.new(str)
#   obj.entry_id #=> "P53_HUMAN"
#
# == Referencees
#
# * UniProt
#   http://uniprot.org/
#
# * The UniProtKB/SwissProt/TrEMBL User Manual
#   http://www.expasy.org/sprot/userman.html
#
class UniProt < SPTR
  # Nothing to do (UniProt format is abstracted in SPTR)
end

end

