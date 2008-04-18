#
# = bio/db/embl/sptr.rb - UniProt/SwissProt and TrEMBL database class
# 
# Copyright::   Copyright (C) 2001-2006  Mitsuteru C. Nakao <n@bioruby.org>
# License::     The Ruby License
#
# $Id: sptr.rb,v 1.37 2008/04/18 15:40:36 ngoto Exp $
#
# == Description
# 
# Shared methods for UniProtKB/SwissProt and TrEMBL classes.
#
# See the SWISS-PROT document file SPECLIST.TXT or UniProtKB/SwissProt 
# user manual.
# 
# == Examples
#
#   str = File.read("p53_human.swiss")
#   obj = Bio::SPTR.new(str)
#   obj.entry_id #=> "P53_HUMAN"
# 
# == References
# 
# * Swiss-Prot Protein knowledgebase. TrEMBL Computer-annotated supplement 
#   to Swiss-Prot	
#   http://au.expasy.org/sprot/
#
# * UniProt
#   http://uniprot.org/
#
# * The UniProtKB/SwissProt/TrEMBL User Manual
#   http://www.expasy.org/sprot/userman.html
#


require 'bio/db'
require 'bio/db/embl/common'

module Bio

# Parser class for UniProtKB/SwissProt and TrEMBL database entry.
class SPTR < EMBLDB
  include Bio::EMBLDB::Common
    
  @@entry_regrexp = /[A-Z0-9]{1,4}_[A-Z0-9]{1,5}/
  @@data_class = ["STANDARD", "PRELIMINARY"]

  # returns a Hash of the ID line.
  #
  # returns a content (Int or String) of the ID line by a given key.
  # Hash keys: ['ENTRY_NAME', 'DATA_CLASS', 'MODECULE_TYPE', 'SEQUENCE_LENGTH']
  #
  # === ID Line
  #   ID   P53_HUMAN      STANDARD;      PRT;   393 AA.
  #   #"ID  #{ENTRY_NAME} #{DATA_CLASS}; #{MOLECULE_TYPE}; #{SEQUENCE_LENGTH}."
  #
  # === Examples
  #   obj.id_line  #=> {"ENTRY_NAME"=>"P53_HUMAN", "DATA_CLASS"=>"STANDARD", 
  #                     "SEQUENCE_LENGTH"=>393, "MOLECULE_TYPE"=>"PRT"}
  #
  #   obj.id_line('ENTRY_NAME') #=> "P53_HUMAN"
  #
  def id_line(key = nil)
    return id_line[key] if key
    return @data['ID'] if @data['ID']

    part = @orig['ID'].split(/ +/)         
    @data['ID'] = {
      'ENTRY_NAME'      => part[1],
      'DATA_CLASS'      => part[2].sub(/;/,''),
      'MOLECULE_TYPE'   => part[3].sub(/;/,''),
      'SEQUENCE_LENGTH' => part[4].to_i 
    }
  end


  # returns a ENTRY_NAME in the ID line. 
  #
  def entry_id
    id_line('ENTRY_NAME')
  end
  alias entry_name entry_id
  alias entry entry_id


  # returns a MOLECULE_TYPE in the ID line.
  #
  # A short-cut for Bio::SPTR#id_line('MOLECULE_TYPE').
  def molecule
    id_line('MOLECULE_TYPE')
  end
  alias molecule_type molecule


  # returns a SEQUENCE_LENGTH in the ID line.
  # 
  # A short-cut for Bio::SPTR#id_line('SEQUENCE_LENGHT').
  def sequence_length
    id_line('SEQUENCE_LENGTH')
  end
  alias aalen sequence_length


  # Bio::EMBLDB::Common#ac  -> ary
  #                  #accessions  -> ary
  #                  #accession  -> String (accessions.first)
  @@ac_regrexp = /[OPQ][0-9][A-Z0-9]{3}[0-9]/ 



  # returns a Hash of information in the DT lines.
  #  hash keys: 
  #    ['created', 'sequence', 'annotation']
  #  also Symbols acceptable (ASAP):
  #    [:created, :sequence, :annotation]
  #
  # returns a String of information in the DT lines by a given key..
  #
  # === DT Line; date (3/entry)
  #   DT DD-MMM-YYY (rel. NN, Created)
  #   DT DD-MMM-YYY (rel. NN, Last sequence update)
  #   DT DD-MMM-YYY (rel. NN, Last annotation update)
  def dt(key = nil)
    return dt[key] if key
    return @data['DT'] if @data['DT']

    part = self.get('DT').split(/\n/)
    @data['DT'] = {
      'created'    => part[0].sub(/\w{2}   /,'').strip,
      'sequence'   => part[1].sub(/\w{2}   /,'').strip,
      'annotation' => part[2].sub(/\w{2}   /,'').strip
    }
  end


  # returns the proposed official name of the protein.
  # 
  # === DE Line; description (>=1)
  #  "DE #{OFFICIAL_NAME} (#{SYNONYM})"
  #  "DE #{OFFICIAL_NAME} (#{SYNONYM}) [CONTEINS: #1; #2]."
  #  OFFICIAL_NAME  1/entry
  #  SYNONYM        >=0
  #  CONTEINS       >=0
  def protein_name
    name = ""
    if de_line = fetch('DE') then
      str = de_line[/^[^\[]*/] # everything preceding the first [ (the "contains" part)
      name = str[/^[^(]*/].strip
      name << ' (Fragment)' if str =~ /fragment/i
    end
    return name
  end


  # returns an array of synonyms (unofficial names).
  #
  # synonyms are each placed in () following the official name on the DE line.
  def synonyms
    ary = Array.new
    if de_line = fetch('DE') then
      line = de_line.sub(/\[.*\]/,'') # ignore stuff between [ and ].  That's the "contains" part
      line.scan(/\([^)]+/) do |synonym| 
        unless synonym =~ /fragment/i then 
          ary << synonym[1..-1].strip # index to remove the leading (  
        end
      end
    end
    return ary
  end


  # returns gene names in the GN line.
  #
  # New UniProt/SwissProt format:
  # * Bio::SPTR#gn -> [ <gene record>* ]
  # where <gene record> is:
  #                    { :name => '...', 
  #                      :synonyms => [ 's1', 's2', ... ],
  #                      :loci   => [ 'l1', 'l2', ... ],
  #                      :orfs     => [ 'o1', 'o2', ... ] 
  #                    }
  #
  # Old format:
  # * Bio::SPTR#gn -> Array      # AND 
  # * Bio::SPTR#gn[0] -> Array   # OR
  #
  # === GN Line: Gene name(s) (>=0, optional)
  def gn
    unless @data['GN']
      case fetch('GN')
      when /Name=/,/ORFNames=/
        @data['GN'] = gn_uniprot_parser
      else
        @data['GN'] = gn_old_parser
      end
    end
    @data['GN']
  end


  # returns contents in the old style GN line.
  # === GN Line: Gene name(s) (>=0, optional)
  #  GN   HNS OR DRDX OR OSMZ OR BGLY.
  #  GN   CECA1 AND CECA2.
  #  GN   CECA1 AND (HOGE OR FUGA).
  #
  #  GN NAME1 [(AND|OR) NAME]+.
  #
  # Bio::SPTR#gn -> Array      # AND 
  #          #gn[0] -> Array   # OR
  #          #gene_names -> Array
  def gn_old_parser
    names = Array.new
    if get('GN').size > 0
      names = fetch('GN').sub(/\.$/,'').split(/ AND /)
      names.map! { |synonyms|
        synonyms = synonyms.gsub(/\(|\)/,'').split(/ OR /).map { |e|
          e.strip 
        }
      }
    end
    @data['GN'] = names
  end
  private :gn_old_parser

  # returns contents in the structured GN line.
  # The new format of the GN line is:
  #  GN   Name=; Synonyms=[, ...]; OrderedLocusNames=[, ...];
  #  GN   ORFNames=[, ...];
  #
  # * Bio::SPTR#gn -> [ <gene record>* ]
  # where <gene record> is:
  #                    { :name => '...', 
  #                      :synonyms => [ 's1', 's2', ... ],
  #                      :loci   => [ 'l1', 'l2', ... ],
  #                      :orfs     => [ 'o1', 'o2', ... ] 
  #                    }
  def gn_uniprot_parser
    @data['GN'] = Array.new
    gn_line = fetch('GN').strip
    records = gn_line.split(/\s*and\s*/)
    records.each do |record|
      gene_hash = {:name => '', :synonyms => [], :loci => [], :orfs => []}
      record.each(';') do |element|
        case element
        when /Name=/ then
          gene_hash[:name] = $'[0..-2]
        when /Synonyms=/ then
          gene_hash[:synonyms] = $'[0..-2].split(/\s*,\s*/)
        when /OrderedLocusNames=/ then
          gene_hash[:loci] = $'[0..-2].split(/\s*,\s*/)
        when /ORFNames=/ then
          gene_hash[:orfs] = $'[0..-2].split(/\s*,\s*/)
        end
      end
      @data['GN'] << gene_hash
    end
    return @data['GN']
  end
  private :gn_uniprot_parser


  # returns a Array of gene names in the GN line.
  def gene_names
    gn # set @data['GN'] if it hasn't been already done
    if @data['GN'].first.class == Hash then
      @data['GN'].collect { |element| element[:name] }
    else
      @data['GN'].first
    end
  end


  # returns a String of the first gene name in the GN line.
  def gene_name
    gene_names.first
  end


  # returns a Array of Hashs or a String of the OS line when a key given.
  # * Bio::EMBLDB#os  -> Array
  #  [{'name' => '(Human)', 'os' => 'Homo sapiens'}, 
  #   {'name' => '(Rat)', 'os' => 'Rattus norveticus'}]
  # * Bio::EPTR#os[0] -> Hash 
  #  {'name' => "(Human)", 'os' => 'Homo sapiens'}
  # * Bio::SPTR#os[0]['name'] -> "(Human)"
  # * Bio::EPTR#os(0) -> "Homo sapiens (Human)"
  # 
  # === OS Line; organism species (>=1)
  #  OS   Genus species (name).
  #  OS   Genus species (name0) (name1).
  #  OS   Genus species (name0) (name1).
  #  OS   Genus species (name0), G s0 (name0), and G s (name0) (name1).
  #  OS   Homo sapiens (Human), and Rarrus norveticus (Rat)
  #  OS   Hippotis sp. Clark and Watts 825.
  #  OS   unknown cyperaceous sp.
  def os(num = nil)
    unless @data['OS']
      os = Array.new
      fetch('OS').split(/, and|, /).each do |tmp|
        if tmp =~ /(\w+ *[\w\d \:\'\+\-\.]+[\w\d\.])/
          org = $1
          tmp =~ /(\(.+\))/ 
          os.push({'name' => $1, 'os' => org})
        else
          raise "Error: OS Line. #{$!}\n#{fetch('OS')}\n"
        end
      end
      @data['OS'] = os
    end

    if num
      # EX. "Trifolium repens (white clover)"
      return "#{@data['OS'][num]['os']} #{@data['OS'][num]['name']}"
    else
      return @data['OS']
    end
  end
  

  # Bio::EMBLDB::Common#og -> Array
  # OG Line; organella (0 or 1/entry)
  # ["MITOCHONDRION", "CHLOROPLAST", "Cyanelle", "Plasmid"]
  #  or a plasmid name (e.g. "Plasmid pBR322").  


  # Bio::EMBLDB::Common#oc -> Array
  # OC Line; organism classification (>=1)
  # "OC   Eukaryota; Alveolata; Apicomplexa; Piroplasmida; Theileriidae;"
  # "OC   Theileria."



  # returns a Hash of oraganism taxonomy cross-references.
  # * Bio::SPTR#ox -> Hash
  #    {'NCBI_TaxID' => ['1234','2345','3456','4567'], ...}
  #
  # === OX Line; organism taxonomy cross-reference (>=1 per entry)
  #  OX   NCBI_TaxID=1234;
  #  OX   NCBI_TaxID=1234, 2345, 3456, 4567;
  def ox
    unless @data['OX']
      tmp = fetch('OX').sub(/\.$/,'').split(/;/).map { |e| e.strip }
      hsh = Hash.new
      tmp.each do |e|
        db,refs = e.split(/=/)
        hsh[db] = refs.split(/, */)
      end
      @data['OX'] = hsh
    end
    return @data['OX']
  end

  # === The OH Line;  
  #
  # OH   NCBI_TaxID=TaxID; HostName.
  # http://br.expasy.org/sprot/userman.html#OH_line
  def oh
    unless @data['OH']
      @data['OH'] = fetch('OH').split("\. ").map {|x|
        if x =~ /NCBI_TaxID=(\d+);/
          taxid = $1
        else
          raise ArgumentError, ["Error: Invalid OH line format (#{self.entry_id}):",
                                $!, "\n", get('OH'), "\n"].join
          
        end
        if x =~ /NCBI_TaxID=\d+; (.+)/ 
          host_name = $1
          host_name.sub!(/\.$/, '')
        else
          host_name = nil
        end
        {'NCBI_TaxID' => taxid, 'HostName' => host_name}
      }
    end
    @data['OH']
  end


  
  # Bio::EMBLDB::Common#ref -> Array
  # R Lines
  # RN RC RP RX RA RT RL

  # returns contents in the R lines.
  # * Bio::EMBLDB::Common#ref -> [ <refernece information Hash>* ]
  # where <reference information Hash> is:
  #  {'RN' => '', 'RC' => '', 'RP' => '', 'RX' => '', 
  #   'RA' => '', 'RT' => '', 'RL' => '', 'RG' => ''}
  # 
  # R Lines
  # * RN RC RP RX RA RT RL RG
  def ref
    unless @data['R']
      @data['R'] = [get('R').split(/\nRN   /)].flatten.map { |str|
        hash = {'RN' => '', 'RC' => '', 'RP' => '', 'RX' => '', 
               'RA' => '', 'RT' => '', 'RL' => '', 'RG' => ''}
        str = 'RN   ' + str unless /^RN   / =~ str

        str.split("\n").each do |line|
          if /^(R[NPXARLCTG])   (.+)/ =~ line
            hash[$1] += $2 + ' '
          else
            raise "Invalid format in R lines, \n[#{line}]\n"
          end
        end

        hash['RN'] = set_RN(hash['RN'])
        hash['RC'] = set_RC(hash['RC'])
        hash['RP'] = set_RP(hash['RP'])
        hash['RX'] = set_RX(hash['RX'])
        hash['RA'] = set_RA(hash['RA'])
        hash['RT'] = set_RT(hash['RT'])
        hash['RL'] = set_RL(hash['RL'])
        hash['RG'] = set_RG(hash['RG'])

        hash
      }

    end
    @data['R']
  end

  def set_RN(data)
    data.strip
  end

  def set_RC(data)
    data.scan(/([STP]\w+)=(.+);/).map { |comment|
      [comment[1].split(/, and |, /)].flatten.map { |text|
        {'Token' => comment[0], 'Text' => text}
      }
    }.flatten
  end
  private :set_RC

  def set_RP(data)
    data = data.strip
    data = data.sub(/\.$/, '')
    data.split(/, AND |, /i).map {|x| 
      x = x.strip
      x = x.gsub('  ', ' ')
    }
  end
  private :set_RP

  def set_RX(data)
    rx = {'MEDLINE' => nil, 'PubMed' => nil, 'DOI' => nil}
    if data =~ /MEDLINE=(.+?);/
      rx['MEDLINE'] = $1
    end
    if data =~ /PubMed=(.+?);/
      rx['PubMed'] = $1
    end
    if data =~ /DOI=(.+?);/
      rx['DOI'] = $1
    end
    rx
  end
  private :set_RX

  def set_RA(data)
    data = data.sub(/; *$/, '')
  end
  private :set_RA

  def set_RT(data)
    data = data.sub(/; *$/, '')
    data = data.gsub(/(^"|"$)/, '')
  end
  private :set_RT

  def set_RL(data)
    data = data.strip
  end
  private :set_RL

  def set_RG(data)
    data = data.split('; ')
  end
  private :set_RG



  # returns Bio::Reference object from Bio::EMBLDB::Common#ref.
  # * Bio::EMBLDB::Common#ref -> Bio::References
  def references
    unless @data['references']
      ary = self.ref.map {|ent|
        hash = Hash.new('')
        ent.each {|key, value|
          case key
          when 'RA'
            hash['authors'] = value.split(/, /)
          when 'RT'
            hash['title'] = value
          when 'RL'
            if value =~ /(.*) (\d+) \((\d+)\), (\d+-\d+) \((\d+)\)$/
              hash['journal'] = $1
              hash['volume']  = $2
              hash['issue']   = $3
              hash['pages']   = $4
              hash['year']    = $5
            else
              hash['journal'] = value
            end
          when 'RX'  # PUBMED, MEDLINE
            value.each do |tag, xref|
              hash[ tag.downcase ]  = xref
            end
          end
        }
        Reference.new(hash)
      }
      @data['references'] = References.new(ary)
    end
    @data['references']
  end






  # === The HI line
  # Bio::SPTR#hi #=> hash
  def hi
    unless @data['HI']
      @data['HI'] = []
      fetch('HI').split(/\. /).each do |hlist|
        hash = {'Category' => '',  'Keywords' => [], 'Keyword' => ''}
        hash['Category'], hash['Keywords'] = hlist.split(': ')
        hash['Keywords'] = hash['Keywords'].split('; ')
        hash['Keyword'] = hash['Keywords'].pop
        hash['Keyword'].sub!(/\.$/, '')
        @data['HI'] << hash
      end
    end
    @data['HI']
  end


  @@cc_topics = ['PHARMACEUTICAL',
                 'BIOTECHNOLOGY',
                 'TOXIC DOSE', 
                 'ALLERGEN',   
                 'RNA EDITING',
                 'POLYMORPHISM',
                 'BIOPHYSICOCHEMICAL PROPERTIES',
                 'MASS SPECTROMETRY',
                 'WEB RESOURCE', 
                 'ENZYME REGULATION',
                 'DISEASE',
                 'INTERACTION',
                 'DEVELOPMENTAL STAGE',
                 'INDUCTION',
                 'CAUTION',
                 'ALTERNATIVE PRODUCTS',
                 'DOMAIN',
                 'PTM',
                 'MISCELLANEOUS',
                 'TISSUE SPECIFICITY',
                 'COFACTOR',
                 'PATHWAY',
                 'SUBUNIT',
                 'CATALYTIC ACTIVITY',
                 'SUBCELLULAR LOCATION',
                 'FUNCTION',
                 'SIMILARITY']
  # returns contents in the CC lines.
  # * Bio::SPTR#cc -> Hash
  #
  # returns an object of contents in the TOPIC.
  # * Bio::SPTR#cc(TOPIC) -> Array w/in Hash, Hash
  #
  # returns contents of the "ALTERNATIVE PRODUCTS".
  # * Bio::SPTR#cc('ALTERNATIVE PRODUCTS') -> Hash
  #    {'Event' => str, 
  #     'Named isoforms' => int,  
  #     'Comment' => str,
  #     'Variants'=>[{'Name' => str, 'Synonyms' => str, 'IsoId' => str, 'Sequence' => []}]}
  # 
  #    CC   -!- ALTERNATIVE PRODUCTS:
  #    CC       Event=Alternative splicing; Named isoforms=15;
  #    ...
  #    CC         placentae isoforms. All tissues differentially splice exon 13;
  #    CC       Name=A; Synonyms=no del;
  #    CC         IsoId=P15529-1; Sequence=Displayed;
  #
  # returns contents of the "DATABASE".
  # * Bio::SPTR#cc('DATABASE') -> Array
  #    [{'NAME'=>str,'NOTE'=>str, 'WWW'=>URI,'FTP'=>URI}, ...]
  #
  #    CC   -!- DATABASE: NAME=Text[; NOTE=Text][; WWW="Address"][; FTP="Address"].
  #
  # returns contents of the "MASS SPECTROMETRY".
  # * Bio::SPTR#cc('MASS SPECTROMETRY') -> Array
  #    [{'MW"=>float,'MW_ERR'=>float, 'METHOD'=>str,'RANGE'=>str}, ...]
  #
  #    CC   -!- MASS SPECTROMETRY: MW=XXX[; MW_ERR=XX][; METHOD=XX][;RANGE=XX-XX].
  #
  # === CC lines (>=0, optional)
  #   CC   -!- TISSUE SPECIFICITY: HIGHEST LEVELS FOUND IN TESTIS. ALSO PRESENT
  #   CC       IN LIVER, KIDNEY, LUNG AND BRAIN.
  # 
  #   CC   -!- TOPIC: FIRST LINE OF A COMMENT BLOCK;
  #   CC       SECOND AND SUBSEQUENT LINES OF A COMMENT BLOCK.
  #
  # See also http://www.expasy.org/sprot/userman.html#CC_line
  #
  def cc(topic = nil)
    unless @data['CC']
      cc  = Hash.new
      comment_border= '-' * (77 - 4 + 1)
      dlm = /-!- /

      # 12KD_MYCSM has no CC lines.
      return cc if get('CC').size == 0
      
      cc_raw = fetch('CC')

      # Removing the copyright statement.
      cc_raw.sub!(/ *---.+---/m, '')

      # Not any CC Lines without the copyright statement.
      return cc if cc_raw == ''

      begin
        cc_raw, copyright = cc_raw.split(/#{comment_border}/)[0]
        cc_raw = cc_raw.sub(dlm,'')
        cc_raw.split(dlm).each do |tmp|
          tmp = tmp.strip

          if /(^[A-Z ]+[A-Z]): (.+)/ =~ tmp
            key  = $1
            body = $2
            body.gsub!(/- (?!AND)/,'-')
            body.strip!
            unless cc[key]
              cc[key] = [body]
            else
              cc[key].push(body)
            end
          else
            raise ["Error: [#{entry_id}]: CC Lines", '"', tmp, '"',
                   '', get('CC'),''].join("\n")
          end
        end
      rescue NameError
        if fetch('CC') == ''
          return {}
        else
          raise ["Error: Invalid CC Lines: [#{entry_id}]: ",
                 "\n'#{self.get('CC')}'\n", "(#{$!})"].join
        end
      rescue NoMethodError
      end
      
      @data['CC'] = cc
    end


    case topic
    when 'ALLERGEN'
      return @data['CC'][topic]
    when 'ALTERNATIVE PRODUCTS'
      return cc_alternative_products(@data['CC'][topic])
    when 'BIOPHYSICOCHEMICAL PROPERTIES'
      return cc_biophysiochemical_properties(@data['CC'][topic])
    when 'BIOTECHNOLOGY'
      return @data['CC'][topic]
    when 'CATALITIC ACTIVITY'
      return cc_catalytic_activity(@data['CC'][topic])
    when 'CAUTION'
      return cc_caution(@data['CC'][topic])
    when 'COFACTOR'
      return @data['CC'][topic]
    when 'DEVELOPMENTAL STAGE'
      return @data['CC'][topic].to_s
    when 'DISEASE'
      return @data['CC'][topic].to_s
    when 'DOMAIN'
      return @data['CC'][topic]
    when 'ENZYME REGULATION'
      return @data['CC'][topic].to_s
    when 'FUNCTION'
      return @data['CC'][topic].to_s
    when 'INDUCTION'
      return @data['CC'][topic].to_s
    when 'INTERACTION'
      return cc_interaction(@data['CC'][topic])
    when 'MASS SPECTROMETRY'
      return cc_mass_spectrometry(@data['CC'][topic])
    when 'MISCELLANEOUS'
      return @data['CC'][topic]
    when 'PATHWAY'
      return cc_pathway(@data['CC'][topic])
    when 'PHARMACEUTICAL'
      return @data['CC'][topic]
    when 'POLYMORPHISM'
      return @data['CC'][topic]
    when 'PTM'
      return @data['CC'][topic]
    when 'RNA EDITING'
      return cc_rna_editing(@data['CC'][topic])
    when 'SIMILARITY'
      return @data['CC'][topic]
    when 'SUBCELLULAR LOCATION'
      return cc_subcellular_location(@data['CC'][topic])
    when 'SUBUNIT'
      return @data['CC'][topic]
    when 'TISSUE SPECIFICITY'
      return @data['CC'][topic]
    when 'TOXIC DOSE'
      return @data['CC'][topic]
    when 'WEB RESOURCE'
      return cc_web_resource(@data['CC'][topic])
    when 'DATABASE'
      # DATABASE: NAME=Text[; NOTE=Text][; WWW="Address"][; FTP="Address"].
      tmp = Array.new
      db = @data['CC']['DATABASE']
      return db unless db

      db.each do |e|
        db = {'NAME' => nil, 'NOTE' => nil, 'WWW' => nil, 'FTP' => nil}
        e.sub(/.$/,'').split(/;/).each do |line|
          case line
          when /NAME=(.+)/
            db['NAME'] = $1
          when /NOTE=(.+)/
            db['NOTE'] = $1
          when /WWW="(.+)"/
            db['WWW'] = $1
          when /FTP="(.+)"/
            db['FTP'] = $1
          end 
        end
        tmp.push(db)
      end
      return tmp
    when nil
      return @data['CC']
    else
      return @data['CC'][topic]
    end
  end


  def cc_alternative_products(data)
    ap = data.to_s
    return ap unless ap

    # Event, Named isoforms, Comment, [Name, Synonyms, IsoId, Sequnce]+
    tmp = {'Event' => "", 'Named isoforms' => "", 'Comment' => "", 
           'Variants'  => []}
    if /Event=(.+?);/ =~ ap
      tmp['Event'] = $1
      tmp['Event'] = tmp['Event'].sub(/;/,'').split(/, /)
    end
    if /Named isoforms=(\S+?);/ =~ ap
      tmp['Named isoforms'] = $1
    end
    if /Comment=(.+?);/m =~ ap
      tmp['Comment'] = $1
    end
    ap.scan(/Name=.+?Sequence=.+?;/).each do |ent|
      tmp['Variants'] << cc_alternative_products_variants(ent)
    end
    return tmp
  end
  private :cc_alternative_products

  def cc_alternative_products_variants(data)
    variant = {'Name' => '', 'Synonyms' => [], 'IsoId' => [], 'Sequence' => []}
    data.split(/; /).map {|x| x.split(/=/) }.each do |e|
      case e[0]
      when 'Sequence', 'Synonyms', 'IsoId'
        e[1] = e[1].sub(/;/,'').split(/, /)
      end
      variant[e[0]] = e[1]
    end
    variant
  end
  private :cc_alternative_products_variants


  def cc_biophysiochemical_properties(data)
    data = data[0]

    hash = {'Absorption' => {}, 
            'Kinetic parameters' => {},
            'pH dependence' => "",
            'Redox potential' => "",
            'Temperature dependence' => ""}
    if data =~ /Absorption: Abs\(max\)=(.+?);/
      hash['Absorption']['Abs(max)'] = $1
    end
    if data =~ /Absorption: Abs\(max\)=.+; Note=(.+?);/
      hash['Absorption']['Note'] = $1
    end
    if data =~ /Kinetic parameters: KM=(.+?); Vmax=(.+?);/
      hash['Kinetic parameters']['KM'] = $1
      hash['Kinetic parameters']['Vmax'] = $2
    end
    if data =~ /Kinetic parameters: KM=.+; Vmax=.+; Note=(.+?);/
      hash['Kinetic parameters']['Note'] = $1
    end
    if data =~ /pH dependence: (.+?);/
      hash['pH dependence'] = $1
    end
    if data =~ /Redox potential: (.+?);/
      hash['Redox potential'] = $1
    end
    if data =~ /Temperature dependence: (.+?);/
      hash['Temperature dependence'] = $1
    end
    hash
  end
  private :cc_biophysiochemical_properties


  def cc_caution(data)
    data.to_s
  end
  private :cc_caution


  # returns conteins in a line of the CC INTERACTION section.
  #
  #   CC       P46527:CDKN1B; NbExp=1; IntAct=EBI-359815, EBI-519280;
  def cc_interaction(data)
    str = data.to_s
    it = str.scan(/(.+?); NbExp=(.+?); IntAct=(.+?);/)
    it.map {|ent|
      ent.map! {|x| x.strip }
      if ent[0] =~ /^(.+):(.+)/
        spac = $1
        spid = $2.split(' ')[0]
        optid = nil
      elsif ent[0] =~ /Self/
        spac = self.entry_id
        spid = self.entry_id
        optid = nil
      end
      if ent[0] =~ /^.+:.+ (.+)/
        optid = $1
      end

      {'SP_Ac' => spac,
       'identifier' => spid,
       'NbExp' => ent[1],
       'IntAct' => ent[2].split(', '),
       'optional_identifier' => optid}
    }
  end
  private :cc_interaction


  def cc_mass_spectrometry(data)
    # MASS SPECTROMETRY: MW=XXX[; MW_ERR=XX][; METHOD=XX][;RANGE=XX-XX].
    return data unless data

    data.map { |m|
      mass = {'MW' => nil, 'MW_ERR' => nil, 'METHOD' => nil, 'RANGE' => nil,
              'NOTE' => nil}
      m.sub(/.$/,'').split(/;/).each do |line|
        case line
        when /MW=(.+)/
          mass['MW'] = $1
        when /MW_ERR=(.+)/
          mass['MW_ERR'] = $1
        when /METHOD=(.+)/
          mass['METHOD'] = $1
        when /RANGE=(\d+-\d+)/ 
          mass['RANGE'] = $1          # RANGE class ? 
        when /NOTE=(.+)/
          mass['NOTE'] = $1
        end 
      end
      mass
    }
  end
  private :cc_mass_spectrometry


  def cc_pathway(data)
    data.map {|x| x.sub(/\.$/, '') }.map {|x|
      x.split(/; | and |: /)
    }[0]
  end
  private :cc_pathway


  def cc_rna_editing(data)
 data = data.to_s
    entry = {'Modified_positions' => [], 'Note' => ""}
    if data =~ /Modified_positions=(.+?)(\.|;)/
      entry['Modified_positions'] = $1.sub(/\.$/, '').split(', ')
    else
      raise ArgumentError, "Invarid CC RNA Editing lines (#{self.entry_id}):#{$!}\n#{get('CC')}"
    end
    if data =~ /Note=(.+)/
      entry['Note'] = $1
    end
    entry
  end
  private :cc_rna_editing


  def cc_subcellular_location(data)
    data.map {|x| 
      x.split('. ').map {|y| 
        y.split('; ').map {|z| 
          z.sub(/\.$/, '') 
        } 
      } 
    }[0]
  end
  private :cc_subcellular_location

  
  # CC   -!- WEB RESOURCE: NAME=ResourceName[; NOTE=FreeText][; URL=WWWAddress].  
  def cc_web_resource(data)
    data.map {|x|
      entry = {'NAME' => nil, 'NOTE' => nil, 'URL' => nil}
      x.split(';').each do |y|
        case y
        when /NAME=(.+)/
          entry['NAME'] = $1.strip
        when /NOTE=(.+)/
          entry['NOTE'] = $1.strip
        when /URL="(.+)"/
          entry['URL'] = $1.strip
        end
      end
      entry
    }
  end
  

  # returns databases cross-references in the DR lines.
  # * Bio::SPTR#dr  -> Hash w/in Array
  #
  # === DR Line; defabases cross-reference (>=0)
  #    DR  database_identifier; primary_identifier; secondary_identifier.
  #  a cross_ref pre one line
  @@dr_database_identifier = ['EMBL','CARBBANK','DICTYDB','ECO2DBASE',
    'ECOGENE',
    'FLYBASE','GCRDB','HIV','HSC-2DPAGE','HSSP','INTERPRO','MAIZEDB',
    'MAIZE-2DPAGE','MENDEL','MGD''MIM','PDB','PFAM','PIR','PRINTS',
    'PROSITE','REBASE','AARHUS/GHENT-2DPAGE','SGD','STYGENE','SUBTILIST',
    'SWISS-2DPAGE','TIGR','TRANSFAC','TUBERCULIST','WORMPEP','YEPD','ZFIN']

  # Backup Bio::EMBLDB#dr as embl_dr
  alias :embl_dr :dr 

  # Bio::SPTR#dr
  def dr(key = nil)
    unless key
      embl_dr
    else
      embl_dr[key].map {|x|
        {'Accession' => x[0],
         'Version' => x[1],
         ' ' => x[2],
         'Molecular Type' => x[3]}
      }
    end
  end


  # Bio::EMBLDB::Common#kw - Array
  #                    #keywords  -> Array
  #
  # KW Line; keyword (>=1)
  # KW   [Keyword;]+


  # returns contents in the feature table.
  #
  # == Examples
  #
  #  sp = Bio::SPTR.new(entry)
  #  ft = sp.ft
  #  ft.class #=> Hash
  #  ft.keys.each do |feature_key|
  #    ft[feature_key].each do |feature|
  #      feature['From'] #=> '1'
  #      feature['To']   #=> '21'
  #      feature['Description'] #=> ''
  #      feature['FTId'] #=> ''
  #      feature['diff'] #=> []
  #      feature['original'] #=> [feature_key, '1', '21', '', '']
  #    end
  #  end
  #
  # * Bio::SPTR#ft -> Hash
  #    {FEATURE_KEY => [{'From' => int, 'To' => int, 
  #                      'Description' => aStr, 'FTId' => aStr,
  #                      'diff' => [original_residues, changed_residues],
  #                      'original' => aAry }],...}
  #
  # returns an Array of the information about the feature_name in the feature table.
  # * Bio::SPTR#ft(feature_name) -> Array of Hash
  #    [{'From' => str, 'To' => str, 'Description' => str, 'FTId' => str},...]
  #
  # == FT Line; feature table data (>=0, optional)
  #
  #   Col     Data item
  #   -----   -----------------
  #    1- 2   FT
  #    6-13   Feature name 
  #   15-20   `FROM' endpoint
  #   22-27   `TO' endpoint
  #   35-75   Description (>=0 per key)
  #   -----   -----------------
  #
  # Note: 'FROM' and 'TO' endopoints are allowed to use non-numerial charactors 
  # including '<', '>' or '?'. (c.f. '<1', '?42')
  #
  # See also http://www.expasy.org/sprot/userman.html#FT_line
  #
  def ft(feature_key = nil)
    return ft[feature_key] if feature_key
    return @data['FT'] if @data['FT']

    table = []
    begin
      get('FT').split("\n").each do |line|
        if line =~ /^FT   \w/
          feature = line.chomp.ljust(74)
          table << [feature[ 5..12].strip,   # Feature Name
                    feature[14..19].strip,   # From
                    feature[21..26].strip,   # To
                    feature[34..74].strip ]  # Description
        else
          table.last << line.chomp.sub!(/^FT +/, '')
        end
      end

      # Joining Description lines
      table = table.map { |feature| 
        ftid = feature.pop if feature.last =~ /FTId=/
        if feature.size > 4
          feature = [feature[0], 
                     feature[1], 
                     feature[2], 
                     feature[3, feature.size - 3].join(" ")]
        end
        feature << if ftid then ftid else '' end
      }

      hash = {}
      table.each do |feature|
        hash[feature[0]] = [] unless hash[feature[0]]
        hash[feature[0]] << {
          # Removing '<', '>' or '?' in FROM/TO endopoint.
          'From' => feature[1].sub(/\D/, '').to_i,  
          'To'   => feature[2].sub(/\D/, '').to_i, 
          'Description' => feature[3], 
          'FTId' => feature[4].to_s.sub(/\/FTId=/, '').sub(/\.$/, ''),
          'diff' => [],
          'original' => feature
        }

        case feature[0]
        when 'VARSPLIC', 'VARIANT', 'VAR_SEQ', 'CONFLICT'
          case hash[feature[0]].last['Description']
          when /(\w[\w ]*\w*) - ?> (\w[\w ]*\w*)/
            original_res = $1
            changed_res = $2
            original_res = original_res.gsub(/ /,'').strip
            chenged_res = changed_res.gsub(/ /,'').strip
          when /Missing/i
            original_res = seq.subseq(hash[feature[0]].last['From'],
                                      hash[feature[0]].last['To'])
            changed_res = ''
          end
          hash[feature[0]].last['diff'] = [original_res, chenged_res]
        end
      end
    rescue
      raise "Invalid FT Lines(#{$!}) in #{entry_id}:, \n'#{self.get('FT')}'\n"
    end

    @data['FT'] = hash
  end



  # returns a Hash of conteins in the SQ lines.
  # * Bio::SPTRL#sq  -> hsh
  #
  # returns a value of a key given in the SQ lines.
  # * Bio::SPTRL#sq(key)  -> int or str
  # * Keys: ['MW', 'mw', 'molecular', 'weight', 'aalen', 'len', 'length', 
  #          'CRC64']
  #
  # === SQ Line; sequence header (1/entry)
  #    SQ   SEQUENCE   233 AA;  25630 MW;  146A1B48A1475C86 CRC64;
  #    SQ   SEQUENCE  \d+ AA; \d+ MW;  [0-9A-Z]+ CRC64;
  #
  # MW, Dalton unit.
  # CRC64 (64-bit Cyclic Redundancy Check, ISO 3309).
  def sq(key = nil)
    unless @data['SQ']
      if fetch('SQ') =~ /(\d+) AA\; (\d+) MW; (.+) CRC64;/
        @data['SQ'] = { 'aalen' => $1.to_i, 'MW' => $2.to_i, 'CRC64' => $3 }
      else
        raise "Invalid SQ Line: \n'#{fetch('SQ')}'"
      end
    end

    if key
      case key
      when /mw/, /molecular/, /weight/
        @data['SQ']['MW']
      when /len/, /length/, /AA/
        @data['SQ']['aalen']
      else
        @data['SQ'][key]
      end
    else 
      @data['SQ']
    end
  end


  # returns a Bio::Sequence::AA of the amino acid sequence.
  # * Bio::SPTR#seq -> Bio::Sequence::AA
  #
  # blank Line; sequence data (>=1)
  def seq
    unless @data['']
      @data[''] = Sequence::AA.new( fetch('').gsub(/ |\d+/,'') )
    end
    return @data['']
  end
  alias aaseq seq

end # class SPTR

end # module Bio



=begin

= Bio::SPTR < Bio::DB

Class for a entry in the SWISS-PROT/TrEMBL database.

  * ((<URL:http://www.ebi.ac.uk/swissprot/>))
  * ((<URL:http://www.ebi.ac.uk/trembl/>))
  * ((<URL:http://www.ebi.ac.uk/sprot/userman.html>))
  

--- Bio::SPTR.new(a_sp_entry)

=== ID line (Identification)

--- Bio::SPTR#id_line -> {'ENTRY_NAME' => str, 'DATA_CLASS' => str,
                          'MOLECULE_TYPE' => str, 'SEQUENCE_LENGTH' => int }  
--- Bio::SPTR#id_line(key) -> str

       key = (ENTRY_NAME|MOLECULE_TYPE|DATA_CLASS|SEQUENCE_LENGTH)

--- Bio::SPTR#entry_id -> str
--- Bio::SPTR#molecule -> str
--- Bio::SPTR#sequence_length -> int
    

=== AC lines (Accession number)

--- Bio::SPTR#ac -> ary
--- Bio::SPTR#accessions -> ary
--- Bio::SPTR#accession -> accessions.first

 
=== GN line (Gene name(s))

--- Bio::SPTR#gn -> [ary, ...] or [{:name => str, :synonyms => [], :loci => [], :orfs => []}]
--- Bio::SPTR#gene_name -> str
--- Bio::SPTR#gene_names -> [str] or [str]


=== DT lines (Date) 

--- Bio::SPTR#dt -> {'created' => str, 'sequence' => str, 'annotation' => str}
--- Bio::SPTR#dt(key) -> str

      key := (created|annotation|sequence)


=== DE lines (Description)

--- Bio::SPTR#de -> str
             #definition -> str

--- Bio::SPTR#protein_name

      Returns the proposed official name of the protein


--- Bio::SPTR#synonyms

      Returns an array of synonyms (unofficial names)

=== KW lines (Keyword)

--- Bio::SPTR#kw -> ary

=== OS lines (Organism species)

--- Bio::SPTR#os -> [{'name' => str, 'os' => str}, ...]

=== OC lines (organism classification)

--- Bio::SPTR#oc -> ary

=== OG line (Organella)

--- Bio::SPTR#og -> ary

=== OX line (Organism taxonomy cross-reference)

--- Bio::SPTR#ox -> {'NCBI_TaxID' => [], ...}

=== RN RC RP RX RA RT RL RG lines (Reference)  

--- Bio::SPTR#ref -> [{'RN' => int, 'RP' => str, 'RC' => str, 'RX' => str, ''RT' => str, 'RL' => str, 'RA' => str, 'RC' => str, 'RG' => str},...]

=== DR lines (Database cross-reference)

--- Bio::SPTR#dr -> {'EMBL' => ary, ...}

=== FT lines (Feature table data)

--- Bio::SPTR#ft -> hsh

=== SQ lines (Sequence header and data)

--- Bio::SPTR#sq -> {'CRC64' => str, 'MW' => int, 'aalen' => int}
--- Bio::SPTR#sq(key) -> int or str

          key := (aalen|MW|CRC64)

--- Bio::EMBL#seq -> Bio::Sequece::AA
             #aaseq -> Bio::Sequece::AA

=end

  #      Content                      Occurrence in an entry
  # ---- ---------------------------  --------------------------------
  # ID - identification               (begins each entry; 1 per entry)
  # AC - accession number(s)          (>=1 per entry)
  # DT - date                         (3 per entry)
  # DE - description                  (>=1 per entry)
  # GN - gene name(s)                 (>=0 per entry; optional)
  # OS - organism species             (>=1 per entry)
  # OG - organelle                    (0 or 1 per entry; optional)
  # OC - organism classification      (>=1 per entry)
  # OX - organism taxonomy x-ref      (>=1 per entry)
  # OH - Organism Host
  # RN - reference number             (>=1 per entry)
  # RP - reference positions          (>=1 per entry)
  # RC - reference comment(s)         (>=0 per entry; optional)
  # RX - reference cross-reference(s) (>=0 per entry; optional)
  # RA - reference author(s)          (>=1 per entry)
  # RT - reference title              (>=0 per entry; optional)
  # RL - reference location           (>=1 per entry)
  # RG - reference group(s)
  # CC - comments or notes            (>=0 per entry; optional)
  # DR - database cross-references    (>=0 per entry; optional)
  # KW - keywords                     (>=1 per entry)
  # FT - feature table data           (>=0 per entry; optional)
  # SQ - sequence header              (1 per entry)
  #    - (blanks) The sequence data   (>=1 per entry)
  # // - termination line             (ends each entry; 1 per entry)
  # ---- ---------------------------  --------------------------------


