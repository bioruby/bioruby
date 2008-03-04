#
# = bio/sequence/format_raw.rb - Raw sequence formatter
#
# Copyright::  Copyright (C) 2008 Naohisa Goto <ng@bioruby.org>
# License::    The Ruby License
#
# $Id: format_raw.rb,v 1.1.2.1 2008/03/04 11:28:46 ngoto Exp $
#

require 'bio/sequence/format'

module Bio::Sequence::Format::Formatter

  # Raw sequence output formatter class
  class Raw < Bio::Sequence::Format::FormatterBase

    # output raw sequence data
    def output
      "#{@sequence.seq}"
    end
  end #class Raw

end #module Bio::Sequence::Format::Formatter
