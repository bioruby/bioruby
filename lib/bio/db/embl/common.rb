#
# = bio/db/embl.rb - Common methods for EMBL style database classes
#
# Copyright::   Copyright (C) 2001-2006
#               Mitsuteru C. Nakao <n@bioruby.org>
# License::     The Ruby License
#
# $Id: common.rb,v 1.12.2.1 2008/02/20 09:56:22 aerts Exp $
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
      @data['R'] = Array.new
      # Get the different references as 'blurbs' (the lines together)
      reference_blurbs = get('R').split(/\nRN   /)
      reference_blurbs.each_index do |i|
        reference_blurbs[i] = 'RN   ' + reference_blurbs[i] unless reference_blurbs[i] =~ /^RN   /
      end
      
      # For each reference, we'll first create a hash that looks like below.
      # Suppose the input is:
      #   RA   name1, name2, name3
      #   RA   name4
      #   RT   some part of the title that
      #   RT   did not fit on one line
      # Then the hash looks like:
      #   h = {
      #         'RA' => ["name1, name2, name3", "name4"],
      #         'RT' => ["some part of the title that", "did not fit on one line"]
      #       }
      reference_blurbs.each do |rb|
        line_based_data = Hash.new
        rb.split(/\n/).each do |line|
          key, value = line.scan(/^(R[A-Z])   "?(\[?.*[A-Za-z0-9]\]?)/)[0]
          if line_based_data[key].nil?
            line_based_data[key] = Array.new
          end
          line_based_data[key].push(value)
        end

        # Now we have to sanitize the hash: the authors should be kept in an 
        # array, the title should be 1 string, ... So the hash should look like:
        #  h = {
        #        'RA' => ["name1", "name2", "name3", "name4"],
        #        'RT' => 'some part of the title that did not fit on one line'
        #      }
        line_based_data.keys.each do |key|
          if ['RC', 'RP', 'RT', 'RL'].include?(key)
            line_based_data[key] = line_based_data[key].join(' ')
          elsif ['RA', 'RX'].include?(key)
            sanitized_data = Array.new
            line_based_data[key].each do |v|
              sanitized_data.push(v.split(/\s*,\s*/))
            end
            line_based_data[key] = sanitized_data.flatten
          elsif key == 'RN'
            line_based_data[key] = line_based_data[key][0].sub(/^\[/,'').sub(/\]$/,'').to_i
          end
        end
        
        # And put it in @data. @data in the end looks like this:
        #  data = [
        #           {
        #             'RA' => ["name1", "name2", "name3", "name4"],
        #             'RT' => 'some part of the title that did not fit on one line'
        #           },
        #           {
        #             'RA' => ["name1", "name2", "name3", "name4"],
        #             'RT' => 'some part of the title that did not fit on one line'
        #           }
        #         ]
        @data['R'].push(line_based_data)
      end
    end
    @data['R']
  end

  # returns Bio::Reference object from Bio::EMBLDB::Common#ref.
  # * Bio::EMBLDB::Common#ref -> Bio::References
  def references
    unless @data['references']
      @data['references'] = Array.new
      self.ref.each do |ref|
        hash = Hash.new
        ref.each do |key, value|
          case key
          when 'RN'
            hash['embl_gb_record_number'] = value
          when 'RC'
            hash['comments'] = value
          when 'RX'
            hash['xrefs'] = value
          when 'RP'
            hash['sequence_position'] = value
          when 'RA'
            hash['authors'] = value
          when 'RT'
            hash['title'] = value
          when 'RL'
            hash['journal'] = value
          when 'RX'  # PUBMED, MEDLINE
            value.each {|item|
              tag, xref = item.split(/; /).map {|i| i.strip }
              hash[ tag.downcase ]  = xref
            }
          end
        end
        @data['references'].push(Reference.new(hash))
      end
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

