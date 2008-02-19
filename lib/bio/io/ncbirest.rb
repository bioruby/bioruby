#
# = bio/io/ncbirest.rb - NCBI Entrez client module
#
# Copyright::  Copyright (C) 2008 Toshiaki Katayama <k@bioruby.org>
# License::    The Ruby License
#
# $Id: ncbirest.rb,v 1.2 2008/02/19 04:49:35 k Exp $
#

require 'bio/command'

module Bio

# == Description
#
# The Bio::NCBI::REST class provides REST client for the NCBI E-Utilities
#
# Entrez utilities index:
#
# * http://www.ncbi.nlm.nih.gov/entrez/utils/utils_index.html
#
# == Usage
#
#  Bio::NCBI::REST.esearch("tardigrada", {"db"=>"nuccore", "rettype"=>"count"})
#  Bio::NCBI::REST.esearch("tardigrada", {"db"=>"nuccore", "rettype"=>"gb"})
#  Bio::NCBI::REST.esearch("yeast kinase", {"db"=>"nuccore", "rettype"=>"gb", "retmode"=>"xml", "retmax"=>5})
#  Bio::NCBI::REST.efetch("185041", {"db"=>"nuccore", "rettype"=>"gb"})
#  Bio::NCBI::REST.efetch("J00231", {"db"=>"nuccore", "rettype"=>"gb", "retmode"=>"xml"})
#  
class NCBI
class REST

  # Run retrieval scripts on weekends or between 9 pm and 5 am Eastern Time
  # weekdays for any series of more than 100 requests.
  # -> Not implemented yet in BioRuby

  # Make no more than one request every 3 seconds.
  NCBI_INTERVAL = 3
  @@last_access = nil

  private

  def ncbi_access_wait(wait = NCBI_INTERVAL)
    if @@last_access
      duration = Time.now - @@last_access
      if wait > duration
        sleep wait - duration
      end
    end
    @@last_access = Time.now
  end

  public

  # Search the NCBI database by given keywords using E-Utils and returns 
  # an array of entry IDs.
  # 
  # For information on the possible arguments, see
  #
  # * http://eutils.ncbi.nlm.nih.gov/entrez/query/static/esearch_help.html
  #
  # ---
  # *Arguments*:
  # * _str_: query string (required)
  # * _hash_: hash of E-Utils option {"db" => "nuccore", "rettype" => "gb"}
  #   * _db_: "nuccore", "nucleotide", "protein", "pubmed", ...
  #   * _retmode_: "text", "xml", "html", ...
  #   * _rettype_: "gb", "medline", "count", ...
  #   * _retmax_: integer (default 100)
  #   * _retstart_: integer
  #   * _field_
  #   * _reldate_
  #   * _mindate_
  #   * _maxdate_
  #   * _datetype_
  # *Returns*:: array of entry IDs or a number of results
  def esearch(str, hash = {})
    return nil if str.empty?

    serv = "http://eutils.ncbi.nlm.nih.gov/entrez/eutils/esearch.fcgi"
    opts = {
      "retmax" => 100,
      "tool"   => "bioruby",
      "term"   => str
    }
    opts.update(hash)

    ncbi_access_wait

    response, = Bio::Command.post_form(serv, opts)
    result = response.body
    if opts['rettype'] == 'count'
      result = result.scan(/<Count>(.*?)<\/Count>/m).flatten.first.to_i
    else
      result = result.scan(/<Id>(.*?)<\/Id>/m).flatten
    end
    return result
  end

  # Retrieve a database entry by given ID and using E-Utils (efetch) and
  # returns an array of entry string. Multiple IDs can be supplied.
  #
  # For information on the possible arguments, see
  #
  # * http://eutils.ncbi.nlm.nih.gov/entrez/query/static/efetch_help.html
  #
  # ---
  # *Arguments*:
  # * _ids_: list of NCBI entry IDs (required)
  # * _hash_: hash of E-Utils option {"db" => "nuccore", "rettype" => "gb"}
  #   * _db_: "nuccore", "nucleotide", "protein", "pubmed", ...
  #   * _retmode_: "text", "xml", "html", ...
  #   * _rettype_: "gb", "medline", "count",...
  #   * _retmax_: integer (default 100)
  #   * _retstart_: integer
  #   * _field_
  #   * _reldate_
  #   * _mindate_
  #   * _maxdate_
  #   * _datetype_
  # *Returns*:: Array of entry String
  def efetch(ids, hash = {})
    return nil if ids.to_s.empty?
    ids = ids.join(",") if ids === Array

    serv = "http://eutils.ncbi.nlm.nih.gov/entrez/eutils/efetch.fcgi"
    opts = {
      "tool"     => "bioruby",
      "retmode"  => "text",
      "id"       => ids,
    }
    opts.update(hash)

    ncbi_access_wait

    response, = Bio::Command.post_form(serv, opts)
    result = response.body
    if opts["retmode"] == "text"
      result = result.split(/\n\n+/)
    end
    return result
  end

  def self.esearch(*args)
    self.new.esearch(*args)
  end

  def self.efetch(*args)
    self.new.efetch(*args)
  end

end # REST
end # NCBI
end # Bio


if __FILE__ == $0

  gbopts = {"db"=>"nuccore", "rettype"=>"gb"}
  pmopts = {"db"=>"pubmed", "rettype"=>"medline"}
  count = {"rettype" => "count"}
  xml = {"retmode"=>"xml"}
  max = {"retmax"=>5}

  puts "=== class methods ==="

  puts "--- Search NCBI by E-Utils ---"

  puts Time.now
  puts "# count of 'tardigrada' in nuccore"
  puts Bio::NCBI::REST.esearch("tardigrada", gbopts.merge(count))

  puts Time.now
  puts "# max 5 'tardigrada' entries in nuccore"
  puts Bio::NCBI::REST.esearch("tardigrada", gbopts.merge(max))

  puts Time.now
  puts "# count of 'yeast kinase' in nuccore"
  puts Bio::NCBI::REST.esearch("yeast kinase", gbopts.merge(count))

  puts Time.now
  puts "# max 5 'yeast kinase' entries in nuccore (XML)"
  puts Bio::NCBI::REST.esearch("yeast kinase", gbopts.merge(xml).merge(max))

  puts Time.now
  puts "# count of 'genome&analysis|bioinformatics' in pubmed"
  puts Bio::NCBI::REST.esearch("(genome AND analysis) OR bioinformatics", pmopts.merge(count))

  puts Time.now
  puts "# max 5 'genome&analysis|bioinformatics' entries in pubmed (XML)"
  puts Bio::NCBI::REST.esearch("(genome AND analysis) OR bioinformatics", pmopts.merge(xml).merge(max))

  puts Time.now
  Bio::NCBI::REST.esearch("(genome AND analysis) OR bioinformatics", pmopts.merge(max)).each do |x|
    puts "# each of 5 'genome&analysis|bioinformatics' entries in pubmed"
    puts x
  end

  puts "--- Retrieve NCBI entry by E-Utils ---"

  puts Time.now
  puts "# '185041' entry in nuccore"
  puts Bio::NCBI::REST.efetch("185041", gbopts)

  puts Time.now
  puts "# 'J00231' entry in nuccore (XML)"
  puts Bio::NCBI::REST.efetch("J00231", gbopts.merge(xml))

  puts Time.now
  puts "# 16381885 entry in pubmed"
  puts Bio::NCBI::REST.efetch(16381885, pmopts)

  puts Time.now
  puts "# '16381885' entry in pubmed"
  puts Bio::NCBI::REST.efetch("16381885", pmopts)

  puts Time.now
  puts "# [10592173,14693808] entries in pubmed"
  puts Bio::NCBI::REST.efetch([10592173, 14693808], pmopts)

  puts Time.now
  puts "# [10592173,14693808] entries in pubmed (XML)"
  puts Bio::NCBI::REST.efetch([10592173, 14693808], pmopts.merge(xml))


  puts "=== instance methods ==="

  ncbi = Bio::NCBI::REST.new

  puts "--- Search NCBI by E-Utils ---"

  puts Time.now
  puts "# count of 'genome&analysis|bioinformatics' in pubmed"
  puts ncbi.esearch("(genome AND analysis) OR bioinformatics", pmopts.merge(count))

  puts Time.now
  puts "# max 5 'genome&analysis|bioinformatics' entries in pubmed"
  puts ncbi.esearch("(genome AND analysis) OR bioinformatics", pmopts.merge(max))

  puts Time.now
  ncbi.esearch("(genome AND analysis) OR bioinformatics", pmopts).each do |x|
    puts "# each 'genome&analysis|bioinformatics' entries in pubmed"
    puts x
  end

  puts "--- Retrieve NCBI entry by E-Utils ---"

  puts Time.now
  puts "# 16381885 entry in pubmed"
  puts ncbi.efetch(16381885, pmopts)

  puts Time.now
  puts "# [10592173,14693808] entries in pubmed"
  puts ncbi.efetch([10592173, 14693808], pmopts)

end
