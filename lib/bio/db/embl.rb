#
# bio/db/embl.rb - EMBL database class
#
#   Copyright (C) 2001 Mitsuteru S. Nakao <n@bioruby.org>
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
#  $Id: embl.rb,v 1.12 2002/06/25 11:56:14 k Exp $
#


#     ID - identification             (begins each entry; 1 per entry)
#     AC - accession number           (>=1 per entry)
#     SV - sequence version           (1 per entry)
#     DT - date                       (2 per entry)
#     DE - description                (>=1 per entry)
#     KW - keyword                    (>=1 per entry)
#     OS - organism species           (>=1 per entry)
#     OC - organism classification    (>=1 per entry)
#     OG - organelle                  (0 or 1 per entry)
#     RN - reference number           (>=1 per entry)
#     RC - reference comment          (>=0 per entry)
#     RP - reference positions        (>=1 per entry)
#     RX - reference cross-reference  (>=0 per entry)
#     RA - reference author(s)        (>=1 per entry)
#     RT - reference title            (>=1 per entry)
#     RL - reference location         (>=1 per entry)
#     DR - database cross-reference   (>=0 per entry)
#     FH - feature table header       (0 or 2 per entry)
#     FT - feature table data         (>=0 per entry)
#     CC - comments or notes          (>=0 per entry)
#     XX - spacer line                (many per entry)
#     SQ - sequence header            (1 per entry)
#     bb - (blanks) sequence data     (>=1 per entry)
#     // - termination line           (ends each entry; 1 per entry)

require 'bio/db'

module Bio

  module  EMBL_COMMON

    # Shared methods in Bio::EMBL and Bio::SPTR

    # AC Line
    # "AC   A12345; B23456;"
    # AC [AC1;]+
    #
    # Accession numbers format:
    # 1       2     3          4          5          6
    # [O,P,Q] [0-9] [A-Z, 0-9] [A-Z, 0-9] [A-Z, 0-9] [0-9]
    #
    # Bio::SPTR#ac  -> Array
    #          #accessions  -> Array
    def ac
      unless @data['AC']
	tmp = Array.new
	field_fetch('AC').split(' ').each do |e|
	  tmp.push(e.sub(/;/,''))
	end
	@data['AC'] = tmp
      end
      @data['AC']
    end
    alias accessions ac
    # Bio::SPTR#accession  -> String
    def accession
      @data['AC'][0]
    end


    # OS Line; organism species (>=1)
    # "OS   Trifolium repens (white clover)"
    #
    # OS   Genus species (name).
    # OS   Genus species (name0) (name1).
    # OS   Genus species (name0) (name1).
    # OS   Genus species (name0), G s0 (name0), and G s (name1).
    #
    # Bio::EMBL#os  -> Array w/in Hash
    # [{'name'=>'Human', 'os'=>'Homo sapiens'}, 
    #  {'name'=>'Rat', 'os'=>'Rattus norveticus'}]
    # Bio::STPR#os[0]['name'] => "Human"
    # Bio::STPR#os[0] => {'name'=>"Human", 'os'=>'Homo sapiens'}
    # Bio::STPR#os(0) => "Homo sapiens (Human)"
    #
    # Bio::SPTR#os -> Array w/in Hash
    # Bio::SPTR#os(num) -> String
    def os(num = nil)
      unless @data['OS']
	os = Array.new
	fetch('OS').split(',').each do |tmp|
	  if tmp =~ /([A-Z][a-z]+ [a-zA-Z0-9]+)/
	    org = $1
	    tmp =~ /\((.+)\)/ 
	    os.push({'name' => $1, 'os' => org})
	  else
	    raise "Error: OS Line. #{$!}\n#{fetch('OS')}\n"
	  end
	end
	@data['OS'] = os
      end
      if num
	# EX. "Trifolium repens (white clover)"
	"#{@data['OS'][num]['os']} ({#data['OS'][num]['name'])"
      else
	@data['OS']
      end
    end

    # OG Line; organella (0 or 1/entry)
    #
    # Bio::EMBLDB#og  -> Array
    def og
      unless @data['OG']
	og = Array.new
	fetch('OG').sub(/.$/,'').sub(/ and/,'').split(',').each do |tmp|
	  og.push(tmp.strip)
	end
	@data['OG'] = og
      else
	@data['OG']
      end
    end


    # OC Line; organism classification (>=1)
    # OC   Eukaryota; Alveolata; Apicomplexa; Piroplasmida; Theileriidae;
    # OC   Theileria.
    #
    # Bio::EMBLDB#oc  -> Array
    def oc
      unless @data['OC']
	begin
	  @data['OC'] = fetch('OC').sub(/.$/,'').split(';').collect {|e|
	    e.strip 
	  }
	rescue NameError
	  nil
	end
      else
	@data['OC']
      end
    end


    # KW Line; keyword (>=1)
    # KW   [Keyword;]+
    # Bio::EMBLDB#kw  -> Array
    #            #keywords  -> Array
    def kw
      unless @data['KW']
	tmp = fetch('KW').sub(/.$/,'')
	@data['KW'] = tmp.split(';').collect{|e| e.strip }	
      else
	@data['KW']
      end
    end
    alias keywords kw

    # R Lines
    # RN RC RP RX RA RT RL
    # Bio::EMBLDB#ref -> Array
    # to be used Bio::Reference, but not yet implemented.
    def ref
      unless @data['R']
	ary = Array.new
	get('R').split(/\nRN   /).each do |str|
	  raw = {'RN' => '', 'RC' => '', 'RP' => '', 'RX' => '', 
	    'RA' => '', 'RT' => '', 'RL' => ''}
	  str = 'RN   ' + str unless str =~ /^RN   /
	  str.split("\n").each do |line|
	    if line =~ /^(R[NPXARLCT])   (.+)/
	      raw[$1] += $2 + ' '
	    else
	      raise "Invalid format in R lines, \n[#{line}]\n"
	    end
	  end
	  raw.each_value {|v| 
	    v.strip! 
	    v.sub!(/^"/,'')
	    v.sub!(/;$/,'')
	    v.sub!(/"$/,'')
	  }

#	  hash = {'authors' => '',  'title' => '',	    'journal' => '',
#	    'volume' => '',	    'issue' => '',	    'pages' => '',
#	    'year' => '',	    'medline' => '',	    'pubmed' => '' }
#	  raw.each do |k,v|
#	    case k
#	    when 'RA'
#	      hash['authors'] = v
#	    when 'RT'
#	      hash['title'] = v
#	    when 'RL'
#	     journal,volume,issue,pages,year
#	    when 
#	  end

#	  ary.push(Reference.new(hash))
	  ary.push(raw)
	end
#	@data['R'] = References.new(ary)
	@data['R'] = ary
      else
	@data['R']
      end
    end

    # DR Line; defabases cross-reference (>=0)
    # a cross_ref pre one line
    # "DR  database_identifier; primary_identifier; secondary_identifier."
    # Bio::EMBLDB#dr  -> Hash w/in Array
    def dr
      unless @data['DR']
	tmp = Hash.new
	self.get('DR').split("\n").each do |db|
	  a = db.sub(/^DR   /,'').sub(/.$/,'').strip.split(";[ ]")
	  dbname = a.shift
	  tmp[dbname] = Array.new unless tmp[dbname]
	  tmp[dbname].push(a)
	end
	@data['DR'] = tmp
      end
      if block_given?
	@data['DR'].each do |k,v|
	  yield(k,v)
	end
      else
	@data['DR']
      end
    end

  end

end # End of module Bio



module Bio

  class EMBL < EMBLDB

    include EMBL_COMMON
    
    DELIMITER	= RS = "\n//\n"
    TAGSIZE	= 5

    def initialize(entry)
      super(entry, TAGSIZE)
    end


    ###
    ### followings are moved from db.rb, these should be here.
    ### * please do merge & clean-up.
    ### * please use feature.rb and possibly reference.rb.
    ### * please follow the method name conventions described in db.rb's doc.
    ###




    # Methods for EMBL 

    ##
    # ID Line
    # "ID  ENTRY_NAME DATA_CLASS; MOLECULE_TYPE; DIVISION; SEQUENCE_LENGTH BP."
    #
    # DATA_CLASS = ['standard']
    #
    # MOLECULE_TYPE: DNA RNA XXX
    #
    # Code ( DIVISION )
    #  EST (ESTs)
    #  PHG (Bacteriophage)
    #  FUN (Fungi)
    #  GSS (Genome survey)
    #  HTC (High Throughput cDNAs) 
    #  HTG (HTGs)
    #  HUM (Human)
    #  INV (Invertebrates)
    #  ORG (Organelles)
    #  MAM (Other Mammals)
    #  VRT (Other Vertebrates)
    #  PLN (Plants)
    #  PRO (Prokaryotes)
    #  ROD (Rodents)
    #  SYN (Synthetic)
    #  STS (STSs)
    #  UNC (Unclassified)
    #  VRL (Viruses)
    #
    def id_line(key=nil)
      unless @data['ID']
	tmp = Hash.new
	idline = @orig['ID'].split(/ +/)         
	tmp['ENTRY_NAME']      = idline[1]
	tmp['DATA_CLASS']      = idline[2].sub(/;/,'')  
	tmp['MOLECULE_TYPE']   = idline[3].sub(/;/,'')  # "cyclic DNA"
	tmp['DVISION']         = idline[4].sub(/;/,'')
	tmp['SEQUENCE_LENGTH'] = idline[5].to_i
	@data['ID'] = tmp
      end
      if block_given?
	@data['ID'].each do |k,v|
	  yield(k,v)
	end
      elsif key
	@data['ID'][key]
      else
	@data['ID']
      end
    end

    ##
    # Bio::EMBL#entry -> String
    #          #entry_name -> String
    def entry
      id_line('ENTRY_NAME')
    end
    alias entry_name entry
    alias entry_id entry

    ##
    # Bio::EMBL#molecule -> String
    # 
    def molecule
      id_line('MOLECULE_TYPE')
    end
    alias molecule_type molecule

    ##
    # Bio::EMBL#division -> String
    # 
    def division
      id_line('DIVISION')
    end

    ##
    # Bio::EMBL#sequencelength -> String
    # 
    def sequence_length
      id_line('SEQUENCE_LENGTH')
    end
    alias seqlen sequence_length
    
    ##
    # AC Line
    # "AC   A12345; B23456;"
    #
    # Bio::EMBLDB#ac  -> Array
    #            #accessions  -> Array


    ##
    # SV Line; sequence version (1/entry)
    # "SV    Accession.Version"
    #
    # Bio::EMBL#sv -> String
    # Bio::EMBL#version -> Int
    #
    def sv
      field_fetch('SV').sub(/;/,'')
    end
    def version
      sv.split(".")[1].to_i
    end
    
    ##
    # DT Line; date (2/entry)
    # Bio::EMBL#dt  -> Hash
    # Bio::EMBL#dt(key)  -> String
    #   key = (created|updated)
    #
    def dt(key=nil)
      unless @data['DT']
	tmp = Hash.new
	dt_line = self.get('DT').split("\n")
	tmp['created'] = dt_line[0].sub(/\w{2}   /,'').strip
	tmp['updated'] = dt_line[1].sub(/\w{2}   /,'').strip
	@data['DT'] = tmp
      end
      if block_given?
	@data['DT'].each do |k,v|
	  yield(k,v)
	end
      elsif key
	@data['DT'][key]
      else
	@data['DT']
      end
    end



    ##
    # DE Line; description (>=1)
    #
    def de
      fetch('DE')
    end


    ##
    # KW Line; keyword (>=1)
    # KW   [Keyword;]+
    #
    # Bio::EMBLDB#kw  -> Array
    #            #keywords  -> Array


    ##
    # OS Line; organism species (>=1)
    # OS   Genus species (name)
    # "OS   Trifolium repens (white clover)"
    #
    # Bio::EMBLDB#os  -> Array


    ##
    # OC Line; organism classification (>=1)
    #
    # Bio::EMBLDB#oc  -> Array


    ##
    # OG Line; organella (0 or 1/entry)
    # ["Mitochondrion", "Chloroplast","Kinetoplast", "Cyanelle", "Plastid"]
    #  or a plasmid name (e.g. "Plasmid pBR322").  
    #
    # Bio::EMBLDB#og  -> String


    ##
    # R Lines
    # RN RC RP RX RA RT RL
    #
    # Bio::EMBLDB#ref


    ##
    # DR Line; defabases cross-regerence (>=0)
    # "DR  database_identifier; primary_identifier; secondary_identifier."
    #
    # Bio::EMBLDB#dr


    ##
    # FH Line; feature table header (0 or 2)
    # FT Line; feature table data (>=0)
    #
    # Bio::EMBL#ft -> Array
    # Bio::EMBL#ft {} -> {|Hash| }
    # Bio::EMBL#ft(Int) -> Hash
    #
    def fh
      get('FH')
    end
    # same as features method in bio/db/genbank.rb 
    def ft(num = nil)
      unless @data['FT']
	@data['FT'] = Array.new
	ary = Array.new
	in_quote = false
	@orig['FT'].each_line do |line|
	  next if line =~ /^FEATURES/

	  head = line[0,20].strip	# feature key (source, CDS, ...)
	  body = line[20,60].chomp	# feature value (position, /qualifier=)
	  if line =~ /^FT {3}(\S+)/
	    ary.push([ $1, body ])	# [ feature, position, /q="data", ... ]
	  elsif body =~ /^ \// and not in_quote
	    ary.last.push(body)		# /q="data..., /q=data, /q

	    if body =~ /=" / and body !~ /"$/
	      in_quote = true
	    end

	  else
	    ary.last.last << body	# ...data..., ...data..."

	    if body =~ /"$/
	      in_quote = false
	    end
	  end
	end

        ary.collect! do |subary|
	  parse_qualifiers(subary)
        end

	@data['FT'] = Features.new(ary)
      end
      @data['FT']
    end
    alias features ft

    ##
    # Bio::EMBL#each_cds -> Hash
    #
    def each_cds
      ft.each do |feature|
	if feature.type == 'CDS'
	  yield feature		# iterate only for the 'CDS' FT
	end
      end
    end

    ##
    # Bio::EMBL#each_gene -> Hash
    #
    def each_gene
      ft.each do |feature|
	if feature.type == 'gene'
	  yield feature		# iterate only for the 'gene' FT
	end
      end
    end


    ##
    # CC Line; comments of notes (>=0)
    #
    def cc
      get('CC')
    end


    ##
    # XX Line; spacer line (many)
    #  def nxx
    #  end


    ##
    # SQ Line; sequence header (1/entry)
    # "SQ   Sequence 1859 BP; 609 A; 314 C; 355 G; 581 T; 0 other;"
    # Bio::EMBL#sq  -> Hash
    # Bio::EMBL#sq(base)  -> Int
    #          #sq[base]  -> Int
    #
    def sq(base = nil)
      unless @data['SQ']
	fetch('SQ') =~ \
               /(\d+) BP\; (\d+) A; (\d+) C; (\d+) G; (\d+) T; (\d+) other;/
	@data['SQ']={'ntlen'=>$1.to_i, 'other'=>$6.to_i,
	             'a'=>$2.to_i,'c'=>$3.to_i,'g'=>$4.to_i,'t'=>$5.to_i}
      else
	@data['SQ']
      end
      if block_given?
	@data['SQ'].each do |k,v|
	  yield(k,v)
	end
      elsif base
	@data['SQ'][base.downcase]
      else
	@data['SQ']
      end
    end
    # Bio::EMBL#gc  -> Float
    def gc
      ( sq('g') + sq('c') ) / sq('ntlen').to_f * 100
    end
    

    ##
    # @orig[''] as sequence
    # bb Line; (blanks) sequence data (>=1)
    # Bio::EMBL#seq  -> Bio::Sequence::NA
    #
    def seq
      Sequence::NA.new( fetch('').gsub(/ /,'').gsub(/\d+/,'') )
    end
    alias naseq seq
    alias ntseq seq

    # // Line; termination line (end; 1/entry)



    ### private methods

    private

    ##
    # same as Bio::GenBank#parse_qualifiers(feature)
    def parse_qualifiers(ary)
      feature = Feature.new

      feature.feature = ary.shift
      feature.position = ary.shift.gsub(/\s/, '')

      ary.each do |f|
	if f =~ %r{/([^=]+)=?"?([^"]*)"?}
	  qualifier, value = $1, $2
	  
	  if value.empty?
	    value = true
	  end

	  case qualifier
	  when 'translation'
	    value = Sequence::AA.new(value.gsub(/\s/, ''))
	  when 'codon_start'
	    value = value.to_i
	  end

	  feature.append(Feature::Qualifier.new(qualifier, value))
	end
      end

      return feature
    end

  end # class EMBL

end # module Bio

##
# Testing codes
#
if __FILE__ == $0
end



=begin

= Bio::EMBL

* Initialize
--- Bio::EMBL#new(an_embl_entry)

* ID Line (Identification)
--- Bio::EMBL#id_line -> Hash
--- Bio::EMBL#id_line(key) -> String
      key = (entryname|molecule|division|sequencelength)
--- Bio::EMBL#entry -> String
---          #entryname -> String
--- Bio::EMBL#molecule -> String
--- Bio::EMBL#division -> String
--- Bio::EMBL#sequencelength -> Int
    

* AC Lines (Accession number)
--- Bio::EMBL#ac -> Array
 
* SV Line (Sequence version)
--- Bio::EMBL#sv -> String

* DT Lines (Date) 
--- Bio::EMBL#dt -> Hash
--- Bio::EMBL#dt(key) -> String
      key = (created|updated)

* DE Lines (Description)
--- Bio::EMBL#de -> String

* KW Lines (Keyword)
--- Bio::EMBL#kw -> Array

* OS Lines (Organism species)
--- Bio::EMBL#os -> Hash

* OC Lines (organism classification)
--- Bio::EMBL#oc -> Array

* OG Line (Organella)
--- Bio::EMBL#og -> String

* R Lines (Reference) 
      RN RC RP RX RA RT RL
--- Bio::EMBL#ref -> String 

* DR Lines (Database cross-reference)
--- Bio::EMBL#dr -> Array

* FH Lines (Feature table header and data)
      FH FT
--- Bio::EMBL#ft -> 
--- Bio::EMBL#each_cds -> Array
--- Bio::EMBL#each_gene -> Array


* SQ Lines (Sequence header and data)
      SQ bb
--- Bio::EMBL#sq -> Hash
--- Bio::EMBL#sq(base) -> Int
      base = (a|c|g|t|u|other)
--- Bio::EMBL#gc -> Float
--- Bio::EMBL#seq -> Bio::Sequece::NA

=end

