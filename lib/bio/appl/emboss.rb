#
# bio/appl/emboss.rb - EMBOSS wrapper
# 
#   Copyright (C) 2002 KATAYAMA Toshiaki <k@bioruby.org>
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
#  $Id: emboss.rb,v 1.1 2002/08/19 02:49:29 k Exp $
#

module Bio

  class EMBOSS

    def initialize(cmd_line)
      @cmd_line = cmd_line + ' -stdout'
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

  end

end

=begin

= Bio::EMBOSS

EMBOSS wrapper.

  #!/usr/bin/env ruby
  require 'bio'

  emboss = Bio::EMBOSS.new("getorf -sequence ~/xlrhodop -outseq stdout")
  puts emboss.exec

--- Bio::EMBOSS.new(command_line)

--- Bio::EMBOSS#exec
--- Bio::EMBOSS#io
--- Bio::EMBOSS#result

=== SEE ALSO

* http://www.emboss.org

=end
