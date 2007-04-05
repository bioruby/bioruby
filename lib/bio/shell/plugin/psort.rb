#
# = bio/shell/plugin/psort.rb - plugin for PSORT
#
# Copyright::   Copyright (C) 2006
#               Toshiaki Katayama <k@bioruby.org>
# License::     The Ruby License
#
# $Id: psort.rb,v 1.3 2007/04/05 23:35:41 trevor Exp $
#

module Bio::Shell

  private

  def psort1(str)
    seq = getseq(str)
    if seq.is_a?(Bio::Sequence::NA)
      seq = seq.translate
    end

    psort = Bio::PSORT::PSORT1.imsut
    fasta = seq.to_fasta

    results = psort.exec(fasta).final_result
    results.each do |result|
      puts "#{result["certainty"].to_f*100.0}\t#{result["prediction"]}"
    end
    return results.first["prediction"]
  end

  def psort2(str)
    seq = getseq(str)
    if seq.is_a?(Bio::Sequence::NA)
      seq = seq.translate
    end

    psort = Bio::PSORT::PSORT2.imsut
    fasta = seq.to_fasta

    results = psort.exec(fasta).prob.sort_by{|x, y| y}.reverse
    results.each do |loc, prob|
      next if prob <= 0.0
      puts "#{prob}\t#{Bio::PSORT::PSORT2::SclNames[loc]}"
    end
    return results.first.first
  end

  def psort2locations
    names = Bio::PSORT::PSORT2::SclNames
    names.sort.each do |loc, desc|
      puts "#{loc}\t#{desc}"
    end
    return names
  end
end

