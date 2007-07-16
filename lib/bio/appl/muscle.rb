#
# = bio/appl/muscle.rb - MUSCLE application wrapper class
#
# Copyright:: Copyright (C) 2006-2007
#             Jeffrey Blakeslee and John Conery University of Oregon <jeffb@uoregon.edu>
#             Naohisa Goto <ng@bioruby.org>
# License::   The Ruby License
#
#  $Id: muscle.rb,v 1.1 2007/07/16 12:25:50 ngoto Exp $
#
#
# Bio::Muscle is a wrapper class to execute MUSCLE.
#
# == References
#
# * http://www.drive5.com/muscle/
# * Edgar R.C.
#   MUSCLE: multiple sequence alignment with high accuracy and
#   high throughput. Nucleic Acids Res. 32: 1792-1797, 2004.
# * Edgar, R.C.
#   MUSCLE: a multiple sequence alignment method with reduced time
#   and space complexity. BMC Bioinformatics 5: 113, 2004.
#

module Bio

  # Bio::Muscle is a wrapper class to execute MUSCLE.
  #
  # Please refer documents in bio/apple/muscle.rb for references.
  class Muscle < Bio::Alignment::FactoryTemplate::StdinInFileOut

    # default program name
    DEFAULT_PROGRAM = 'muscle'.freeze

    # default report parser
    DEFAULT_PARSER = Bio::Alignment::MultiFastaFormat

    private
    # generates options specifying input filename.
    # returns an array of string
    def _option_input_file(fn)
      [ '-in', fn ]
    end

    # generates options specifying output filename.
    # returns an array of string
    def _option_output_file(fn)
      [ '-out', fn ]
    end
  end #class Muscle

end #module Bio
