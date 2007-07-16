#
# = bio/appl/probcons.rb - ProbCons application wrapper class
#
# Copyright:: Copyright (C) 2006-2007
#             Jeffrey Blakeslee and John Conery University of Oregon <jeffb@uoregon.edu>
#             Naohisa Goto <ng@bioruby.org>
# License::   The Ruby License
#
#  $Id: probcons.rb,v 1.1 2007/07/16 12:25:50 ngoto Exp $
#
# Bio::Probcons is a wrapper class to execute ProbCons
# (Probabilistic Consistency-based Multiple Alignment
# of Amino Acid Sequences).
#
# == References
# 
# * http://probcons.stanford.edu/
# * Do, C.B., Mahabhashyam, M.S.P., Brudno, M., and Batzoglou, S.
#   ProbCons: Probabilistic Consistency-based Multiple Sequence Alignment.
#   Genome Research 15: 330-340, 2005.
#


module Bio

  # Bio::Probcons is a wrapper class to execute PROBCONS
  # (Probabilistic Consistency-based Multiple Alignment
  # of Amino Acid Sequences).
  #
  # Please refer documents in bio/apple/probcons.rb for references.
  class Probcons < Bio::Alignment::FactoryTemplate::FileInStdoutOut

    # default program name
    DEFAULT_PROGRAM = 'probcons'.freeze

    # default report parser
    DEFAULT_PARSER = Bio::Alignment::MultiFastaFormat

  end #class Probcons

end #module Bio
