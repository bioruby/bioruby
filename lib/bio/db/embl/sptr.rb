#
# bio/db/embl/sptr.rb - SwissProt and TrEMBL database class
# 
#   Copyright (C) 2001,2002,2003 Mitsuteru C. Nakao <n@bioruby.org>
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
#  $Id: sptr.rb,v 1.16 2003/03/16 18:01:39 n Exp $
#

require 'bio/db/embl'

module Bio

  class SPTR < EMBLDB

    include EMBL_COMMON
    

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

      if block_given?
	@data['ID'].each do |k,v|
	  yield k,v
	end
      elsif key
	@data['ID'][key]	# String/Int
      else
	@data['ID']		# Hash
      end
    end

    def entry
      id_line('ENTRY_NAME')
    end
    alias entry_name entry
    alias entry_id entry

    def molecule
      id_line('MOLECULE_TYPE')
    end
    alias molecule_type molecule

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
    # Bio::SPTR#ac  -> Array
    #          #accessions  -> Array

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
	a = self.get('DT').split("\n")
	tmp['created']    = a[0].sub(/\w{2}   /,'').strip
	tmp['sequence']   = a[1].sub(/\w{2}   /,'').strip
	tmp['annotation'] = a[2].sub(/\w{2}   /,'').strip
	@data['DT'] = tmp
      end
      if block_given?
	@data['DT'].each do |k,v|
	  yield k,v
	end
      elsif key
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
    def gn 
      unless @data['GN']
	begin
	  names = fetch('GN').sub(/\.$/,'').split(' AND ')
	  names.collect! {|synonyms|
	    synonyms = synonyms.gsub('\(|\)','').split(' OR ').collect {|e|
	      e.strip 
	    }
	  }
	end
	@data['GN'] = names
      end
      @data['GN']
    end
    alias gene_names gn

    # Bio::SPTR#gene_name -> String
    #
    def gene_name
      begin
	@data['GN'][0][0]
      rescue NameError
	nil
      end
    end

    # OS Line; organism species (>=1)
    # "OS   Trifolium repens (white clover)"
    #
    # OS   Genus species (name).
    # OS   Genus species (name0) (name1).
    # OS   Genus species (name0) (name1).
    # OS   Genus species (name0), G s0 (name0), and G s (name1).
    #
    # Bio::EMBLDB#os  -> Array w/in Hash
    # [{'name'=>'Human', 'os'=>'Homo sapiens'}, 
    #  {'name'=>'Rat', 'os'=>'Rattus norveticus'}]
    # Bio::EMBLDB#os[0]['name'] => "Human"
    # Bio::EMBLDB#os[0] => {'name'=>"Human", 'os'=>'Homo sapiens'}
    # Bio::EMBLDB#os(0) => "Homo sapiens (Human)"
    #
    # Bio::SPTR#os -> Array w/in Hash
    # Bio::SPTR#os(num) -> String
    

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
	tmp = fetch('OX').sub(/\.$/,'').split(';').collect {|e| e.strip }
	hsh = Hash.new
	tmp.each do |e|
	  db,refs = e.split('=')
	  hsh[db] = refs.split(/, */)
	end
	@data['OX'] = hsh
      else
	@data['OX']
      end
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
    # Bio::SPTR#cc('DATABASE') -> [{'NAME'=>String,'NOTE'=>String,
    #                               'WWW'=>URI,'FTP'=>URI}]
    # Bio::SPTR#cc('MASS SPECTROMETRY') -> [{'MW"=>Float,'MW_ERR'=>Float,
    #                                        'METHOD'=>String,'RANGE'=>String}]
    #
    def cc(num = nil)
      # @data['CC'] = {'DATABASE'=>['hoge','fuga']}
      unless @data['CC']
	cc = Hash.new
	cmt = '-' * (77 - 4 + 1)
	dlm = /-!- /

	begin
	  fetch('CC').split(cmt)[0].sub(dlm,'').split(dlm).each do |tmp|
	    if tmp =~ /(^[A-Z ]+): (.+)[\.!]/
	      unless cc['$1']
		cc[$1] = [$2]
	      else
		cc[$1].puch($2)
	      end
	    else
	      raise "Error: CC Lines \n\n#{tmp.inspect}\n\n#{fetch('CC')}\n";
	    end
	  end
	rescue NameError
	  if fetch('CC') == ''
            return {}
          else
	    raise "Invalid CC Lines, \n'#{self.get('CC').inspect}'\n"
          end
	end

	@data['CC'] = cc
      else
      end

      case num
      when 'DATABASE'
	# DATABASE: NAME=Text[; NOTE=Text][; WWW="Address"][; FTP="Address"].
	tmp = Array.new
	@data['CC']['DATABASE'].each do |e|
	  db = {'NAME'=>nil,'NOTE'=>nil,'WWW'=>nil,'FTP'=>nil}
	  e.sub(/.$/,'').split(';').each do |l|
	    case l
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
	@data['CC']['MASS SPECTOROMETRY'].each do |m|
	  mass = {'MW'=>nil,'MW_ERR'=>nil,'METHOD'=>nil,'RANGE'=>nil}
	  m.sub(/.$/,'').split(';').each do |l|
	    case l
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
	return @data['CC'][num]
      end
    end


    # DR Line; defabases cross-reference (>=0)
    # a cross_ref pre one line
    # "DR  database_identifier; primary_identifier; secondary_identifier."
    # Bio::EMBLDB#dr  -> Hash w/in Array

    @@dr_database_identifier = ['EMBL','CARBBANK','DICTYDB','ECO2DBASE','ECOGENE',
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
    # Bio::SPTR#ft -> {'feature_name'=>[{'From'=>String,'To'=>String,
    #                                    'Description'=>String}],}
    # Bio::SPTR#ft(feature_name) -> [{'From'=>String,'To'=>String,
    #                                 'Description'=>String},...]
    def ft(feature_name = nil)
      unless @data['FT']
	table        = Hash.new()
	last_feature = nil

	begin
	  get('FT').split("\n").each {|line|
	    feature = line[5..12].strip

	    if feature == '' and line[34..74]
	      tmp = ' ' + line[34..74].strip 
	      table[last_feature].last['Description'] << tmp

	    else
	      from = line[14..19].strip
	      to   = line[21..26].strip
	      desc = line[34..74].strip mbox.kyoto-inet.or.jpif line[34..74]

	      table[feature] = [] unless table[feature]
	      table[feature] << {'From' => from, 'To' => to, 'Description' => desc}
	      last_feature = feature
	    end
	  }
	rescue
	  raise "Invalid FT Lines(#{$!}):, \n'#{self.get('FT')}'\n"
	end

	table.each_key {|k|
	  table[k].each {|e|
	    if / -> / =~ e['Description']
	      e['Description'].sub!(/([A-Z][A-Z ]+[A-Z]) -> ([A-Z][A-Z ]+[A-Z])/){ 
		a = $1
		b = $2
		a.gsub(' ','') + " -> " + b.gsub(' ','') 
	      }
	    end
	  }
	}

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
    # Bio::SPTRL#sq  -> Hash
    #
    def sq(key = nil)
      unless @data['SQ']
	if fetch('SQ') =~ /(\d+) AA\; (\d+) MW; (.+) CRC64;/
	  @data['SQ'] = { 'aalen'=>$1.to_i, 'MW'=>$2.to_i, 'CRC64'=>$3 }
	else
	  raise "Invalid SQ Line: \n'#{fetch('SQ')}'"
	end
      end

      if block_given?
	@data['SQ'].each do |k,v|
	  yield(k,v)
	end
      elsif key
	case key
	when /mw/,/molecular/,/weight/
	  @data['SQ']['MW']
	when /len/,/length/,/AA/
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
	@data[''] = Sequence::AA.new( fetch('').gsub(/ /,'').gsub(/\d+/,'') )
      else
	@data['']
      end
    end
    alias aaseq seq

  end

end


if __FILE__ == $0
end


=begin

= Bio::SPTR

=== Initialize

--- Bio::SPTR.new(a_sp_entry)

=== ID line (Identification)

--- Bio::SPTR#id_line -> Hash
--- Bio::SPTR#id_line(key) -> String

       key = (ENTRY_NAME|MOLECULE_TYPE|DATA_CLASS|SEQUENCE_LENGTH)

--- Bio::SPTR#entry -> String
--- Bio::SPTR#entryname -> String
--- Bio::SPTR#molecule -> String
--- Bio::SPTR#division -> String
--- Bio::SPTR#sequencelength -> Int
    
=== AC lines (Accession number)

--- Bio::SPTR#ac -> Array
--- Bio::SPTR#accession -> String
 
=== GN line (Gene name(s))

--- Bio::SPTR#gn -> Array(Array)
--- Bio::SPTR#gene_name -> Bio::SPTR#gn[0][0]

=== DT lines (Date) 

--- Bio::SPTR#dt -> Hash
--- Bio::SPTR#dt(key) -> String

      key = (created|annotation|sequence)

--- Bio::SPTR.dt['updated']

=== DE lines (Description)

--- Bio::SPTR#de -> String
             #definition -> String

=== KW lines (Keyword)

--- Bio::SPTR#kw -> Array

=== OS lines (Organism species)

--- Bio::SPTR#os -> Array

=== OC lines (organism classification)

--- Bio::SPTR#oc -> Array

=== OG line (Organella)

--- Bio::SPTR#og -> String

=== OX line (Organism taxonomy cross-reference)

--- Bio::SPTR#ox -> Hash

=== RN RC RP RX RA RT RL lines (Reference)  

--- Bio::SPTR#ref -> Array

=== DR lines (Database cross-reference)

--- Bio::SPTR#dr -> Hash
--- Bio::SPTR#dr(dbname) -> Array

=== FT lines (Feature table data)

--- Bio::SPTR#ft -> Hash
--- Bio::SPTR#ft(feature_name) -> Array

=== SQ lines (Sequence header and data)

--- Bio::SPTR#sq -> Hash
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

