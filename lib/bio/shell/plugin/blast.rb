#
# = bio/shell/plugin/blast.rb - plugin for BLAST services
#
# Copyright::   Copyright (C) 2006
#               Toshiaki Katayama <k@bioruby.org>
# License::     The Ruby License
#
# $Id: blast.rb,v 1.3 2007/04/05 23:35:41 trevor Exp $
#

module Bio::Shell

  private

  # GenomeNet

  def keggblast(query)
    server = Bio::Blast.remote("blastp", "genes", "", "genomenet_tab")

    if query[/^>/]
      data = Bio::FastaFormat.new(query)
      desc = data.definition
      tmp = getseq(data.seq)
    else
      desc = "query"
      tmp = getseq(query)
    end
    
    if tmp.respond_to?(:translate)
      aaseq = tmp.translate
    else
      aaseq = tmp
    end

    fasta = aaseq.to_fasta(desc, 60)
    result = server.query(fasta)
    puts server.output
    return result
  end

end

