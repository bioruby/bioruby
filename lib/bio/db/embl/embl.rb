#
# = bio/db/embl/embl.rb - EMBL database class
#
# 
# Copyright::   Copyright (C) 2001-2005 Mitsuteru C. Nakao <n@bioruby.org>
# License::     LGPL
#
# $Id: embl.rb,v 1.26 2006/01/28 06:40:38 nakao Exp $
#
# == Description
#
# Parser class for EMBL database entry.
#
# == Examples
# 
#   emb = Bio::EMBL.new($<.read)
#   emb.entry_id
#   emb.each_cds do |cds|
#     cds # A CDS in feature table.
#   end
#   emb.seq #=> "ACGT..."
#
# == References
#
# * The EMBL Nucleotide Sequence Database
#   http://www.ebi.ac.uk/embl/
#
# * The EMBL Nucleotide Sequence Database: Users Manual
#   http://www.ebi.ac.uk/embl/Documentation/User_manual/usrman.html
#
#--
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
#++
#

require 'bio/db'
require 'bio/db/embl/common'

module Bio
class EMBL < EMBLDB
  include Bio::EMBLDB::Common

  # returns contents in the ID line.
  # * Bio::EMBL#id_line -> <ID Hash>
  # where <ID Hash> is:
  #  {'ENTRY_NAME' => String, 'MOLECULE_TYPE' => String, 'DIVISION' => String,
  #   'SEQUENCE_LENGTH' => Int}
  #
  # ID Line
  #  "ID  ENTRY_NAME DATA_CLASS; MOLECULE_TYPE; DIVISION; SEQUENCE_LENGTH BP."
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
      idline = fetch('ID').split(/; +/)         
      tmp['ENTRY_NAME'], tmp['DATA_CLASS'] = idline[0].split(/ +/)
      tmp['MOLECULE_TYPE'] = idline[1]
      tmp['DIVISION'] = idline[2]
      tmp['SEQUENCE_LENGTH'] = idline[3].strip.split(' ').first.to_i

      @data['ID'] = tmp
    end
    
    if key
      @data['ID'][key]
    else
      @data['ID']
    end
  end

  # returns ENTRY_NAME in the ID line.
  # * Bio::EMBL#entry -> String
  def entry
    id_line('ENTRY_NAME')
  end
  alias entry_name entry
  alias entry_id entry

  # returns MOLECULE_TYPE in the ID line.
  # * Bio::EMBL#molecule -> String
  def molecule
    id_line('MOLECULE_TYPE')
  end
  alias molecule_type molecule

  # returns DIVISION in the ID line.
  # * Bio::EMBL#division -> String
  def division
    id_line('DIVISION')
  end

  # returns SEQUENCE_LENGTH in the ID line.
  # * Bio::EMBL#sequencelength -> String
  def sequence_length
    id_line('SEQUENCE_LENGTH')
  end
  alias seqlen sequence_length
  

  # AC Line
  # "AC   A12345; B23456;"


  # returns the version information in the sequence version (SV) line.
  # * Bio::EMBL#sv -> Accession.Version in String
  # * Bio::EMBL#version -> accession in Int
  #
  # SV Line; sequence version (1/entry)
  #  SV    Accession.Version
  def sv
    field_fetch('SV').sub(/;/,'')
  end
  def version
    sv.split(".")[1].to_i
  end

  
  # returns contents in the date (DT) line.
  # * Bio::EMBL#dt  -> <DT Hash>
  # where <DT Hash> is:
  #  {}
  # * Bio::EMBL#dt(key)  -> String
  # keys: 'created' and 'updated'
  #
  # DT Line; date (2/entry)
  def dt(key=nil)
    unless @data['DT']
      tmp = Hash.new
      dt_line = self.get('DT').split(/\n/)
      tmp['created'] = dt_line[0].sub(/\w{2}   /,'').strip
      tmp['updated'] = dt_line[1].sub(/\w{2}   /,'').strip
      @data['DT'] = tmp
    end
    if key
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


  # returns feature table header (String) in the feature header (FH) line.
  #
  # FH Line; feature table header (0 or 2)
  def fh
    fetch('FH')
  end

  # returns contents in the feature table (FT) lines.
  # * Bio::EMBL#ft -> Bio::Features
  # * Bio::EMBL#ft {} -> {|Bio::Feature| }
  #
  # same as features method in bio/db/genbank.rb 
  #
  # FT Line; feature table data (>=0)
  def ft
    unless @data['FT']
      @data['FT'] = Array.new
      ary = Array.new
      in_quote = false
      @orig['FT'].each_line do |line|
        next if line =~ /^FEATURES/

        head = line[0,20].strip  # feature key (source, CDS, ...)
        body = line[20,60].chomp # feature value (position, /qualifier=)
        if line =~ /^FT {3}(\S+)/
          ary.push([ $1, body ]) # [ feature, position, /q="data", ... ]
        elsif body =~ /^ \// and not in_quote
          ary.last.push(body)    # /q="data..., /q=data, /q

          if body =~ /=" / and body !~ /"$/
            in_quote = true
          end

        else
          ary.last.last << body # ...data..., ...data..."

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
      @data['FT'].each do |feature|
        yield feature
      end
    else
      @data['FT']
    end
  end
  alias features ft

  # iterates on CDS features in the FT lines.
  def each_cds
    ft.each do |cds_feature|
      if cds_feature.feature == 'CDS'
        yield cds_feature
      end
    end
  end

  # iterates on gene features in the FT lines.
  def each_gene
    ft.each do |gene_feature|
      if gene_feature.feature == 'gene'
        yield gene_feature
      end
    end
  end


  # returns comment text in the comments (CC) line.
  #
  # CC Line; comments of notes (>=0)
  def cc
    get('CC')
  end


  ##
  # XX Line; spacer line (many)
  #  def nxx
  #  end


  # returns sequence header information in the sequence header (SQ) line.
  # * Bio::EMBL#sq  -> <SQ Hash>
  # where <SQ Hash> is:
  #     {'ntlen' => Int, 'other' => Int,
  #      'a' => Int, 'c' => Int, 'g' => Int, 't' => Int}
  # * Bio::EMBL#sq(base)  -> <base content in Int>
  # * Bio::EMBL#sq[base]  -> <base content in Int>
  #
  # SQ Line; sequence header (1/entry)
  #  SQ   Sequence 1859 BP; 609 A; 314 C; 355 G; 581 T; 0 other;
  def sq(base = nil)
    unless @data['SQ']
      fetch('SQ') =~ \
             /(\d+) BP\; (\d+) A; (\d+) C; (\d+) G; (\d+) T; (\d+) other;/
      @data['SQ'] = {'ntlen' => $1.to_i, 'other' => $6.to_i,
                     'a' => $2.to_i, 'c' => $3.to_i , 'g' => $4.to_i, 't' => $5.to_i}
    else
      @data['SQ']
    end

    if base
      @data['SQ'][base.downcase]
    else
      @data['SQ']
    end
  end
  

  # returns the nucleotie sequence in this entry.
  # * Bio::EMBL#seq  -> Bio::Sequence::NA
  #
  # @orig[''] as sequence
  # bb Line; (blanks) sequence data (>=1)
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



