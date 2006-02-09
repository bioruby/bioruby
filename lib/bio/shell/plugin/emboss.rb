#
# = bio/shell/plugin/emboss.rb - methods to use EMBOSS
#
# Copyright::   Copyright (C) 2005
#               Toshiaki Katayama <k@bioruby.org>
# License::     Ruby's
#
# $Id: emboss.rb,v 1.2 2006/02/09 20:48:53 k Exp $
#

module Bio::Shell

  private

  def seqret(usa)
    Bio::EMBOSS.seqret(usa)
  end

  def entret(usa)
    Bio::EMBOSS.entret(usa)
  end

end
