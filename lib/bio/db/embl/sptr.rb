#
# bio/db/embl/sptr.rb - SwissProt and TrEMBL database class
# 
#   Copyright (C) 2001-2003 Mitsuteru C. Nakao <n@bioruby.org>
#
#  This library is free software; you can redistribute it and/or
#  modify it under the terms of the GNU Lesser General Public
#  License as published by the Free Software Foundation; either
#  version 2 of the License, or (at your option) any later version.
#
#  This library is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
#  Lesser General Public License for more details.
#
#  You should have received a copy of the GNU Lesser General Public
#  License along with this library; if not, write to the Free Software
#  Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307  USA
#
#  $Id: sptr.rb,v 1.24 2005/08/08 06:41:13 nakao Exp $
#

require 'bio/db'

module Bio

class SPTR < EMBLDB

  require 'bio/db/embl/common'
  include Bio::EMBL::Common
    

  # ID Line
  #
  # "ID  #{ENTRY_NAME} #{DATA_CLASS}; #{MOLECULE_TYPE}; #{SEQUENCE_LENGTH}."
  #
  #   ENTRY_NAME = "#{X}_#{Y}"
  #     X =~ /[A-Z0-9]{1,4}/ # The protein name.
  #     Y =~ /[A-Z0-9]{1,5}/ # The biological source of the protein.
  #   MOLECULE_TYPE = 'PRT' =~ /\w{3}/ 
  #   SEQUENCE_LENGTH =~ /\d+ AA/
  #
  # See also the SWISS-PROT dicument file SPECLIST.TXT.
  #

  @@entry_regrexp = /[A-Z0-9]{1,4}_[A-Z0-9]{1,5}/
  @@data_class = ["STANDARD", "PRELIMINARY"]

  # Bio::SPTR#id_line -> hsh
  # Bio::SPTR#id_line(key) -> str or int
  def id_line(key = nil)
    unless @data['ID']
      tmp = Hash.new
      a = @orig['ID'].split(/ +/)         
      tmp['ENTRY_NAME']      = a[1]
      tmp['DATA_CLASS']      = a[2].sub(/;/,'') 
      tmp['MOLECULE_TYPE']   = a[3].sub(/;/,'')
      tmp['SEQUENCE_LENGTH'] = a[4].to_i
      @data['ID'] = tmp
    end

    if key
      @data['ID'][key]	# String/Int
    else
      @data['ID']		# Hash
    end
  end

  #
  def entry
    id_line('ENTRY_NAME')
  end
  alias entry_name entry
  alias entry_id entry

  #
  def molecule
    id_line('MOLECULE_TYPE')
  end
  alias molecule_type molecule

  #
  def sequence_length
    id_line('SEQUENCE_LENGTH')
  end
  alias aalen sequence_length


  # AC Line
  #
  # "AC   A12345; B23456;"
  #
  #   AC [AC1;]+
  #
  #   Accession numbers format:
  #   1       2     3          4          5          6
  #   [O,P,Q] [0-9] [A-Z, 0-9] [A-Z, 0-9] [A-Z, 0-9] [0-9]
  #
  # Bio::SPTR#ac  -> ary
  #          #accessions  -> ary
  #          #accession  -> accessions.first

  @@ac_regrexp = /[OPQ][0-9][A-Z0-9]{3}[0-9]/ 


  # DT Line; date (3/entry)
  # DT DD-MMM-YYY (rel. NN, Created)
  # DT DD-MMM-YYY (rel. NN, Last sequence update)
  # DT DD-MMM-YYY (rel. NN, Last annotation update)
  #
  # Bio::SPTR#dt  -> Hash
  # Bio::SPTR#dt(key)  -> String
  # key = (created|sequence|annotation)
  def dt(key = nil)
    unless @data['DT']
      tmp = Hash.new
      a = self.get('DT').split(/\n/)
      tmp['created']    = a[0].sub(/\w{2}   /,'').strip
      tmp['sequence']   = a[1].sub(/\w{2}   /,'').strip
      tmp['annotation'] = a[2].sub(/\w{2}   /,'').strip
      @data['DT'] = tmp
    end

    if key
      @data['DT'][key]
    else
      @data['DT']
    end
  end


  # DE Line; description (>=1)
  # "DE #{OFFICIAL_NAME} (#{SYNONYM})"
  # "DE #{OFFICIAL_NAME} (#{SYNONYM}) [CONTEINS: #1; #2]."
  # OFFICIAL_NAME  1/entry
  # SYNONYM        >=0
  # CONTEINS       >=0
  #
  # Returns the proposed official name of the protein
  def protein_name
    name = ""
    if de_line = fetch('DE') then
      str = de_line[/^[^\[]*/] # everything preceding the first [ (the "contains" part)
      name = str[/^[^(]*/].strip
      name << ' (Fragment)' if str =~ /fragment/i
    end
    return name
  end
  # synonyms are each placed in () following the official name on the DE line
  # Returns an array of synonyms (unofficial names)
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


  # GN Line: Gene name(s) (>=0, optional)
  def gn
    return @data['GN'] if @data['GN']

    case fetch('GN')
    when /Name=/ then
      return gn_uniprot_parser
    else
      return gn_old_parser
    end
  end

  # GN Line: Gene name(s) (>=0, optional)
  # GN   HNS OR DRDX OR OSMZ OR BGLY.
  # GN   CECA1 AND CECA2.
  # GN   CECA1 AND (HOGE OR FUGA).
  #
  # GN NAME1 [(AND|OR) NAME]+.
  #
  # Bio::SPTR#gn -> Array      # AND 
  #          #gn[0] -> Array   # OR
  #          #gene_names -> Array
  #
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
    return @data['GN'] = names
  end
  private :gn_old_parser


  # The new format of the GN line is:
  # GN   Name=; Synonyms=[, ...]; OrderedLocusNames=[, ...];
  # GN   ORFNames=[, ...];
  # 
  # GN   and
  #
  # Bio::SPTR#gn -> [ <gene record>* ]
  #   where <gene record> is:
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


  # Bio::SPTR#gene_names -> [String]
  def gene_names
    gn # set @data['GN'] if it hasn't been already done
    if @data['GN'].first.class == Hash then
      @data['GN'].collect { |element| element[:name] }
    else
      @data['GN'].first
    end
  end


  # Bio::SPTR#gene_name -> String
  #
  def gene_name
    gene_names.first
  end


  # OS Line; organism species (>=1)
  # "OS   Genus species (name)."
  # "OS   Genus species (name0) (name1)."
  # "OS   Genus species (name0) (name1)."
  # "OS   Genus species (name0), G s0 (name0), and G s (name0) (name1)."
  # "OS   Homo sapiens (Human), and Rarrus norveticus (Rat)"
  #
  # Bio::EMBLDB#os  -> Array of Hash
  # [{'name'=>'(Human)', 'os'=>'Homo sapiens'}, 
  #  {'name'=>'(Rat)', 'os'=>'Rattus norveticus'}]
  # Bio::SPTR#os[0]['name'] => "(Human)"
  # Bio::EPTR#os[0] => {'name'=>"(Human)", 'os'=>'Homo sapiens'}
  # Bio::EPTR#os(0) => "Homo sapiens (Human)"
  #
  # Bio::SPTR#os -> Array of Hash
  # Bio::SPTR#os(num) -> String
  def os(num = nil)
    unless @data['OS']
      os = Array.new
      fetch('OS').split(/, and|, /).each do |tmp|
        if tmp =~ /([A-Z][a-z]* *[\w\d \:\'\+\-]+[\w\d])/
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
  

  # OG Line; organella (0 or 1/entry)
  # ["MITOCHONDRION", "CHLOROPLAST", "Cyanelle", "Plasmid"]
  #  or a plasmid name (e.g. "Plasmid pBR322").  
  #
  # Bio::SPTR#og  -> Array


  # OC Line; organism classification (>=1)
  # OC   Eukaryota; Alveolata; Apicomplexa; Piroplasmida; Theileriidae;
  # OC   Theileria.
  #
  # Bio::EMBLDB#oc  -> Array

  # OX Line; organism taxonomy cross-reference (>=1 per entry)
  # OX   NCBI_TaxID=1234;
  # OX   NCBI_TaxID=1234, 2345, 3456, 4567;
  #
  # Bio::SPTR#ox -> {'NCBI_TaxID' => ['1234','2345','3456','4567']}
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


  # R Lines
  # RN RC RP RX RA RT RL
  # Bio::EMBLDB#ref -> Array

  # CC lines (>=0, optional)
  # CC   -!- TISSUE SPECIFICITY: HIGHEST LEVELS FOUND IN TESTIS. ALSO PRESENT
  # CC       IN LIVER, KIDNEY, LUNG AND BRAIN.
  #
  # CC   -!- TOPIC: FIRST LINE OF A COMMENT BLOCK;
  # CC       SECOND AND SUBSEQUENT LINES OF A COMMENT BLOCK.
  #
  # CC   -!- CAUTION: HOGE HOGE IS FUGA FUGA!
  #

  @@cc_topics = ['ALTERNATIVE PRODUCTS','CATALYTIC ACTIVITY','CAUTION',
    'COFACTOR','DATABASE','DEVELOPMENTAL STAGE','DISEASE','DOMAIN',
    'ENZYME REGULATION','FUNCTION','INDUCTION','MASS SPECTROMETRY',
    'MISCELLANEOUS','PATHWAY','PHARMACEUTICAL','POLYMORPHISM','PTM',
    'SIMILARITY','SUBCELLULAR LOCATION','SUBUNIT','TISSUE SPECIFICITY']

  # DATABASE: NAME=Text[; NOTE=Text][; WWW="Address"][; FTP="Address"].
  # MASS SPECTROMETRY: MW=XXX[; MW_ERR=XX][; METHOD=XX][;RANGE=XX-XX].
  #
  # Bio::SPTR#cc -> Hash w/in Array
  # Bio::SPTR#cc(Int) -> String
  # Bio::SPTR#cc(TOPIC) -> Array w/in Hash
  # Bio::SPTR#cc('ALTERNATIVE PRODUCTS') -> {'Event'=>str, 
  #                                          'Named isoforms'=>int,
  #                                          'Comment'=>str,
  #                                          'Variants'=>[{'Name'=>str,
  #                                                        'Synonyms'=>str,
  #                                                        'IsoId'=>str,
  #                                                        'Sequence'=>[]}]}
  # Bio::SPTR#cc('DATABASE') -> [{'NAME'=>str,'NOTE'=>str,
  #                               'WWW'=>URI,'FTP'=>URI}]
  # Bio::SPTR#cc('MASS SPECTROMETRY') -> [{'MW"=>float,'MW_ERR'=>float,
  #                                        'METHOD'=>str,'RANGE'=>str}]
  #
  def cc(tag = nil)

    # @data['CC'] = {'DATABASE'=>['hoge','fuga'], ... }
    unless @data['CC']
      cc  = Hash.new
      cmt = '-' * (77 - 4 + 1)
      dlm = /-!- /

      return cc if get('CC').size == 0 # 12KD_MYCSM has no CC lines.

      begin
        fetch('CC').split(/#{cmt}/)[0].sub(dlm,'').split(dlm).each do |tmp|
          if /(^[A-Z ]+[A-Z]): (.+)/ =~ tmp
            key  = $1
            body = $2.gsub(/- (?!AND)/,'-')
            unless cc[key]
              cc[key] = [body]
            else
              cc[key].push(body)
            end
          else
            raise ["Error: [#{entry_id}]: CC Lines", '',
                   tmp, '', '', fetch('CC'),''].join("\n")
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


    case tag
    when 'ALTERNATIVE PRODUCTS'
      ap = @data['CC']['ALTERNATIVE PRODUCTS'].to_s
      return ap unless ap

      # CC   -!- ALTERNATIVE PRODUCTS:
      # CC       Event=Alternative splicing; Named isoforms=15;
      # ...
      # CC         placentae isoforms. All tissues differentially splice exon 13;
      # CC       Name=A; Synonyms=no del;
      # CC         IsoId=P15529-1; Sequence=Displayed;

      # Event, Named isoforms, Comment, [Name, Synonyms, IsoId, Sequnce]+
      tmp = {'Event' => nil, 'Named isoforms' => nil, 'Comment' => nil, 'Variants'  => []}

      if /Event=(.+?);/ =~ ap
        tmp['Event'] = $1
      end
      if /Named isoforms=(\S+?);/ =~ ap
        tmp['Named isoforms'] = $1
      end
      if /Comment=(.+?);/m =~ ap
        tmp['Comment'] = $1
      end
      ap.scan(/Name=.+?Sequence=.+?;/).each do |ent|
        tmp['Variants'] << cc_ap_variants_parse(ent)
      end
      return tmp


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

    when 'MASS SPECTOROMETRY'
      # MASS SPECTROMETRY: MW=XXX[; MW_ERR=XX][; METHOD=XX][;RANGE=XX-XX].
      tmp = Array.new
      ms = @data['CC']['MASS SPECTOROMETRY']
      return ms unless ms

      ms.each do |m|
        mass = {'MW'=>nil,'MW_ERR'=>nil,'METHOD'=>nil,'RANGE'=>nil}
        m.sub(/.$/,'').split(/;/).each do |line|
          case line
          when /MW=(.+)/
            mass['MW'] = $1.to_f
          when /MW_ERR=(.+)/
            mass['MW_ERR'] = $1.to_f
          when /METHOD="(.+)"/
            mass['METHOD'] = $1.to_s
          when /RANGE="(\d+-\d+)"/ 
            mass['RANGE'] = $1          # RANGE class ? 
          end 
        end
        tmp.push(mass)
      end
      return tmp

    when nil
      return @data['CC']	

    else
      return @data['CC'][tag]
    end
  end


  def cc_ap_variants_parse(ent)
    hsh = {}
    ent.split(/; /).map {|e| e.split(/=/) }.each do |e|
      case e[0]
      when 'Sequence'
        e[1] = e[1].sub(/;/,'').split(/, /)
      end
      hsh[e[0]] = e[1]
    end
    return hsh
  end
  private :cc_ap_variants_parse



  # DR Line; defabases cross-reference (>=0)
  # a cross_ref pre one line
  # "DR  database_identifier; primary_identifier; secondary_identifier."
  # Bio::EMBLDB#dr  -> Hash w/in Array

  @@dr_database_identifier = ['EMBL','CARBBANK','DICTYDB','ECO2DBASE',
    'ECOGENE',
    'FLYBASE','GCRDB','HIV','HSC-2DPAGE','HSSP','INTERPRO','MAIZEDB',
    'MAIZE-2DPAGE','MENDEL','MGD''MIM','PDB','PFAM','PIR','PRINTS',
    'PROSITE','REBASE','AARHUS/GHENT-2DPAGE','SGD','STYGENE','SUBTILIST',
    'SWISS-2DPAGE','TIGR','TRANSFAC','TUBERCULIST','WORMPEP','YEPD','ZFIN']


  # KW Line; keyword (>=1)
  # KW   [Keyword;]+
  # Bio::EMBLDB#kw  -> Array
  #            #keywords  -> Array

  # FT Line; feature table data (>=0, optional)
  #
  # Col     Data item
  # -----   -----------------
  #  1- 2   FT
  #  6-13   Feature name 
  # 15-20   `FROM' endpoint
  # 22-27   `TO' endpoint
  # 35-75   Description (>=0 per key)
  # -----   -----------------
  #
  # Bio::SPTR#ft -> {'feature_name'=>[{'From'=>str,'To'=>str,
  #                                    'Description'=>str, 'FTId'=>str}],}
  # Bio::SPTR#ft(feature_name) -> [{'From'=>str,'To'=>str,
  #                                 'Description'=>str, 'FTId'=>str},...]
  def ft(feature_name = nil)
    unless @data['FT']
      table        = Hash.new()
      last_feature = nil

      begin
        get('FT').split(/\n/).each {|line|

          feature = line[5..12].strip

          if feature == '' and line[34..74]
            tmp = ' ' + line[34..74].strip 
            table[last_feature].last['Description'] << tmp
            
            next unless /\.$/ =~ line
          else
            from = line[14..19].strip
            to   = line[21..26].strip
            desc = line[34..74].strip if line[34..74]

            table[feature] = [] unless table[feature]
            table[feature] << {
              'From'        => from.to_i, 
              'To'          => to.to_i, 
              'Description' => desc,
              'diff'        => [],
              'FTId'        => nil }
            last_feature = feature
            next
          end

          case last_feature
          when 'VARSPLIC', 'VARIANT', 'CONFLICT'
            if /FTId=(.+?)\./ =~ line   # version 41 >
              ftid = $1
              table[last_feature].last['FTId'] = ftid
              table[last_feature].last['Description'].sub!(/ \/FTId=#{ftid}./,'') 
            end

            case table[last_feature].last['Description']
            when /(\w[\w ]*\w*) - ?> (\w[\w ]*\w*)/
              original = $1
              swap = $2
              original = original.gsub(/ /,'').strip
              swap = swap.gsub(/ /,'').strip
            when /Missing/i
              original = seq.subseq(table[last_feature].last['From'],
                                    table[last_feature].last['To'])
              swap = ''
            else
              raise line
            end
            table[last_feature].last['diff'] = [original, swap]
          end
        }

      rescue
        raise "Invalid FT Lines(#{$!}) in #{entry_id}:, \n" + 
                  "'#{self.get('FT')}'\n"
      end

      table.each_key do |k|
        table[k].each do |e|
          if / -> / =~ e['Description']
            pattern = /([A-Z][A-Z ]*[A-Z]*) -> ([A-Z][A-Z ]*[A-Z]*)/
            e['Description'].sub!(pattern) {  
              a = $1
              b = $2
              a.gsub(/ /,'') + " -> " + b.gsub(/ /,'') 
            }
          end
          if /- [\w\d]/ =~ e['Description']
            e['Description'].gsub!(/([\w\d]- [\w\d]+)/) { 
              a = $1
              if /- AND/ =~ a
                a
              else
                a.sub(/ /,'') 
              end
            }
          end
        end
      end
      @data['FT'] = table
    end

    if feature_name
      @data['FT'][feature_name]
    else
      @data['FT']
    end
  end


  # SQ Line; sequence header (1/entry)
  # SQ   SEQUENCE   233 AA;  25630 MW;  146A1B48A1475C86 CRC64;
  # SQ   SEQUENCE  \d+ AA; \d+ MW;  [0-9A-Z]+ CRC64;
  #
  # MW, Dalton unit
  # CRC64 (64-bit Cyclic Redundancy Check, ISO 3309)
  #
  # Bio::SPTRL#sq  -> hsh
  # Bio::SPTRL#sq(key)  -> int or str
  #
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

  # @orig[''] as sequence
  # blank Line; sequence data (>=1)
  # Bio::SPTR#seq  -> Bio::Sequence::AA
  #
  def seq
    unless @data['']
      @data[''] = Sequence::AA.new( fetch('').gsub(/ |\d+/,'') )
    end
    return @data['']
  end
  alias aaseq seq

end

end


if __FILE__ == $0
  # Usage: ruby __FILE__ uniprot_sprot.dat 
  # Usage: ruby __FILE__ uniprot_sprot.dat | egrep '^RuntimeError'

  begin
    require 'pp'
    alias p pp
  rescue LoadErrmr
  end

  def cmd(cmd, tag = nil, ent = $ent)
    puts " ==> #{cmd} "
    puts Bio::SPTR.new(ent).get(tag) if tag
    begin
      p eval(cmd)
    rescue RuntimeError
      puts "RuntimeError(#{Bio::SPTR.new($ent).entry_id})}: #{$!} "
    end
    puts
  end


  while $ent = $<.gets(Bio::SPTR::RS)
    
    cmd "Bio::SPTR.new($ent).entry_id"

    cmd "Bio::SPTR.new($ent).id_line", 'ID'
    cmd "Bio::SPTR.new($ent).entry"
    cmd "Bio::SPTR.new($ent).entry_name"
    cmd "Bio::SPTR.new($ent).molecule"
    cmd "Bio::SPTR.new($ent).sequence_length"

    cmd "Bio::SPTR.new($ent).ac", 'AC'
    cmd "Bio::SPTR.new($ent).accession"


    cmd "Bio::SPTR.new($ent).gn", 'GN'
    cmd "Bio::SPTR.new($ent).gene_name"
    cmd "Bio::SPTR.new($ent).gene_names"

    cmd "Bio::SPTR.new($ent).dt", "DT"
    ['created','annotation','sequence'].each do |key|
      cmd "Bio::SPTR.new($ent).dt('#{key}')"
    end

    cmd "Bio::SPTR.new($ent).de", 'DE'
    cmd "Bio::SPTR.new($ent).definition"
    cmd "Bio::SPTR.new($ent).protein_name"
    cmd "Bio::SPTR.new($ent).synonyms"

    cmd "Bio::SPTR.new($ent).kw", 'KW'

    cmd "Bio::SPTR.new($ent).os", 'OS'

    cmd "Bio::SPTR.new($ent).oc", 'OC'

    cmd "Bio::SPTR.new($ent).og", 'OG'

    cmd "Bio::SPTR.new($ent).ox", 'OX'

    cmd "Bio::SPTR.new($ent).ref", 'R'

    cmd "Bio::SPTR.new($ent).cc", 'CC'
    cmd "Bio::SPTR.new($ent).cc('ALTERNATIVE PRODUCTS')"
    cmd "Bio::SPTR.new($ent).cc('DATABASE')"
    cmd "Bio::SPTR.new($ent).cc('MASS SPECTOMETRY')"

    cmd "Bio::SPTR.new($ent).dr", 'DR'

    cmd "Bio::SPTR.new($ent).ft", 'FT'
    cmd "Bio::SPTR.new($ent).ft['DOMAIN']"

    cmd "Bio::SPTR.new($ent).sq", "SQ"
    cmd "Bio::SPTR.new($ent).seq"
  end

end


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
  # RN - reference number             (>=1 per entry)
  # RP - reference positions          (>=1 per entry)
  # RC - reference comment(s)         (>=0 per entry; optional)
  # RX - reference cross-reference(s) (>=0 per entry; optional)
  # RA - reference author(s)          (>=1 per entry)
  # RT - reference title              (>=0 per entry; optional)
  # RL - reference location           (>=1 per entry)
  # CC - comments or notes            (>=0 per entry; optional)
  # DR - database cross-references    (>=0 per entry; optional)
  # KW - keywords                     (>=1 per entry)
  # FT - feature table data           (>=0 per entry; optional)
  # SQ - sequence header              (1 per entry)
  #    - (blanks) The sequence data   (>=1 per entry)
  # // - termination line             (ends each entry; 1 per entry)
  # ---- ---------------------------  --------------------------------


