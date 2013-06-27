#
# = bio/db/genbank/refseq.rb - RefSeq database class
#
# Copyright::  Copyright (C) 2000-2004 Toshiaki Katayama <k@bioruby.org>
# License::    The Ruby License
#
#

warn "Bio::RefSeq is deprecated. Use Bio::GenBank."

module Bio

require 'bio/db/genbank/genbank' unless const_defined?(:GenBank)

# Bio::RefSeq is deprecated. Use Bio::GenBank.
class RefSeq < GenBank

  # Bio::RefSeq is deprecated. Use Bio::GenBank.
  def initialize(str)
    warn "Bio::RefSeq is deprecated. Use Bio::GenBank."
    super(str)
  end

end

end # Bio
