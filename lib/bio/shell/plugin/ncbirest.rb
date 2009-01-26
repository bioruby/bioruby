#
# = bio/shell/plugin/ncbirest.rb - plugin for NCBI eUtils
#
# Copyright::   Copyright (C) 2009
#               Naohisa Goto <ng@bioruby.org>
# License::     The Ruby License
#
# $Id:$
#

module Bio::Shell

  private

  # NCBI eUtils EFetch service.
  # When two or more arguments are given, or multiple accession numbers
  # are given it acts the same as Bio::NCBI::REST.efetch.
  # Otherwise, assumes nucleotide or protein accessin is given, and
  # automatically tries several databases.
  def efetch(ids, *arg)
    if !arg.empty? or ids.kind_of?(Array) or /\,/ =~ ids then
      return Bio::NCBI::REST.efetch(ids, *arg)
    end

    rettype = 'gb'
    prot_dbs = [ 'protein' ]
    nucl_dbs = [ 'nuccore', 'nucleotide', 'nucgss', 'nucest' ]

    case ids
    when /\A[A-Z][A-Z][A-Z][0-9]+(\.[0-9]+)?\z/i,
      /\A[OPQ][A-Z0-9]+(\.[0-9]+)?\z/i
      # protein accession
      dbs = prot_dbs
    when /\A[0-9]+\z/, /\A[A-Z0-9]+\_[A-Z0-9]+\z/i
      # NCBI GI or UniProt accession (with fail-safe)
      dbs = prot_dbs + nucl_dbs
    else
      # nucleotide accession
      dbs = nucl_dbs
    end
    result = nil
    dbs.each do |db|
      hash = { 'db' => db, 'rettype' => 'gb' }
      result = Bio::NCBI::REST.efetch(ids, hash)
      break if result and !result.empty?
    end
    result
  end

  # NCBI eUtils EInfo
  def einfo
    Bio::NCBI::REST.einfo
  end

  # NCBI eUtils ESearch
  def esearch(str, *arg)
    Bio::NCBI::REST.esearch(str, *arg)
  end

  # Same as Bio::NCBI::REST.esearch_count
  def esearch_count(str, *arg)
    Bio::NCBI::REST.esearch_count(str, *arg)
  end

end

