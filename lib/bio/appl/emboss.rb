#
# = bio/appl/emboss.rb - EMBOSS wrapper
# 
# Copyright::	Copyright (C) 2002, 2005
#		KATAYAMA Toshiaki <k@bioruby.org>
# License::	Ruby's
#
# $Id: emboss.rb,v 1.4 2006/02/27 09:14:30 k Exp $
#
# == References
#
# * http://www.emboss.org
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

