#
# = bio/db/genbank/ddbj.rb - DDBJ database class
#
# Copyright::  Copyright (C) 2000-2004 Toshiaki Katayama <k@bioruby.org>
# License::    The Ruby License
#

warn "Bio::DDBJ is deprecated. Use Bio::GenBank."

module Bio

require 'bio/db/genbank/genbank' unless const_defined?(:GenBank)

# Bio::DDBJ is deprecated. Use Bio::GenBank.
class DDBJ < GenBank

  # Bio::DDBJ is deprecated. Use Bio::GenBank.
  def initialize(str)
    warn "Bio::DDBJ is deprecated. Use Bio::GenBank."
    super(str)
  end

end # DDBJ

end # Bio
