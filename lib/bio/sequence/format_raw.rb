#
# = bio/sequence/format_raw.rb - Raw sequence formatter
#
# Copyright::  Copyright (C) 2008 Naohisa Goto <ng@bioruby.org>
# License::    The Ruby License
#

module Bio::Sequence::Format::Formatter

  # Raw sequence output formatter class
  class Raw < Bio::Sequence::Format::FormatterBase

    # output raw sequence data
    def output
      "#{@sequence.seq}"
    end
  end #class Raw

end #module Bio::Sequence::Format::Formatter
