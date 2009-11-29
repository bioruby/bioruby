#
# = sample/demo_gff1.rb - very simple demonstration of Bio::GFF
#
# Copyright::  Copyright (C) 2003, 2005
#              Toshiaki Katayama <k@bioruby.org>
#              2006  Jan Aerts <jan.aerts@bbsrc.ac.uk>
#              2008  Naohisa Goto <ng@bioruby.org>
# License::    The Ruby License
#
#
# == Description
#
# Very simple demonstration of Bio::GFF, parser classes for GFF formatted
# text.
#
# == Usage
#
# Simply run this script.
#
#  $ ruby demo_gff1.rb
#
# == To do
#
# Bio::GFF and related classes have many functions, and we should write
# more example and/or demonstration codes.
#
# == Development information
#
# The code was moved from lib/bio/db/gff.rb.
#

require 'bio'

#if __FILE__ == $0
  begin
    require 'pp'
    alias p pp
  rescue LoadError
  end

  this_gff =  "SEQ1\tEMBL\tatg\t103\t105\t.\t+\t0\n"
  this_gff << "SEQ1\tEMBL\texon\t103\t172\t.\t+\t0\n"
  this_gff << "SEQ1\tEMBL\tsplice5\t172\t173\t.\t+\t.\n"
  this_gff << "SEQ1\tnetgene\tsplice5\t172\t173\t0.94\t+\t.\n"
  this_gff << "SEQ1\tgenie\tsp5-20\t163\t182\t2.3\t+\t.\n"
  this_gff << "SEQ1\tgenie\tsp5-10\t168\t177\t2.1\t+\t.\n"
  this_gff << "SEQ1\tgrail\tATG\t17\t19\t2.1\t-\t0\n"
  p Bio::GFF.new(this_gff)
#end
