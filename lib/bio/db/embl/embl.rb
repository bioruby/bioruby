#
# bio/db/embl/embl.rb - EMBL database class
#
#   Copyright (C) 2001, 2002 Mitsuteru C. Nakao <n@bioruby.org>
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
#  $Id: embl.rb,v 1.20 2004/08/23 23:40:35 k Exp $
#

require 'bio/db'

module Bio

class EMBL < EMBLDB

  require 'bio/db/embl/common'
  include Bio::EMBL::Common

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
      dt_line = self.get('DT').split(/\n/)
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

      ary.map! do |subary|
        parse_qualifiers(subary)
      end

      @data['FT'] = Features.new(ary)
    end
    if block_given?
      @data['FT'].each do |f|
        yield f
      end
    else
      @data['FT']
    end
  end
  alias features ft

  def each_cds
    ft.each do |feature|
      if feature.feature == 'CDS'
        yield feature
      end
    end
  end

  def each_gene
    ft.each do |feature|
      if feature.feature == 'gene'
        yield feature
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

end

end


if __FILE__ == $0
  while ent = $<.gets(Bio::EMBL::RS)
    puts "\n ==> e = Bio::EMBL.new(ent) "
    e = Bio::EMBL.new(ent)

    puts "\n ==> e.entry_id "
    p e.entry_id
    puts "\n ==> e.id_line "
    p e.id_line
    puts "\n ==> e.id_line('molecule') "
    p e.id_line('molecule')
    puts "\n ==> e.molecule "
    p e.molecule
    puts "\n ==> e.ac "
    p e.ac
    puts "\n ==> e.sv "
    p e.sv
    puts "\n ==> e.dt "
    p e.dt
    puts "\n ==> e.dt('created') "
    p e.dt('created')
    puts "\n ==> e.de "
    p e.de
    puts "\n ==> e.kw "
    p e.kw
    puts "\n ==> e.os "
    p e.os
    puts "\n ==> e.oc "
    p e.oc
    puts "\n ==> e.og "
    p e.og
    puts "\n ==> e.ref "
    p e.ref
    puts "\n ==> e.dr "
    p e.dr
    puts "\n ==> e.ft "
    p e.ft
    puts "\n ==> e.each_cds {|c| p c}"
    p e.each_cds {|c| p c }
    puts "\n ==> e.sq "
    p e.sq
    puts "\n ==> e.sq('a') "
    p e.sq('a')
    puts "\n ==> e.gc"    
    p e.gc
    puts "\n ==> e.seq "
    p e.seq
  end

end



=begin

= Bio::EMBL

=== Initialize

--- Bio::EMBL#new(an_embl_entry)

=== ID line (Identification)

--- Bio::EMBL#id_line -> Hash
--- Bio::EMBL#id_line(key) -> String

      key = (entryname|molecule|division|sequencelength)

--- Bio::EMBL#entry -> String
--- Bio::EMBL#entryname -> String
--- Bio::EMBL#molecule -> String
--- Bio::EMBL#division -> String
--- Bio::EMBL#sequencelength -> Int

=== AC lines (Accession number)

--- Bio::EMBL#ac -> Array
 
=== SV line (Sequence version)

--- Bio::EMBL#sv -> String

=== DT lines (Date) 

--- Bio::EMBL#dt -> Hash
--- Bio::EMBL#dt(key) -> String

      key = (created|updated)

=== DE lines (Description)

--- Bio::EMBL#de -> String

=== KW lines (Keyword)

--- Bio::EMBL#kw -> Array

=== OS lines (Organism species)

--- Bio::EMBL#os -> Hash

=== OC lines (organism classification)

--- Bio::EMBL#oc -> Array

=== OG line (Organella)

--- Bio::EMBL#og -> String

=== RN RC RP RX RA RT RL lines (Reference)
      
--- Bio::EMBL#ref -> String 

=== DR lines (Database cross-reference)

--- Bio::EMBL#dr -> Array

=== FH FT lines (Feature table header and data)

--- Bio::EMBL#ft -> Bio::Features
--- Bio::EMBL#each_cds -> Array
--- Bio::EMBL#each_gene -> Array


=== SQ Lines (Sequence header and data)

--- Bio::EMBL#sq -> Hash
--- Bio::EMBL#sq(base) -> Int

      base = (a|c|g|t|u|other)

--- Bio::EMBL#gc -> Float
--- Bio::EMBL#seq -> Bio::Sequece::NA

=end
