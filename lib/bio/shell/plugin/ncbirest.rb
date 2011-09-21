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
  #
  # With 1 argument, it gets sequence(s) by using
  # Bio::NCBI::REST::EFetch.sequence.
  # Nucleotide or protein database is automatically selected for each id.
  #
  # Example:
  #   efetch('AF237819')
  # 
  # With two or more arguments, and when the 2nd argument is Symbol,
  # it calls the corresponding Bio::NCBI::REST::EFetch class method.
  #
  # Example:
  #   efetch('13054692', :pubmed)
  #   # the same as Bio::NCBI::REST::EFetch.pubmed('13054692')
  #
  # Otherwise, it acts the same as Bio::NCBI::REST.efetch.
  def efetch(ids, *arg)
    if arg.empty? then
      ret = Bio::NCBI::REST::EFetch.nucleotide(ids)
      unless /^LOCUS       / =~ ret.to_s then
        ret = Bio::NCBI::REST::EFetch.protein(ids)
      end
      ret
    elsif arg[0].kind_of?(Symbol)
      meth = arg[0]
      case meth.to_s
      when /\A(journal|omim|pmc|pubmed|sequence|taxonomy)\z/
        Bio::NCBI::REST::EFetch.__send__(meth, ids, *(arg[1..-1]))
      else
        nil
      end
    else
      Bio::NCBI::REST.efetch(ids, *arg)
    end
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

