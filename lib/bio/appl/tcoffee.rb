#
# = bio/appl/tcoffee.rb - T-Coffee application wrapper class
#
# Copyright:: Copyright (C) 2006-2007
#             Jeffrey Blakeslee and John Conery University of Oregon <jeffb@uoregon.edu>
#             Naohisa Goto <ng@bioruby.org>
# License::   The Ruby License
#
#  $Id: tcoffee.rb,v 1.1 2007/07/16 12:25:50 ngoto Exp $
#
# Bio::Tcoffee is a wrapper class to execute T-Coffee.
#
# == References
#
# * http://www.tcoffee.org/Projects_home_page/t_coffee_home_page.html
# * Notredame, C., Higgins, D.G. and Heringa, J.
#   T-Coffee: A novel method for fast and accurate multiple sequence
#   alignment. J. Mol. Biol. 302: 205-217, 2000.
#


module Bio

  # Bio::Tcoffee is a wrapper class to execute t-coffee.
  #
  # Please refer documents in bio/apple/tcoffee.rb for references.
  class Tcoffee < Bio::Alignment::FactoryTemplate::FileInFileOutWithTree

    # default program name
    DEFAULT_PROGRAM = 't_coffee'.freeze

    # default report parser
    DEFAULT_PARSER = Bio::ClustalW::Report

    private
    # generates options specifying input filename.
    # returns an array of string
    def _option_input_file(fn)
      [ '-infile', fn ]
    end

    # generates options specifying output filename.
    # returns an array of string
    def _option_output_file(fn)
      [ '-outfile', fn ]
    end

    # generates options specifying output filename.
    # returns an array of string
    def _option_output_dndfile(fn)
      [ '-newtree', fn ]
    end
  end #class TCoffee

end #module Bio
