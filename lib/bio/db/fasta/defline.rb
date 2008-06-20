#
# = bio/db/fasta/defline.rb - FASTA defline parser class
#
# Copyright::  Copyright (C) 2001, 2002
#              GOTO Naohisa <ngoto@gen-info.osaka-u.ac.jp>,
#              Toshiaki Katayama <k@bioruby.org>
# License::    The Ruby License
#
# $Id: defline.rb,v 1.1.2.1 2008/06/20 13:22:32 ngoto Exp $
# 
# == Description
# 
# Bio::FastaDefline is a parser class for definition line (defline)
# of the FASTA format.
#
# == Examples
#
#       rub = Bio::FastaDefline.new('>gi|671595|emb|CAA85678.1| rubisco large subunit [Perovskia abrotanoides]')
#       rub.entry_id       ==> 'gi|671595'
#       rub.get('emb')     ==> 'CAA85678.1'
#       rub.emb            ==> 'CAA85678.1'
#       rub.gi             ==> '671595'
#       rub.accession      ==> 'CAA85678'
#       rub.accessions     ==> [ 'CAA85678' ]
#       rub.acc_version    ==> 'CAA85678.1'
#       rub.locus          ==> nil
#       rub.list_ids       ==> [["gi", "671595"],
#                               ["emb", "CAA85678.1", nil],
#                               ["Perovskia abrotanoides"]]
#
#       ckr = Bio::FastaDefline.new(">gi|2495000|sp|Q63931|CCKR_CAVPO CHOLECYSTOKININ TYPE A RECEPTOR (CCK-A RECEPTOR) (CCK-AR)\001gi|2147182|pir||I51898 cholecystokinin A receptor - guinea pig\001gi|544724|gb|AAB29504.1| cholecystokinin A receptor; CCK-A receptor [Cavia]")
#       ckr.entry_id      ==> "gi|2495000"
#       ckr.sp            ==> "CCKR_CAVPO"
#       ckr.pir           ==> "I51898"
#       ckr.gb            ==> "AAB29504.1"
#       ckr.gi            ==> "2495000"
#       ckr.accession     ==> "AAB29504"
#       ckr.accessions    ==> ["Q63931", "AAB29504"]
#       ckr.acc_version   ==> "AAB29504.1"
#       ckr.locus         ==> nil
#       ckr.description   ==>
#         "CHOLECYSTOKININ TYPE A RECEPTOR (CCK-A RECEPTOR) (CCK-AR)"
#       ckr.descriptions  ==>
#         ["CHOLECYSTOKININ TYPE A RECEPTOR (CCK-A RECEPTOR) (CCK-AR)",
#          "cholecystokinin A receptor - guinea pig",
#          "cholecystokinin A receptor; CCK-A receptor [Cavia]"]
#       ckr.words         ==> 
#         ["cavia", "cck-a", "cck-ar", "cholecystokinin", "guinea", "pig",
#          "receptor", "type"]
#       ckr.id_strings    ==>
#         ["2495000", "Q63931", "CCKR_CAVPO", "2147182", "I51898",
#          "544724", "AAB29504.1", "Cavia"]
#       ckr.list_ids      ==>
#         [["gi", "2495000"], ["sp", "Q63931", "CCKR_CAVPO"],
#          ["gi", "2147182"], ["pir", nil, "I51898"], ["gi", "544724"],
#          ["gb", "AAB29504.1", nil], ["Cavia"]]
#
# == References
#
# * FASTA format (WikiPedia)
#   http://en.wikipedia.org/wiki/FASTA_format
#   
# * Fasta format description (NCBI)
#   http://www.ncbi.nlm.nih.gov/BLAST/fasta.shtml
#

module Bio

  #--
  # split from fasta.rb revision 1.28
  #++

  # Parsing FASTA Defline, and extract IDs and other informations.
  # IDs are NSIDs (NCBI standard FASTA sequence identifiers)
  # or ":"-separated IDs.
  # 
  # specs are described in:
  # ftp://ftp.ncbi.nih.gov/blast/documents/README.formatdb
  # http://blast.wustl.edu/doc/FAQ-Indexing.html#Identifiers
  #
  # === Examples
  #
  #   rub = Bio::FastaDefline.new('>gi|671595|emb|CAA85678.1| rubisco large subunit [Perovskia abrotanoides]')
  #   rub.entry_id       ==> 'gi|671595'
  #   rub.get('emb')     ==> 'CAA85678.1'
  #   rub.emb            ==> 'CAA85678.1'
  #   rub.gi             ==> '671595'
  #   rub.accession      ==> 'CAA85678'
  #   rub.accessions     ==> [ 'CAA85678' ]
  #   rub.acc_version    ==> 'CAA85678.1'
  #   rub.locus          ==> nil
  #   rub.list_ids       ==> [["gi", "671595"],
  #                           ["emb", "CAA85678.1", nil],
  #                           ["Perovskia abrotanoides"]]
  #
  #   ckr = Bio::FastaDefline.new(">gi|2495000|sp|Q63931|CCKR_CAVPO CHOLECYSTOKININ TYPE A RECEPTOR (CCK-A RECEPTOR) (CCK-AR)\001gi|2147182|pir||I51898 cholecystokinin A receptor - guinea pig\001gi|544724|gb|AAB29504.1| cholecystokinin A receptor; CCK-A receptor [Cavia]")
  #   ckr.entry_id      ==> "gi|2495000"
  #   ckr.sp            ==> "CCKR_CAVPO"
  #   ckr.pir           ==> "I51898"
  #   ckr.gb            ==> "AAB29504.1"
  #   ckr.gi            ==> "2495000"
  #   ckr.accession     ==> "AAB29504"
  #   ckr.accessions    ==> ["Q63931", "AAB29504"]
  #   ckr.acc_version   ==> "AAB29504.1"
  #   ckr.locus         ==> nil
  #   ckr.description   ==>
  #     "CHOLECYSTOKININ TYPE A RECEPTOR (CCK-A RECEPTOR) (CCK-AR)"
  #   ckr.descriptions  ==>
  #     ["CHOLECYSTOKININ TYPE A RECEPTOR (CCK-A RECEPTOR) (CCK-AR)",
  #      "cholecystokinin A receptor - guinea pig",
  #      "cholecystokinin A receptor; CCK-A receptor [Cavia]"]
  #   ckr.words         ==> 
  #     ["cavia", "cck-a", "cck-ar", "cholecystokinin", "guinea", "pig",
  #      "receptor", "type"]
  #   ckr.id_strings    ==>
  #     ["2495000", "Q63931", "CCKR_CAVPO", "2147182", "I51898",
  #      "544724", "AAB29504.1", "Cavia"]
  #   ckr.list_ids      ==>
  #     [["gi", "2495000"], ["sp", "Q63931", "CCKR_CAVPO"],
  #      ["gi", "2147182"], ["pir", nil, "I51898"], ["gi", "544724"],
  #      ["gb", "AAB29504.1", nil], ["Cavia"]]
  #
  # === Refereneces
  #
  # * Fasta format description (NCBI)
  #   http://www.ncbi.nlm.nih.gov/BLAST/fasta.shtml
  #
  # * Frequently Asked Questions:  Indexing of Sequence Identifiers (by Warren R. Gish.)
  #   http://blast.wustl.edu/doc/FAQ-Indexing.html#Identifiers
  #
  # * README.formatdb
  #   ftp://ftp.ncbi.nih.gov/blast/documents/README.formatdb
  # 
  class FastaDefline

    NSIDs = {
      # NCBI and WU-BLAST
      'gi'  => [ 'gi' ],                      # NCBI GI
      'gb'  => [ 'acc_version', 'locus' ],      # GenBank
      'emb' => [ 'acc_version', 'locus' ],      # EMBL
      'dbj' => [ 'acc_version', 'locus' ],      # DDBJ
      'sp'  => [ 'accession', 'entry_id' ],   # SWISS-PROT
      'pdb' => [ 'entry_id', 'chain' ],       # PDB
      'bbs' => [ 'number' ],                  # GenInfo Backbone Id
      'gnl' => [ 'database' , 'entry_id' ],   # General database identifier
      'ref' => [ 'acc_version' , 'locus' ],     # NCBI Reference Sequence
      'lcl' => [ 'entry_id' ],                # Local Sequence identifier

      # WU-BLAST and NCBI
      'pir' => [ 'accession', 'entry_id' ],   # PIR
      'prf' => [ 'accession', 'entry_id' ],   # Protein Research Foundation
      'pat' => [ 'country', 'number', 'serial' ], # Patents

      # WU-BLAST only
      'bbm' => [ 'number' ],      # NCBI GenInfo Backbone database identifier
      'gim' => [ 'number' ],      # NCBI GenInfo Import identifier
      'gp'  => [ 'acc_version', 'locus' ],      # GenPept
      'oth' => [ 'accession', 'name', 'release' ],  # Other (user-definable) identifier
      'tpd' => [ 'accession', 'name' ],       # Third party annotation, DDBJ
      'tpe' => [ 'accession', 'name' ],       # Third party annotation, EMBL
      'tpg' => [ 'accession', 'name' ],       # Third party annotation, GenBank

      # Original
      'ri'  => [ 'entry_id', 'rearray_id', 'len' ], # RIKEN FANTOM DB
    }

    # Shows array that contains IDs (or ID-like strings).
    # Returns an array of arrays of strings.
    attr_reader :list_ids

    # Shows a possibly unique identifier.
    # Returns a string.
    attr_reader :entry_id

    # Parses given string.
    def initialize(str)
      @deflines = []
      @info = {}
      @list_ids = []

      @entry_id = nil

      lines = str.split("\x01")
      lines.each do |line|
        add_defline(line)
      end
    end #def initialize

    # Parses given string and adds parsed data.
    def add_defline(str)
      case str
      when /^\>?\s*((?:[^\|\s]*\|)+[^\s]+)\s*(.*)$/
        # NSIDs
        # examples:
        # >gi|9910844|sp|Q9UWG2|RL3_METVA 50S ribosomal protein L3P
        #
        # note: regexp (:?) means grouping without backreferences
        i = $1
        d = $2
        tks = i.split('|')
        tks << '' if i[-1,1] == '|'
        a = parse_NSIDs(tks)
        i = a[0].join('|')
        a.unshift('|')
        d = tks.join('|') + ' ' + d unless tks.empty?
        a << d
        this_line = a
        match_EC(d)
        parse_square_brackets(d).each do |x|
          if !match_EC(x, false) and x =~ /\A[A-Z]/ then
            di = [  x ]
            @list_ids << di
            @info['organism'] = x unless @info['organism']
          end
        end

      when /^\>?\s*([a-zA-Z0-9]+\:[^\s]+)\s*(.*)$/
        # examples:
        # >sce:YBR160W  CDC28, SRM5; cyclin-dependent protein kinase catalytic subunit [EC:2.7.1.-] [SP:CC28_YEAST]
        # >emb:CACDC28 [X80034] C.albicans CDC28 gene 
        i = $1
        d = $2
        a = parse_ColonSepID(i)
        i = a.join(':')
        this_line = [ ':', a , d ]
        match_EC(d)
        parse_square_brackets(d).each do |x|
          if !match_EC(x, false) and x =~ /:/ then
            parse_ColonSepID(x)
          elsif x =~ /\A\s*([A-Z][A-Z0-9_\.]+)\s*\z/ then
            @list_ids << [ $1 ]
          end
        end

      when /^\>?\s*(\S+)(?:\s+(.+))?$/
        # examples:
        # >ABC12345 this is test
        i = $1
        d = $2.to_s
        @list_ids << [ i.chomp('.') ]
        this_line = [  '', [ i ], d ]
        match_EC(d)
      else
        i = str
        d = ''
        match_EC(i)
        this_line = [ '', [ i ], d ]
      end

      @deflines << this_line
      @entry_id = i unless @entry_id
    end

    def match_EC(str, write_flag = true)
      di = nil
      str.scan(/EC\:((:?[\-\d]+\.){3}(:?[\-\d]+))/i) do |x|
        di = [ 'EC', $1 ]
        if write_flag then
          @info['ec'] = di[1] if (!@info['ec'] or @info['ec'].to_s =~ /\-/)
          @list_ids << di
        end
      end
      di
    end
    private :match_EC

    def parse_square_brackets(str)
      r = []
      str.scan(/\[([^\]]*)\]/) do |x|
        r << x[0]
      end
      r
    end
    private :parse_square_brackets

    def parse_ColonSepID(str)
      di = str.split(':', 2)
      di << nil if di.size <= 1 
      @list_ids << di
      di
    end
    private :parse_ColonSepID

    def parse_NSIDs(ary)
      # this method destroys ary
      data = []
      while token = ary.shift
        if labels = self.class::NSIDs[token] then
          di = [ token ]
          idtype = token
          labels.each do |x|
            token = ary.shift
            break unless token
            if self.class::NSIDs[token] then
              ary.unshift(token)
              break #each
            end
            if token.length > 0 then
              di << token
            else
              di << nil
            end
          end
          data << di
        else
          if token.length > 0 then
            # UCID (uncontrolled identifiers)
            di = [ token ]
            data << di
            @info['ucid'] = token unless @info['ucid']
          end
          break #while
        end
      end #while
      @list_ids.concat data
      data
    end #def parse_NSIDs
    private :parse_NSIDs


    # Shows original string.
    # Note that the result of this method may be different from
    # original string which is given in FastaDefline.new method.
    def to_s
      @deflines.collect { |a|
        s = a[0]
        (a[1..-2].collect { |x| x.join(s) }.join(s) + ' ' + a[-1]).strip
      }.join("\x01")
    end

    # Shows description.
    def description
      @deflines[0].to_a[-1]
    end

    # Returns descriptions.
    def descriptions
      @deflines.collect do |a|
        a[-1]
      end
    end

    # Shows ID-like strings.
    # Returns an array of strings.
    def id_strings
      r = []
      @list_ids.each do |a|
        if a.size >= 2 then
          r.concat a[1..-1].find_all { |x| x }
        else
          if a[0].to_s.size > 0 and a[0] =~ /\A[A-Za-z0-9\.\-\_]+\z/
            r << a[0]
          end
        end
      end
      r.concat( words(true, []).find_all do |x|
                 x =~ /\A[A-Z][A-Za-z0-9\_]*[0-9]+[A-Za-z0-9\_]+\z/ or
                   x =~ /\A[A-Z][A-Z0-9]*\_[A-Z0-9\_]+\z/
               end)
      r
    end

    KillWords = [
      'an', 'the', 'this', 'that',
      'is', 'are', 'were', 'was', 'be', 'can', 'may', 'might',
      'as', 'at', 'by', 'for', 'in', 'of', 'on', 'to', 'with',
      'from', 'and', 'or', 'not',
      'dna', 'rna', 'mrna', 'cdna', 'orf',
      'aa', 'nt', 'pct', 'id', 'ec', 'sp', 'subsp',
      'similar', 'involved', 'identical', 'identity',
      'cds', 'clone', 'library', 'contig', 'contigs',
      'homolog', 'homologue', 'homologs', 'homologous',
      'protein', 'proteins', 'gene', 'genes',
      'product', 'products', 'sequence', 'sequences', 
      'strain', 'strains', 'region', 'regions',
    ]
    KillWordsHash = {}
    KillWords.each { |x| KillWordsHash[x] = true }

    KillRegexpArray = [
      /\A\d{1,3}\%?\z/,
      /\A[A-Z][A-Za-z0-9\_]*[0-9]+[A-Za-z0-9\_]+\z/,
      /\A[A-Z][A-Z0-9]*\_[A-Z0-9\_]+\z/
    ]

    # Shows words used in the defline. Returns an Array.
    def words(case_sensitive = nil, kill_regexp = self.class::KillRegexpArray,
              kwhash = self.class::KillWordsHash)
      a = descriptions.join(' ').split(/[\.\,\;\:\(\)\[\]\{\}\<\>\"\'\`\~\/\|\?\!\&\@\#\s\x00-\x1f\x7f]+/)
      a.collect! do |x|
        x.sub!(/\A[\$\*\-\+]+/, '')
        x.sub!(/[\$\*\-\=]+\z/, '')
        if x.size <= 1 then
          nil
        elsif kwhash[x.downcase] then
          nil
        else
          if kill_regexp.find { |expr| expr =~ x } then
            nil
          else
            x
          end
        end
      end
      a.compact!
      a.collect! { |x| x.downcase } unless case_sensitive
      a.sort!
      a.uniq!
      a
    end

    # Returns identifires by a database name.
    def get(dbname)
      db = dbname.to_s
      r = nil
      unless r = @info[db] then
        di = @list_ids.find { |x| x[0] == db.to_s }
        if di and di.size <= 2 then
          r = di[-1]
        elsif di then
          labels = self.class::NSIDs[db]
          [ 'acc_version', 'entry_id',
            'locus', 'accession', 'number'].each do |x|
            if i = labels.index(x) then
              r = di[i+1]
              break if r
            end
          end
          r = di[1..-1].find { |x| x } unless r
        end
        @info[db] = r if r
      end
      r
    end

    # Returns an identifier by given type.
    def get_by_type(type_str)
      @list_ids.each do |x|
        if labels = self.class::NSIDs[x[0]] then
          if i = labels.index(type_str) then
            return x[i+1]
          end
        end
      end
      nil
    end

    # Returns identifiers by given type.
    def get_all_by_type(*type_strarg)
      d = []
      @list_ids.each do |x|
        if labels = self.class::NSIDs[x[0]] then
          type_strarg.each do |y|
            if i = labels.index(y) then
              d << x[i+1] if x[i+1]
            end
          end
        end
      end
      d
    end

    # Shows locus.
    # If the entry has more than two of such IDs,
    # only the first ID are shown.
    # Returns a string or nil.
    def locus
      unless defined?(@locus)
        @locus = get_by_type('locus')
      end
      @locus
    end

    # Shows GI.
    # If the entry has more than two of such IDs,
    # only the first ID are shown.
    # Returns a string or nil.
    def gi
      unless defined?(@gi) then
        @gi = get_by_type('gi')
      end
      @gi
    end

    # Shows accession with version number.
    # If the entry has more than two of such IDs,
    # only the first ID are shown.
    # Returns a string or nil.
    def acc_version
      unless defined?(@acc_version) then
        @acc_version = get_by_type('acc_version')
      end
      @acc_version
    end

    # Shows accession numbers.
    # Returns an array of strings.
    def accessions
      unless defined?(@accessions) then
        @accessions = get_all_by_type('accession', 'acc_version')
        @accessions.collect! { |x| x.sub(/\..*\z/, '') }
      end
      @accessions
    end

    # Shows an accession number.
    def accession
      unless defined?(@accession) then
        if acc_version then
          @accession = acc_version.split('.')[0]
        else
          @accession = accessions[0]
        end
      end
      @accession
    end
    
    def method_missing(name, *args)
      # raise ArgumentError,
      # "wrong # of arguments(#{args.size} for 1)" if args.size >= 2
      r = get(name, *args)
      if !r and !(self.class::NSIDs[name.to_s]) then
        raise "NameError: undefined method `#{name.inspect}'"
      end
      r
    end
    

  end #class FastaDefline

end #module Bio

