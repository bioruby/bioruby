#
# bio/db/embl.rb - EMBL database class
#
#   Copyright (C) 2001 Mitsuteru S. Nakao <n@bioruby.org>
#
#  This library is free software; you can redistribute it and/or
#  modify it under the terms of the GNU Library General Public
#  License as published by the Free Software Foundation; either
#  version 2 of the License, or (at your option) any later version.
#
#  This library is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
#  Library General Public License for more details.
#
#  $Id: embl.rb,v 1.2 2001/10/29 16:34:56 nakao Exp $
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


module Bio

  require 'bio/db'

class EMBL < EMBLDB
    
  DELIMITER	= RS = "\n//\n"
  TAGSIZE	= 5

  def initialize(entry)
    super(entry, TAGSIZE)
  end

  # ID Line
  # "ID   entryname  dataclass; molecule; division; sequencelength BP."
  #
  # Dataclass: standard
  #
  # Molecule Type: DNA RNA XXX
  #
  # Code ( Division )
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
  def idline(key=nil)
    unless @data['ID']
      tmp=Hash.new
      a=@orig['ID'].split(/ +/)         
      tmp['entryname']=a[1]
      tmp['dataclass']=a[2].sub(/;/,'') # standard
      tmp['molecule']=a[3].sub(/;/,'')  # cyclic DNA
      tmp['division']=a[4].sub(/;/,'')
      tmp['sequencelength']=a[5].to_i
      @data['ID']=tmp
    end
    if block_given?
      @data['ID'].each do |k,v|
	yield(k,v)
     ppp end
    elsif key
      @data['ID'][key]
    else
      @data['ID']
    end
  end
  def entry
    id('entryname')
  end
  def molecule
    id('molecule')
  end
  def division
    id('division')
  end
  def sequencelength
    id('sequencelength')
  end

  

  # AC Line
  # "AC   A12345; B23456;"
  # Bio::DB::EMBL#ac  -> Array
  #              #accessions  -> Array
  def ac
    unless @data['AC']
      tmp=Array.new
      a=field_fetch('AC').split(' ')
      a.each do |e|
	tmp.push(e.sub(/;/,''))
      end
      @data['AC']=tmp
    end
    @data['AC']
  end
  alias accessions ac
  # Bio::DB::EMBL#accession  -> String
  def accession
    @data['AC'][0]
  end

  # SV Line; sequence version (1/entry)
  # "SV    Accession.Version"
  def sv
    field_fetch('SV').sub(/;/,'')
  end


  # DT Line; date (2/entry)
  # Bio::DB::EMBL#dt  -> Hash
  # Bio::DB::EMBL#dt(key)  -> String
  # key = (created|updated)
  def dt(key=nil)
    unless @data['DT']
      tmp=Hash.new
      a=self.get('DT').split("\n")
      tmp['created']=a[0].sub(/\w{2}   /,'').strip
      tmp['updated']=a[1].sub(/\w{2}   /,'').strip
      @data['DT']=tmp
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

  # DE Line; description (>=1)
  def de
    fetch('DE')
  end

  # KW Line; keyword (>=1)
  # KW   [Keyword;]+
  # Bio::DB::EMBL#kw  -> Array
  #              #keywords  -> Array
  def kw
    tmp=fetch('KW').sub(/.$/,'')
    if block_given?
      tmp.split(';').each do |k|
	yield k
      end
    else
      tmp.split(';')
    end      
  end
  alias keywords kw

  # OS Line; organism species (>=1)
  # OS   Genus species (name)
  # "OS   Trifolium repens (white clover)"
  # Bio::DB::EMBL#os  -> Array
  def os
    tmp=fetch('OS')
    os=Array.new
    if tmp =~ /(.+)\((.+)\)/
      os=[$1,$2]
    else
      os=[tmp]
    end
    os
  end

  # OC Line; organism classification (>=1)
  # Bio::DB::EMBL#oc  -> Array
  def oc
    tmp=fetch('OC').sub(/.$/,'')
    tmp.split(';')
  end

  # OG Line; organella (0 or 1/entry)
  # ["Mitochondrion", "Chloroplast","Kinetoplast", "Cyanelle", "Plastid"]
  #  or a plasmid name (e.g. "Plasmid pBR322").  
  # Bio::DB::EMBL#kw  -> String
  def og
    fetch('OG')
  end

  # R Lines
  # RN RC RP RX RA RT RL
  def ref
    get('R')
  end


  # DR Line; defabases cross-regerence (>=0)
  # "DR  database_identifier; primary_identifier; secondary_identifier."
  # Bio::DB::EMBL#dr  -> Array
  def dr
    unless @data['DR']
      tmp=Array.new
      a=self.get('DR').split("\n")
      a.each do |e|
	tmp.push(e.sub(/\w{2}   /,'').strip)
      end
      @data['DR']=tmp
    end
    if block_given?
      @data['DR'].each do |v|
	yield(v)
      end
    else
      @data['DR']
    end
  end


  # FH Line; feature table header (0 or 2)
  # FT Line; feature table data (>=0)
  def features(num = nil, key = nil) 
    unless @data['FEATURES']
      @data['FEATURES'] = []
      ary = []
      @orig['FEATURES'].each_line do |line|
	next if line =~ /^FEATURES/
	head = line[0,20].strip		# feature key (source, CDS, ...)
	body = line[20,60].chomp	# feature value (position, /qualifier=)
	if line =~ /^ {5}\S/
	  ary.push([ head, body ])	# [ feature, position, /q="data", ... ]
	elsif body =~ /^ \//
	  ary.last.push(body)		# /q="data..., /q=data, /q
	else
	  ary.last.last << body		# ...data..., ...data..."
	end
      end
      ary.each do |feature|		# feature is Array
	@data['FEATURES'].push(parse_qualifiers(feature))
      end
    end

    if block_given?
      @data['FEATURES'].each do |feature|
	yield(feature)			# Hash of each FEATURES
      end				#   obj.features do |f| f['gene'] end
    elsif num				#     f.has_key?('virion'), p f, ...
      if key
	@data['FEATURES'][num-1][key]	# key contents of num'th FEATURES
      else				#   obj.features(3, 'feature') -> 3rd
	@data['FEATURES'][num-1]	# Hash of num'th FEATURES
      end				#   obj.features(2) -> 2nd FEATURES
    else
      @data['FEATURES']			# Array of Hash of FEATURES (default)
    end					#   obj.features
  end
  def each_cds
    features do |feature|
      if feature['feature'] == 'CDS'
        yield(feature)			# iterate only for the 'CDS' FEATURES
      end
    end
  end
  def each_gene
    features.each do |feature|
      if feature['feature'] == 'gene'
        yield(feature)			# iterate only for the 'gene' FEATURES
      end
    end
  end






  # CC Line; comments of notes (>=0)
  def cc
    get('CC')
  end

  # XX Line; spacer line (many)
#  def xx
#  end


  # SQ Line; sequence header (1/entry)
  # "SQ   Sequence 1859 BP; 609 A; 314 C; 355 G; 581 T; 0 other;"
  # Bio::DB::EMBL#sq  -> Hash
  # Bio::DB::EMBL#sq(base)  -> Int
  # Bio::DB::EMBL#sq[base]  -> Int
  def sq(base=nil)
    unless @data['SQ']
      fetch('SQ') \
        =~ /(\d+) BP\; (\d+) A; (\d+) C; (\d+) G; (\d+) T; (\d+) other;/
      @data['SQ']={'ntlen'=>$1.to_i,
	'a'=>$2.to_i,'c'=>$3.to_i,'g'=>$4.to_i,'t'=>$5.to_i,
	'other'=>$6.to_i}
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
  # Bio::DB::EMBL#gc  -> Float
  def gc
   ( sq('g') + sq('c') ) / sq('ntlen').to_f * 100
  end

  # @orig[''] as sequence
  # bb Line; (blanks) sequence data (>=1)
  # Bio::DB::EMBL#seq  -> Bio::Sequence::NA
  def seq
    Sequence::NA.new( fetch('').gsub(/ /,'').gsub(/\d+/,'') )
  end
  alias naseq seq
  alias ntseq seq

  # // Line; termination line (end; 1/entry)




  ### private methods

  private

  def parse_qualifiers(feature)
    hash = Hash.new('')

    hash['feature'] = feature.shift
    hash['position'] = feature.shift.gsub(/\s/, '')

    feature.each do |f|
      if f =~ %r{/([^=]+)=?"?([^"]*)"?}
	qualifier, data = $1, $2
#	qualifier, data = $1, truncate($2)

	if data.empty?
	  data = qualifier
	end

	case qualifier
	when 'translation'
	  hash[qualifier] = Sequence::AA.new(data.gsub(/\s/, ''))
#	  hash[qualifier] = Sequence::AA.new(data.tr('^A-Z', ''))
	when 'db_xref'
	  if hash[qualifier].empty?
	    hash[qualifier] = []
	  end
	  hash[qualifier].push(data)
	when 'codon_start'
	  hash[qualifier] = data.to_i
	else
	  hash[qualifier] = data
	end
      end
    end

    return hash
  end

end


end # module Bio


=begin
= NAME

  embl.rb - A parser object for EMBL entry


== Usage:

  emb=Bio::DB:EMBL.new(data)


== Author
  Mitsuteru S. Nakao <n@BioRuby.org>
  The BioRuby Project (http://BioRuby.org/)

== Class

  class  Bio::DB::EMBL

== Methods

* Initialize
    Bio::DB::EMBL#new(an_embl_entry)

* ID Line (Identification)
    Bio::DB::EMBL#idline -> Hash
    Bio::DB::EMBL#idline(key) -> String
      key = (entryname|molecule|division|sequencelength)
    Bio::DB::EMBL#entry -> String
    Bio::DB::EMBL#molecule -> String
    Bio::DB::EMBL#division -> String
    Bio::DB::EMBL#sequencelength -> Int
    

* AC Lines (Accession number)
    Bio::DB::EMBL#ac -> Array
 
* SV Line (Sequence version)
    Bio::DB::EMBL#sv -> String

* DT Lines (Date) 
    Bio::DB::EMBL#dt -> Hash
    Bio::DB::EMBL#dt(key) -> String
      key = (created|updated)
    Bio::DB::EMBL.dt['updated']

* DE Lines (Description)
    Bio::DB::EMBL#de -> String

* KW Lines (Keyword)
    Bio::DB::EMBL#kw -> Array

* OS Lines (Organism species)
    Bio::DB::EMBL#os -> Hash

* OC Lines (organism classification)
    Bio::DB::EMBL#oc -> Array

* OG Line (Organella)
    Bio::DB::EMBL#og -> String

* R Lines (Reference) 
      RN RC RP RX RA RT RL
    Bio::DB::EMBL#ref -> String 

* DR Lines (Database cross-reference)
    Bio::DB::EMBL#dr -> Array

* FH Lines (Feature table header and data)
      FH FT
    Bio::DB::EMBL#ft
    Bio::DB::EMBL#each_cds
    Bio::DB::EMBL#each_gene


* SQ Lines (Sequence header and data)
      SQ bb
    Bio::DB::EMBL#sq -> Hash
    Bio::DB::EMBL#sq(base) -> Int
      base = (a|c|g|t|u|other)
    Bio::DB::EMBL#gc -> Float
    Bio::DB::EMBL#seq -> Bio::Sequece::NA

=end
