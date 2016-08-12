#
# = bio/io/ncbirest.rb - NCBI Entrez client module
#
# Copyright::  Copyright (C) 2008 Toshiaki Katayama <k@bioruby.org>
# License::    The Ruby License
#
# $Id:$
#

require 'thread'
require 'bio/command'
require 'bio/version'

module Bio

class NCBI


  # (Hash) Default parameters for Entrez (eUtils).
  # They may also be used for other NCBI services.
  ENTREZ_DEFAULT_PARAMETERS = {
    # Cited from
    # https://www.ncbi.nlm.nih.gov/books/NBK25499/#chapter4.Release_Notes
    #  tool:
    #  Name of application making the E-utility call.
    #  Value must be a string with no internal spaces.
    'tool' => "bioruby",
    # Cited from
    # https://www.ncbi.nlm.nih.gov/books/NBK25497/
    # The value of email should be a complete and valid e-mail address
    # of the software developer and not that of a third-party end user.
    'email' => 'staff@bioruby.org',
  }

  # Resets Entrez (eUtils) default parameters.
  # ---
  # *Returns*:: (Hash) default parameters
  def self.reset_entrez_default_parameters
    h = {
      'tool'  => "bioruby",
      'email' => 'staff@bioruby.org',
    }
    ENTREZ_DEFAULT_PARAMETERS.clear
    ENTREZ_DEFAULT_PARAMETERS.update(h)
  end

  # Gets default email address for Entrez (eUtils).
  # ---
  # *Returns*:: String or nil
  def self.default_email
    ENTREZ_DEFAULT_PARAMETERS['email']
  end

  # Sets default email address used for Entrez (eUtils).
  # It may also be used for other NCBI services.
  #
  # In https://www.ncbi.nlm.nih.gov/books/NBK25497/ 
  # NCBI says:
  # "The value of email should be a complete and valid e-mail address of
  # the software developer and not that of a third-party end user."
  #
  # By default, email address of BioRuby staffs is set.
  #
  # From the above NCBI documentation, the tool and email value is used
  # only for unblocking IP addresses blocked by NCBI due to excess requests.
  # For the purpose, NCBI says:
  # "Please be aware that merely providing values for tool and email
  # in requests is not sufficient to comply with this policy;
  # these values must be registered with NCBI."
  #
  # Please use your own email address and tool name when registering
  # tool and email values to NCBI.
  #
  # ---
  # *Arguments*:
  # * (required) _str_: (String) email address
  # *Returns*:: same as given argument
  def self.default_email=(str)
    ENTREZ_DEFAULT_PARAMETERS['email'] = str
  end

  # Gets default tool name for Entrez (eUtils).
  # ---
  # *Returns*:: String or nil
  def self.default_tool
    ENTREZ_DEFAULT_PARAMETERS['tool']
  end

  # Sets default tool name for Entrez (eUtils).
  # It may also be used for other NCBI services.
  #
  # In https://www.ncbi.nlm.nih.gov/books/NBK25497/ 
  # NCBI says:
  # "The value of tool should be a string with no internal spaces that
  # uniquely identifies the software producing the request."
  #
  # "bioruby" is set by default.
  # Please use your own tool name when registering to NCBI.
  #
  # See the document of default_email= for more information.
  #
  # ---
  # *Arguments*:
  # * (required) _str_: (String) tool name
  # *Returns*:: same as given argument
  def self.default_tool=(str)
    ENTREZ_DEFAULT_PARAMETERS['tool'] = str
  end

# == Description
#
# The Bio::NCBI::REST class provides REST client for the NCBI E-Utilities
#
# Entrez Programming Utilities Help:
#
# * https://www.ncbi.nlm.nih.gov/books/NBK25501/
# * ( redirected from http://www.ncbi.nlm.nih.gov/entrez/utils/ )
#
class REST

  # Run retrieval scripts on weekends or between 9 pm and 5 am Eastern Time
  # weekdays for any series of more than 100 requests.
  # -> Not implemented yet in BioRuby
  #
  # Wait for 1/3 seconds.
  # NCBI's restriction is: "Make no more than 3 requests every 1 second.".
  NCBI_INTERVAL = 1.0 / 3.0
  @@last_access = nil
  @@last_access_mutex = nil

  private

  # (Private) Sleeps until allowed to access.
  # ---
  # *Arguments*:
  # * (required) _wait_: wait unit time
  # *Returns*:: (undefined)
  def ncbi_access_wait(wait = NCBI_INTERVAL)
    @@last_access_mutex ||= Mutex.new
    @@last_access_mutex.synchronize {
      if @@last_access
        duration = Time.now - @@last_access
        if wait > duration
          sleep wait - duration
        end
      end
      @@last_access = Time.now
    }
    nil
  end

  # (Private) default parameters
  # ---
  # *Returns*:: Hash
  def default_parameters
    Bio::NCBI::ENTREZ_DEFAULT_PARAMETERS
  end

  # (Private) Sends query to NCBI.
  # ---
  # *Arguments*:
  # * (required) _serv_: (String) server URI string
  # * (required) _opts_: (Hash) parameters
  # *Returns*:: nil
  def ncbi_post_form(serv, opts)
    ncbi_check_parameters(opts)
    ncbi_access_wait
    #$stderr.puts opts.inspect
    response = Bio::Command.post_form(serv, opts)
    response
  end

  # (Private) Checks parameters as NCBI requires.
  # If no email or tool parameter, raises an error.
  #
  # NCBI announces that "Effective on
  # June 1, 2010, all E-utility requests, either using standard URLs or
  # SOAP, must contain non-null values for both the &tool and &email
  # parameters. Any E-utility request made after June 1, 2010 that does
  # not contain values for both parameters will return an error explaining
  # that these parameters must be included in E-utility requests."
  # ---
  # *Arguments*:
  # * (required) _opts_: Hash containing parameters
  # *Returns*:: (undefined)
  def ncbi_check_parameters(opts)
    #return if Time.now < Time.gm(2010,5,31)
    if opts['email'].to_s.empty? then
      raise 'Set email parameter for the query, or set Bio::NCBI.default_email = "(email address of the author of this software)"'
    end
    if opts['tool'].to_s.empty? then
      raise 'Set tool parameter for the query, or set Bio::NCBI.default_tool = "(your tool name)"'
    end
    nil
  end

  public

  # List the NCBI database names E-Utils (einfo) service
  # 
  # * https://eutils.ncbi.nlm.nih.gov/entrez/eutils/einfo.fcgi
  #
  #  pubmed protein nucleotide nuccore nucgss nucest structure genome
  #  books cancerchromosomes cdd gap domains gene genomeprj gensat geo
  #  gds homologene journals mesh ncbisearch nlmcatalog omia omim pmc
  #  popset probe proteinclusters pcassay pccompound pcsubstance snp
  #  taxonomy toolkit unigene unists
  #
  # == Usage
  #
  #  ncbi = Bio::NCBI::REST.new
  #  ncbi.einfo
  #
  #  Bio::NCBI::REST.einfo
  #
  # ---
  # *Returns*:: array of string (database names)
  def einfo
    serv = "https://eutils.ncbi.nlm.nih.gov/entrez/eutils/einfo.fcgi"
    opts = default_parameters.merge({})
    response = ncbi_post_form(serv, opts)
    result = response.body
    list = result.scan(/<DbName>(.*?)<\/DbName>/m).flatten
    return list
  end


  # Search the NCBI database by given keywords using E-Utils (esearch) service
  # and returns an array of entry IDs.
  # 
  # For information on the possible arguments, see
  #
  # * https://www.ncbi.nlm.nih.gov/books/NBK25499/#chapter4.ESearch
  # * ( redirected from http://eutils.ncbi.nlm.nih.gov/books/n/helpeutils/chapter4/#chapter4.ESearch )
  # * ( redirected from http://eutils.ncbi.nlm.nih.gov/entrez/query/static/esearch_help.html )
  #
  # == Usage
  #
  #  ncbi = Bio::NCBI::REST.new
  #  ncbi.esearch("tardigrada", {"db"=>"nucleotide", "rettype"=>"count"})
  #  ncbi.esearch("tardigrada", {"db"=>"nucleotide", "rettype"=>"gb"})
  #  ncbi.esearch("yeast kinase", {"db"=>"nuccore", "rettype"=>"gb", "retmax"=>5})
  #
  #  Bio::NCBI::REST.esearch("tardigrada", {"db"=>"nucleotide", "rettype"=>"count"})
  #  Bio::NCBI::REST.esearch("tardigrada", {"db"=>"nucleotide", "rettype"=>"gb"})
  #  Bio::NCBI::REST.esearch("yeast kinase", {"db"=>"nuccore", "rettype"=>"gb", "retmax"=>5})
  #
  # ---
  # *Arguments*:
  # * _str_: query string (required)
  # * _hash_: hash of E-Utils option {"db" => "nuccore", "rettype" => "gb"}
  #   * _db_: "sequences", "nucleotide", "protein", "pubmed", "taxonomy", ...
  #   * _retmode_: "text", "xml", "html", ...
  #   * _rettype_: "gb", "medline", "count", ...
  #   * _retmax_: integer (default 100)
  #   * _retstart_: integer
  #   * _field_:
  #     * "titl": Title [TI]
  #     * "tiab": Title/Abstract [TIAB]
  #     * "word": Text words [TW]
  #     * "auth": Author [AU]
  #     * "affl": Affiliation [AD]
  #     * "jour": Journal [TA]
  #     * "vol":  Volume [VI]
  #     * "iss":  Issue [IP]
  #     * "page": First page [PG]
  #     * "pdat": Publication date [DP]
  #     * "ptyp": Publication type [PT]
  #     * "lang": Language [LA]
  #     * "mesh": MeSH term [MH]
  #     * "majr": MeSH major topic [MAJR]
  #     * "subh": Mesh sub headings [SH]
  #     * "mhda": MeSH date [MHDA]
  #     * "ecno": EC/RN Number [rn]
  #     * "si":   Secondary source ID [SI]
  #     * "uid":  PubMed ID (PMID) [UI]
  #     * "fltr": Filter [FILTER] [SB]
  #     * "subs": Subset [SB]
  #   * _reldate_: 365
  #   * _mindate_: 2001
  #   * _maxdate_: 2002/01/01
  #   * _datetype_: "edat"
  # * _limit_: maximum number of entries to be returned (0 for unlimited; nil for the "retmax" value in the hash or the internal default value (=100))
  # * _step_: maximum number of entries retrieved at a time
  # *Returns*:: array of entry IDs or a number of results
  def esearch(str, hash = {}, limit = nil, step = 10000)
    serv = "https://eutils.ncbi.nlm.nih.gov/entrez/eutils/esearch.fcgi"
    opts = default_parameters.merge({ "term" => str })
    opts.update(hash)

    case opts["rettype"]
    when "count"
      count = esearch_count(str, opts)
      return count
    else
      retstart = 0
      retstart = hash["retstart"].to_i if hash["retstart"]

      limit ||= hash["retmax"].to_i if hash["retmax"]
      limit ||= 100 # default limit is 100
      limit = esearch_count(str, opts) if limit == 0   # unlimit

      list = []
      0.step(limit, step) do |i|
        retmax = [step, limit - i].min
        opts.update("retmax" => retmax, "retstart" => i + retstart)
        response = ncbi_post_form(serv, opts)
        result = response.body
        list += result.scan(/<Id>(.*?)<\/Id>/m).flatten
      end
      return list
    end
  end

  # *Arguments*:: same as esearch method
  # *Returns*:: array of entry IDs or a number of results
  def esearch_count(str, hash = {})
    serv = "https://eutils.ncbi.nlm.nih.gov/entrez/eutils/esearch.fcgi"
    opts = default_parameters.merge({ "term" => str })
    opts.update(hash)
    opts.update("rettype" => "count")
    response = ncbi_post_form(serv, opts)
    result = response.body
    count = result.scan(/<Count>(.*?)<\/Count>/m).flatten.first.to_i
    return count
  end


  # Retrieve database entries by given IDs and using E-Utils (efetch) service.
  #
  # For information on the possible arguments, see
  #
  # * https://www.ncbi.nlm.nih.gov/books/NBK25499/#chapter4.EFetch
  #
  # == Usage
  #
  #  ncbi = Bio::NCBI::REST.new
  #  ncbi.efetch("185041", {"db"=>"nucleotide", "rettype"=>"gb", "retmode" => "xml"})
  #  ncbi.efetch("J00231", {"db"=>"nuccore", "rettype"=>"gb", "retmode"=>"xml"})
  #  ncbi.efetch("AAA52805", {"db"=>"protein", "rettype"=>"gb"})
  #
  #  Bio::NCBI::REST.efetch("185041", {"db"=>"nucleotide", "rettype"=>"gb", "retmode" => "xml"})
  #  Bio::NCBI::REST.efetch("J00231", {"db"=>"nuccore", "rettype"=>"gb"})
  #  Bio::NCBI::REST.efetch("AAA52805", {"db"=>"protein", "rettype"=>"gb"})
  #
  # ---
  # *Arguments*:
  # * _ids_: list of NCBI entry IDs (required)
  # * _hash_: hash of E-Utils option {"db" => "nuccore", "rettype" => "gb"}
  #   * _db_: "sequences", "nucleotide", "protein", "pubmed", "omim", ...
  #   * _retmode_: "text", "xml", "html", ...
  #   * _rettype_: "gb", "gbc", "medline", "count",...
  # * _step_: maximum number of entries retrieved at a time
  # *Returns*:: String
  def efetch(ids, hash = {}, step = 100)
    serv = "https://eutils.ncbi.nlm.nih.gov/entrez/eutils/efetch.fcgi"
    opts = default_parameters.merge({ "retmode"  => "text" })
    opts.update(hash)

    case ids
    when Array
      list = ids
    else
      list = ids.to_s.split(/\s*,\s*/)
    end

    result = ""
    0.step(list.size, step) do |i|
      opts["id"] = list[i, step].join(',')
      unless opts["id"].empty?
        response = ncbi_post_form(serv, opts)
        result += response.body
      end
    end
    return result.strip
    #return result.strip.split(/\n\n+/)
  end

  def self.einfo
    self.new.einfo
  end

  def self.esearch(*args)
    self.new.esearch(*args)
  end

  def self.esearch_count(*args)
    self.new.esearch_count(*args)
  end

  def self.efetch(*args)
    self.new.efetch(*args)
  end


  # Shortcut methods for the ESearch service
  class ESearch

    # Search database entries by given keywords using E-Utils (esearch).
    #
    # * https://www.ncbi.nlm.nih.gov/books/NBK25499/#chapter4.ESearch
    #
    #  sequences = gene + genome + nucleotide + protein + popset + snp
    #  nucleotide = nuccore + nucest + nucgss
    #
    # * https://eutils.ncbi.nlm.nih.gov/entrez/eutils/einfo.fcgi
    #
    #  pubmed protein nucleotide nuccore nucgss nucest structure genome
    #  books cancerchromosomes cdd gap domains gene genomeprj gensat geo
    #  gds homologene journals mesh ncbisearch nlmcatalog omia omim pmc
    #  popset probe proteinclusters pcassay pccompound pcsubstance snp
    #  taxonomy toolkit unigene unists
    #
    # == Usage
    #
    #  Bio::NCBI::REST::ESearch.search("nucleotide", "tardigrada")
    #  Bio::NCBI::REST::ESearch.count("nucleotide", "tardigrada")
    #
    #  Bio::NCBI::REST::ESearch.nucleotide("tardigrada")
    #  Bio::NCBI::REST::ESearch.popset("aldh2")
    #  Bio::NCBI::REST::ESearch.taxonomy("tardigrada")
    #  Bio::NCBI::REST::ESearch.pubmed("tardigrada", "reldate" => 365)
    #  Bio::NCBI::REST::ESearch.pubmed("mammoth mitochondrial genome")
    #  Bio::NCBI::REST::ESearch.pmc("Indonesian coelacanth genome Latimeria menadoensis")
    #  Bio::NCBI::REST::ESearch.journal("bmc bioinformatics")
    #
    #  ncbi = Bio::NCBI::REST::ESearch.new
    #  ncbi.search("nucleotide", "tardigrada")
    #  ncbi.count("nucleotide", "tardigrada")
    #
    #  ncbi.nucleotide("tardigrada")
    #  ncbi.popset("aldh2")
    #  ncbi.taxonomy("tardigrada")
    #  ncbi.pubmed("tardigrada", "reldate" => 365)
    #  ncbi.pubmed("mammoth mitochondrial genome")
    #  ncbi.pmc("Indonesian coelacanth genome Latimeria menadoensis")
    #  ncbi.journal("bmc bioinformatics")
    #
    # ---
    #
    # *Arguments*:
    # * _term_: search keywords (required)
    # * _limit_: maximum number of entries to be returned (0 for unlimited)
    # * _hash_: hash of E-Utils option
    # *Returns*:: array of entry IDs or a number of results
    module Methods

      # search("nucleotide", "tardigrada")
      # search("nucleotide", "tardigrada", 0)                  # unlimited
      # search("pubmed", "tardigrada")
      # search("pubmed", "tardigrada", 5)                      # first five
      # search("pubmed", "tardigrada", "reldate" => 365)       # within a year
      # search("pubmed", "tardigrada", 5, "reldate" => 365)    # combination
      # search("pubmed", "tardigrada", {"reldate" => 365}, 5)  # combination 2
      # search("journals", "bmc", 10)
      def search(db, term, *args)
        limit = 100
        hash = {}
        args.each do |arg|
          case arg
          when Hash
            hash.update(arg)
          else
            limit = arg.to_i
          end
        end
        opts = { "db" => db }
        opts.update(hash)
        Bio::NCBI::REST.esearch(term, opts, limit)
      end

      # count("nucleotide", "tardigrada")
      # count("pubmed", "tardigrada")
      # count("journals", "bmc")
      def count(db, term, hash = {})
        opts = { "db" => db }
        opts.update(hash)
        Bio::NCBI::REST.esearch_count(term, opts)
      end

      # nucleotide("tardigrada")
      # nucleotide("tardigrada", 0)
      # pubmed("tardigrada")
      # pubmed("tardigrada", 5)
      # pubmed("tardigrada", "reldate" => 365)
      # pubmed("tardigrada", 5, "reldate" => 365)
      # pubmed("tardigrada", {"reldate" => 365}, 5)
      def method_missing(*args)
        self.search(*args)
      end

      # alias for journals
      def journal(*args)
        self.search("journals", *args)
      end

      # alias for "nucest"
      def est(*args)
        self.search("nucest", *args)
      end

      # alias for "nucgss"
      def gss(*args)
        self.search("nucgss", *args)
      end

    end # Methods

    include Methods
    extend Methods

  end # ESearch


  # Shortcut methods for the EFetch service
  class EFetch

    module Methods

      # Retrieve sequence entries by given IDs using E-Utils (efetch).
      #
      # * https://www.ncbi.nlm.nih.gov/books/NBK25499/#chapter4.EFetch
      #
      #  sequences = gene + genome + nucleotide + protein + popset + snp
      #  nucleotide = nuccore + nucest + nucgss
      #
      # format (rettype):
      # * native       all but Gene    ASN Default format for viewing sequences
      # * fasta        all sequence    FASTA view of a sequence
      # * gb           NA sequence     GenBank view for sequences
      # * gbc          NA sequence     INSDSeq structured flat file
      # * gbwithparts  NA sequence     GenBank CON division with sequences
      # * est          dbEST sequence  EST Report
      # * gss          dbGSS sequence  GSS Report
      # * gp           AA sequence     GenPept view
      # * gpc          AA sequence     INSDSeq structured flat file
      # * seqid        all sequence    Convert GIs into seqids
      # * acc          all sequence    Convert GIs into accessions
      # * chr          dbSNP only      SNP Chromosome Report
      # * flt          dbSNP only      SNP Flat File report
      # * rsr          dbSNP only      SNP RS Cluster report
      # * brief        dbSNP only      SNP ID list
      # * docset       dbSNP only      SNP RS summary
      #
      # == Usage
      #
      #  Bio::NCBI::REST::EFetch.sequence("123,U12345,U12345.1,gb|U12345|")
      #
      #  list = [123, "U12345.1", "gb|U12345|"]
      #  Bio::NCBI::REST::EFetch.sequence(list)
      #  Bio::NCBI::REST::EFetch.sequence(list, "fasta")
      #  Bio::NCBI::REST::EFetch.sequence(list, "acc")
      #  Bio::NCBI::REST::EFetch.sequence(list, "xml")
      #
      #  Bio::NCBI::REST::EFetch.sequence("AE009950")
      #  Bio::NCBI::REST::EFetch.sequence("AE009950", "gbwithparts")
      #
      #  ncbi = Bio::NCBI::REST::EFetch.new
      #  ncbi.sequence("123,U12345,U12345.1,gb|U12345|")
      #  ncbi.sequence(list)
      #  ncbi.sequence(list, "fasta")
      #  ncbi.sequence(list, "acc")
      #  ncbi.sequence(list, "xml")
      #  ncbi.sequence("AE009950")
      #  ncbi.sequence("AE009950", "gbwithparts")
      #
      # ---
      #
      # *Arguments*:
      # * _ids_: list of NCBI entry IDs (required)
      # * _format_: "gb", "gbc", "fasta", "acc", "xml" etc.
      # *Returns*:: String
      def sequence(ids, format = "gb", hash = {})
        case format
        when "xml"
          format = "gbc"
        end
        opts = { "db" => "sequences", "rettype" => format }
        opts.update(hash)
        Bio::NCBI::REST.efetch(ids, opts)
      end

      # Retrieve nucleotide sequence entries by given IDs using E-Utils
      # (efetch).
      #
      # * https://www.ncbi.nlm.nih.gov/books/NBK25499/#chapter4.EFetch
      #  nucleotide = nuccore + nucest + nucgss
      #
      # format (rettype):
      # * native       all but Gene    ASN Default format for viewing sequences
      # * fasta        all sequence    FASTA view of a sequence
      # * gb           NA sequence     GenBank view for sequences
      # * gbc          NA sequence     INSDSeq structured flat file
      # * gbwithparts  NA sequence     GenBank CON division with sequences
      # * est          dbEST sequence  EST Report
      # * gss          dbGSS sequence  GSS Report
      # * gp           AA sequence     GenPept view
      # * gpc          AA sequence     INSDSeq structured flat file
      # * seqid        all sequence    Convert GIs into seqids
      # * acc          all sequence    Convert GIs into accessions
      # * chr          dbSNP only      SNP Chromosome Report
      # * flt          dbSNP only      SNP Flat File report
      # * rsr          dbSNP only      SNP RS Cluster report
      # * brief        dbSNP only      SNP ID list
      # * docset       dbSNP only      SNP RS summary
      #
      # == Usage
      #
      #  Bio::NCBI::REST::EFetch.nucleotide("123,U12345,U12345.1,gb|U12345|")
      #
      #  list = [123, "U12345.1", "gb|U12345|"]
      #  Bio::NCBI::REST::EFetch.nucleotide(list)
      #  Bio::NCBI::REST::EFetch.nucleotide(list, "fasta")
      #  Bio::NCBI::REST::EFetch.nucleotide(list, "acc")
      #  Bio::NCBI::REST::EFetch.nucleotide(list, "xml")
      #
      #  Bio::NCBI::REST::EFetch.nucleotide("AE009950")
      #  Bio::NCBI::REST::EFetch.nucleotide("AE009950", "gbwithparts")
      #
      #  ncbi = Bio::NCBI::REST::EFetch.new
      #  ncbi.nucleotide("123,U12345,U12345.1,gb|U12345|")
      #  ncbi.nucleotide(list)
      #  ncbi.nucleotide(list, "fasta")
      #  ncbi.nucleotide(list, "acc")
      #  ncbi.nucleotide(list, "xml")
      #  ncbi.nucleotide("AE009950")
      #  ncbi.nucleotide("AE009950", "gbwithparts")
      #
      # ---
      #
      # *Arguments*:
      # * _ids_: list of NCBI entry IDs (required)
      # * _format_: "gb", "gbc", "fasta", "acc", "xml" etc.
      # *Returns*:: String
      def nucleotide(ids, format = "gb", hash = {})
        case format
        when "xml"
          format = "gbc"
        end
        opts = { "db" => "nucleotide", "rettype" => format }
        opts.update(hash)
        Bio::NCBI::REST.efetch(ids, opts)
      end

      # Retrieve protein sequence entries by given IDs using E-Utils
      # (efetch).
      #
      # * https://www.ncbi.nlm.nih.gov/books/NBK25499/#chapter4.EFetch
      #  protein
      #
      # format (rettype):
      # * native       all but Gene    ASN Default format for viewing sequences
      # * fasta        all sequence    FASTA view of a sequence
      # * gb           NA sequence     GenBank view for sequences
      # * gbc          NA sequence     INSDSeq structured flat file
      # * gbwithparts  NA sequence     GenBank CON division with sequences
      # * est          dbEST sequence  EST Report
      # * gss          dbGSS sequence  GSS Report
      # * gp           AA sequence     GenPept view
      # * gpc          AA sequence     INSDSeq structured flat file
      # * seqid        all sequence    Convert GIs into seqids
      # * acc          all sequence    Convert GIs into accessions
      # * chr          dbSNP only      SNP Chromosome Report
      # * flt          dbSNP only      SNP Flat File report
      # * rsr          dbSNP only      SNP RS Cluster report
      # * brief        dbSNP only      SNP ID list
      # * docset       dbSNP only      SNP RS summary
      #
      # == Usage
      #
      #  Bio::NCBI::REST::EFetch.protein("7527480,AAF63163.1,AAF63163")
      #
      #  list = [ 7527480, "AAF63163.1", "AAF63163"]
      #  Bio::NCBI::REST::EFetch.protein(list)
      #  Bio::NCBI::REST::EFetch.protein(list, "fasta")
      #  Bio::NCBI::REST::EFetch.protein(list, "acc")
      #  Bio::NCBI::REST::EFetch.protein(list, "xml")
      #
      #  ncbi = Bio::NCBI::REST::EFetch.new
      #  ncbi.protein("7527480,AAF63163.1,AAF63163")
      #  ncbi.protein(list)
      #  ncbi.protein(list, "fasta")
      #  ncbi.protein(list, "acc")
      #  ncbi.protein(list, "xml")
      #
      # ---
      #
      # *Arguments*:
      # * _ids_: list of NCBI entry IDs (required)
      # * _format_: "gp", "gpc", "fasta", "acc", "xml" etc.
      # *Returns*:: String
      def protein(ids, format = "gp", hash = {})
        case format
        when "xml"
          format = "gpc"
        end
        opts = { "db" => "protein", "rettype" => format }
        opts.update(hash)
        Bio::NCBI::REST.efetch(ids, opts)
      end

      # Retrieve PubMed entries by given IDs using E-Utils (efetch).
      #
      # * https://www.ncbi.nlm.nih.gov/books/NBK25499/#chapter4.EFetch
      #
      # == Usage
      #
      #  Bio::NCBI::REST::EFetch.pubmed(15496913)
      #  Bio::NCBI::REST::EFetch.pubmed("15496913,11181995")
      #
      #  list = [15496913, 11181995]
      #  Bio::NCBI::REST::EFetch.pubmed(list)
      #  Bio::NCBI::REST::EFetch.pubmed(list, "abstract")
      #  Bio::NCBI::REST::EFetch.pubmed(list, "citation")
      #  Bio::NCBI::REST::EFetch.pubmed(list, "medline")
      #  Bio::NCBI::REST::EFetch.pubmed(list, "xml")
      #
      #  ncbi = Bio::NCBI::REST::EFetch.new
      #  ncbi.pubmed(list)
      #  ncbi.pubmed(list, "abstract")
      #  ncbi.pubmed(list, "citation")
      #  ncbi.pubmed(list, "medline")
      #  ncbi.pubmed(list, "xml")
      #
      # ---
      #
      # *Arguments*:
      # * _ids_: list of PubMed entry IDs (required)
      # * _format_: "abstract", "citation", "medline", "xml"
      # *Returns*:: String
      def pubmed(ids, format = "medline", hash = {})
        case format
        when "xml"
          format = "medline"
          mode = "xml"
        else
          mode = "text"
        end
        opts = { "db" => "pubmed", "rettype" => format, "retmode" => mode }
        opts.update(hash)
        Bio::NCBI::REST.efetch(ids, opts)
      end

      # Retrieve PubMed Central entries by given IDs using E-Utils (efetch).
      #
      # * https://www.ncbi.nlm.nih.gov/books/NBK25499/#chapter4.EFetch
      #
      # == Usage
      #
      #  Bio::NCBI::REST::EFetch.pmc(1360101)
      #  Bio::NCBI::REST::EFetch.pmc("1360101,534663")
      #
      #  list = [1360101, 534663]
      #  Bio::NCBI::REST::EFetch.pmc(list)
      #  Bio::NCBI::REST::EFetch.pmc(list, "xml")
      #
      #  ncbi = Bio::NCBI::REST::EFetch.new
      #  ncbi.pmc(list)
      #  ncbi.pmc(list, "xml")
      #
      # ---
      #
      # *Arguments*:
      # * _ids_: list of PubMed Central entry IDs (required)
      # * _format_: "docsum", "xml"
      # *Returns*:: String
      def pmc(ids, format = "docsum", hash = {})
        case format
        when "xml"
          format = "medline"
          mode = "xml"
        else
          mode = "text"
        end
        opts = { "db" => "pmc", "rettype" => format, "retmode" => mode }
        Bio::NCBI::REST.efetch(ids, opts)
      end

      # Retrieve journal entries by given IDs using E-Utils (efetch).
      #
      # * https://www.ncbi.nlm.nih.gov/books/NBK25499/#chapter4.EFetch
      #
      # == Usage
      #
      #  Bio::NCBI::REST::EFetch.journal(21854)
      #
      #  list = [21854, 21855]
      #  Bio::NCBI::REST::EFetch.journal(list)
      #  Bio::NCBI::REST::EFetch.journal(list, "xml")
      #
      #  ncbi = Bio::NCBI::REST::EFetch.new
      #  ncbi.journal(list)
      #  ncbi.journal(list, "xml")
      #
      # ---
      #
      # *Arguments*:
      # * _ids_: list of journal entry IDs (required)
      # * _format_: "full", "xml"
      # *Returns*:: String
      def journal(ids, format = "full", hash = {})
        case format
        when "xml"
          format = "full"
          mode = "xml"
        else
          mode = "text"
        end
        opts = { "db" => "journals", "rettype" => format, "retmode" => mode }
        opts.update(hash)
        Bio::NCBI::REST.efetch(ids, opts)
      end

      # Retrieve OMIM entries by given IDs using E-Utils (efetch).
      #
      # * https://www.ncbi.nlm.nih.gov/books/NBK25499/#chapter4.EFetch
      #
      # == Usage
      #
      #  Bio::NCBI::REST::EFetch.omim(143100)
      #
      #  list = [143100, 602260]
      #  Bio::NCBI::REST::EFetch.omim(list)
      #  Bio::NCBI::REST::EFetch.omim(list, "xml")
      #
      #  ncbi = Bio::NCBI::REST::EFetch.new
      #  ncbi.omim(list)
      #  ncbi.omim(list, "xml")
      #
      # ---
      #
      # *Arguments*:
      # * _ids_: list of OMIM entry IDs (required)
      # * _format_: "docsum", "synopsis", "variants", "detailed", "linkout", "xml"
      # *Returns*:: String
      def omim(ids, format = "detailed", hash = {})
        case format
        when "xml"
          format = "full"
          mode = "xml"
        when "linkout"
          format = "ExternalLink"
          mode = "text"
        else
          mode = "text"
        end
        opts = { "db" => "omim", "rettype" => format, "retmode" => mode }
        opts.update(hash)
        Bio::NCBI::REST.efetch(ids, opts)
      end

      # Retrieve taxonomy entries by given IDs using E-Utils (efetch).
      #
      # * https://www.ncbi.nlm.nih.gov/books/NBK25499/#chapter4.EFetch
      #
      # == Usage
      #
      #  Bio::NCBI::REST::EFetch.taxonomy(42241)
      #
      #  list = [232323, 290179, 286681]
      #  Bio::NCBI::REST::EFetch.taxonomy(list)
      #  Bio::NCBI::REST::EFetch.taxonomy(list, "xml")
      #
      #  ncbi = Bio::NCBI::REST::EFetch.new
      #  ncbi.taxonomy(list)
      #  ncbi.taxonomy(list, "xml")
      #
      # ---
      #
      # *Arguments*:
      # * _ids_: list of Taxonomy entry IDs (required)
      # * _format_: "brief", "docsum", "xml"
      # *Returns*:: String
      def taxonomy(ids, format = "docsum", hash = {})
        case format
        when "xml"
          format = "full"
          mode = "xml"
        else
          mode = "text"
        end
        opts = { "db" => "taxonomy", "rettype" => format, "retmode" => mode }
        Bio::NCBI::REST.efetch(ids, opts)
      end

    end # Methods

    include Methods
    extend Methods

  end # EFetch


end # REST
end # NCBI
end # Bio

