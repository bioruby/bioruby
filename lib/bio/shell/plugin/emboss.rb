#
# = bio/shell/plugin/emboss.rb - methods to use EMBOSS
#
# Copyright::   Copyright (C) 2005
#               Toshiaki Katayama <k@bioruby.org>
# License::     The Ruby License
#
# $Id: emboss.rb,v 1.3 2007/04/05 23:35:41 trevor Exp $
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
