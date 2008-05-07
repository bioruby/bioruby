#
# = bio/db/embl.rb - Common methods for EMBL style database classes
#
# Copyright::   Copyright (C) 2001-2006
#               Mitsuteru C. Nakao <n@bioruby.org>
# License::     The Ruby License
#
# $Id: common.rb,v 1.12.2.5 2008/05/07 12:22:10 ngoto Exp $
#
# == Description
#
# EMBL style databases class
#
# This module defines a common framework among EMBL, UniProtKB, SWISS-PROT, 
# TrEMBL. For more details, see the documentations in each embl/*.rb 
# libraries.
#
# EMBL style format:
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
#     RG - reference group            (>=0 per entry)
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
#
# == Examples
# 
#  # Make a new parser class for EMBL style database entry.
#  require 'bio/db/embl/common'
#  module Bio
#    class NEWDB < EMBLDB
#      include Bio::EMBLDB::Common
#    end
#  end
#
# == References
#
# * The EMBL Nucleotide Sequence Database
#   http://www.ebi.ac.uk/embl/
#
# * The EMBL Nucleotide Sequence Database: Users Manual
#   http://www.ebi.ac.uk/embl/Documentation/User_manual/usrman.html
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
require 'bio/reference'
require 'bio/compat/references'

module Bio
class EMBLDB
module Common

  DELIMITER = "\n//\n"
  RS = DELIMITER
  TAGSIZE = 5

  def initialize(entry)
    super(entry, TAGSIZE)
  end

  # returns a Array of accession numbers in the AC lines.
  #
  # AC Line
  #   "AC   A12345; B23456;"
  #   AC [AC1;]+
  #
  # Accession numbers format:
  #   1       2     3          4          5          6
  #   [O,P,Q] [0-9] [A-Z, 0-9] [A-Z, 0-9] [A-Z, 0-9] [0-9]
  def ac
    unless @data['AC']
      tmp = Array.new
      field_fetch('AC').split(/ /).each do |e|
        tmp.push(e.sub(/;/,''))
      end
      @data['AC'] = tmp
    end
    @data['AC']
  end
  alias accessions ac


  # returns the first accession number in the AC lines
  def accession
    ac[0]
  end


  # returns a String int the DE line.
  #
  # DE Line
  def de
    unless @data['DE']
      @data['DE'] = fetch('DE')
    end
    @data['DE']
  end
  alias description de
  alias definition de   # API
  


  # returns contents in the OS line.
  # * Bio::EMBLDB#os  -> Array of <OS Hash>
  # where <OS Hash> is:
  #  [{'name'=>'Human', 'os'=>'Homo sapiens'}, 
  #   {'name'=>'Rat', 'os'=>'Rattus norveticus'}]
  # * Bio::SPTR#os[0]['name'] => "Human"
  # * Bio::SPTR#os[0] => {'name'=>"Human", 'os'=>'Homo sapiens'}
  # * Bio::STPR#os(0) => "Homo sapiens (Human)"
  #
  # OS Line; organism species (>=1)
  #   "OS   Trifolium repens (white clover)"
  #
  #   OS   Genus species (name).
  #   OS   Genus species (name0) (name1).
  #   OS   Genus species (name0) (name1).
  #   OS   Genus species (name0), G s0 (name0), and G s (name1).
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
      "#{@data['OS'][num]['os']} {#data['OS'][num]['name']"
    end
    @data['OS']
  end


  # returns contents in the OG line.
  # * Bio::EMBLDB::Common#og  -> [ <ogranella String>* ]
  #
  # OG Line; organella (0 or 1/entry)
  #  OG   Plastid; Chloroplast.
  #  OG   Mitochondrion.
  #  OG   Plasmid sym pNGR234a.
  #  OG   Plastid; Cyanelle.
  #  OG   Plasmid pSymA (megaplasmid 1).
  #  OG   Plasmid pNRC100, Plasmid pNRC200, and Plasmid pHH1.
  def og
    unless @data['OG']
      og = Array.new
      if get('OG').size > 0
        ogstr = fetch('OG')
        ogstr.sub!(/\.$/,'')
        ogstr.sub!(/ and/,'')
        ogstr.sub!(/;/, ',')
        ogstr.split(',').each do |tmp|
          og.push(tmp.strip)
        end
      end
      @data['OG'] = og
    end
    @data['OG']
  end
  

  # returns contents in the OC line.
  # * Bio::EMBLDB::Common#oc  -> [ <organism class String>* ]
  # OC Line; organism classification (>=1)
  #  OC   Eukaryota; Alveolata; Apicomplexa; Piroplasmida; Theileriidae;
  #  OC   Theileria.
  def oc
    unless @data['OC']
      begin
        @data['OC'] = fetch('OC').sub(/.$/,'').split(/;/).map {|e|
          e.strip 
        }
      rescue NameError
        nil
      end
    end
    @data['OC']
  end

  # returns keywords in the KW line.
  # * Bio::EMBLDB::Common#kw  -> [ <keyword>* ]
  # KW Line; keyword (>=1)
  #  KW   [Keyword;]+
  def kw
    unless @data['KW']
      if get('KW').size > 0
        tmp = fetch('KW').sub(/.$/,'')
        @data['KW'] = tmp.split(/;/).map {|e| e.strip }
      else
        @data['KW'] = []
      end
    end
    @data['KW']
  end
  alias keywords kw


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
      ary = Array.new
      get('R').split(/\nRN   /).each do |str|
        raw = {'RN' => '', 'RC' => '', 'RP' => '', 'RX' => '', 
               'RA' => '', 'RT' => '', 'RL' => '', 'RG' => ''}
        str = 'RN   ' + str unless /^RN   / =~ str
        str.split("\n").each do |line|
          if /^(R[NPXARLCTG])   (.+)/ =~ line
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
        ary.push(raw)
      end
      @data['R'] = ary
    end
    @data['R']
  end

  # returns Bio::Reference object from Bio::EMBLDB::Common#ref.
  # * Bio::EMBLDB::Common#ref -> Bio::References
  def references
    unless @data['references']
      ary = self.ref.map {|ent|
        hash = Hash.new
        ent.each {|key, value|
          case key
          when 'RN'
            if /\[(\d+)\]/ =~ value.to_s
              hash['embl_gb_record_number'] = $1.to_i
            end
          when 'RC'
            unless value.to_s.strip.empty?
              hash['comments'] ||= []
              hash['comments'].push value
            end
          when 'RP'
            hash['sequence_position'] = value
          when 'RA'
            a = value.split(/\, /)
            a.each do |x|
              x.sub!(/( [^ ]+)\z/, ",\\1")
            end
            hash['authors'] = a
          when 'RT'
            hash['title'] = value
          when 'RL'
            if /(.*) (\d+) *(\(([^\)]+)\))?(\, |\:)([a-zA-Z\d]+\-[a-zA-Z\d]+) *\((\d+)\)\.?\z/ =~ value.to_s
              hash['journal'] = $1.rstrip
              hash['volume']  = $2
              hash['issue']   = $4
              hash['pages']   = $6
              hash['year']    = $7
            else
              hash['journal'] = value
            end
          when 'RX'  # PUBMED, DOI, (AGRICOLA)
            value.split(/\. /).each {|item|
              tag, xref = item.split(/\; /).map {|i| i.strip.sub(/\.\z/, '') }
              hash[ tag.downcase ]  = xref
            }
          end
        }
        Reference.new(hash)
      }
      @data['references'] = ary.extend(Bio::References::BackwardCompatibility)
    end
    @data['references']
  end


  # returns contents in the DR line.
  # * Bio::EMBLDB::Common#dr  -> [ <Database cross-reference Hash>* ]
  # where <Database cross-reference Hash> is:
  # * Bio::EMBLDB::Common#dr {|k,v| } 
  # 
  # DR Line; defabases cross-reference (>=0)
  # a cross_ref pre one line
  #  "DR  database_identifier; primary_identifier; secondary_identifier."
  def dr
    unless @data['DR']
      tmp = Hash.new
      self.get('DR').split(/\n/).each do |db|
        a = db.sub(/^DR   /,'').sub(/.$/,'').strip.split(/;[ ]/)
        dbname = a.shift
        tmp[dbname] = Array.new unless tmp[dbname]
        tmp[dbname].push(a)
      end
      @data['DR'] = tmp
    end
    if block_given?
      @data['DR'].each do |k,v|
        yield(k, v)
      end
    else
      @data['DR']
    end
  end

end # module Common
end # class EMBLDB
end # module Bio

