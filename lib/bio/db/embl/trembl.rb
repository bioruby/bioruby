#
# = bio/db/embl/trembl.rb - TrEMBL database class
# 
# Copyright::  Copyright (C) 2001, 2002 Toshiaki Katayama <k@bioruby.org>
# License::    Ruby's
#
# $Id: trembl.rb,v 1.6 2006/09/19 06:01:48 k Exp $
#

require 'bio/db/embl/sptr'

module Bio

# == Description
#
# Parser class for TrEMBL database entry. See also Bio::SPTR class.
# This class holds name space for TrEMBL specific methods.
#
# UniProtKB/SwissProt specific methods are defined in this class. 
# Shared methods for UniProtKB/SwissProt and TrEMBL classes are 
# defined in Bio::SPTR class.
#
# == Examples
#
#   str = File.read("Q2UNG2_ASPOR.trembl")
#   obj = Bio::TrEMBL.new(str)
#   obj.entry_id #=> "Q2UNG2_ASPOR"
#
# == Referencees
#
# * TrEMBL Computer-annotated supplement to Swiss-Prot	
#   http://au.expasy.org/sprot/
#
# * TrEMBL Computer-annotated supplement to Swiss-Prot User Manual
#   http://au.expasy.org/sprot/userman.html
# 
class TrEMBL < SPTR
  # Nothing to do (TrEMBL format is abstracted in SPTR)
end

end
