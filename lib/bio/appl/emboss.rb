#
# = bio/appl/emboss.rb - EMBOSS wrapper
# 
# Copyright::	Copyright (C) 2002, 2005
#		KATAYAMA Toshiaki <k@bioruby.org>
# License::	LGPL
#
# $Id: emboss.rb,v 1.3 2006/01/28 06:46:42 k Exp $
#
# == References
#
# * http://www.emboss.org
#
#--
#
#  This library is free software; you can redistribute it and/or
#  modify it under the terms of the GNU Lesser General Public
#  License as published by the Free Software Foundation; either
#  version 2 of the License, or (at your option) any later version.
#
#  This library is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
#  Lesser General Public License for more details.
#
#  You should have received a copy of the GNU Lesser General Public
#  License along with this library; if not, write to the Free Software
#  Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307  USA
#
#++
#

module Bio

autoload :Command, 'bio/command'

class EMBOSS

  extend Bio::Command::Tools

  def self.seqret(arg)
    str = self.retrieve('seqret', arg)
  end

  def self.entret(arg)
    str = self.retrieve('entret', arg)
  end

  def initialize(cmd_line)
    @cmd_line = cmd_line + ' -stdout -auto'
  end

  def exec
    begin
      @io = IO.popen(@cmd_line, "w+")
      @result = @io.read
      return @result
    ensure
      @io.close
    end
  end
  attr_reader :io, :result

  private

  def self.retrieve(cmd, arg)
    cmd = [ cmd, arg, '-auto', '-stdout' ]
    str = ''
    call_command_local(cmd) do |inn, out|
      inn.close_write
      str = out.read
    end
    return str
  end

end # EMBOSS

end # Bio

