#
# bio/db/embl.rb - Common methods for EMBL style database classes
#
#   Copyright (C) 2001-2004 Mitsuteru C. Nakao <n@bioruby.org>
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
#  $Id: common.rb,v 1.2 2004/08/25 16:59:24 k Exp $
#

module Bio
class EMBL
module Common

  DELIMITER	= RS = "\n//\n"
  TAGSIZE	= 5

  def initialize(entry)
    super(entry, TAGSIZE)
  end


  # AC Line
  # "AC   A12345; B23456;"
  # AC [AC1;]+
  #
  # Accession numbers format:
  # 1       2     3          4          5          6
  # [O,P,Q] [0-9] [A-Z, 0-9] [A-Z, 0-9] [A-Z, 0-9] [0-9]
  #
  # Bio::EMBL::Common#ac  -> Array
  #                 #accessions  -> Array
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

  # Bio::EMBL::Common#accession  -> String
  def accession
    ac[0]
  end


  # DE Line:
  def de
    unless @data['DE']
      @data['DE'] = fetch('DE')
    end
    @data['DE']
  end
  alias :description :de	
  # API
  alias :definition :de
  


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


  # OG Line; organella (0 or 1/entry)
  #
  # Bio::EMBL::Common#og  -> Array
  def og
    unless @data['OG']
      og = Array.new
      if get('OG').size > 0
        fetch('OG').sub(/\.$/,'').sub(/ and/,'').split(/,/).each do |tmp|
          og.push(tmp.strip)
        end
      end
      @data['OG'] = og
    end
    @data['OG']
  end


  # OC Line; organism classification (>=1)
  # OC   Eukaryota; Alveolata; Apicomplexa; Piroplasmida; Theileriidae;
  # OC   Theileria.
  #
  # Bio::EMBL::Common#oc  -> Array
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


  # KW Line; keyword (>=1)
  # KW   [Keyword;]+
  # Bio::EMBL::Common#kw  -> Array
  #                 #keywords  -> Array
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


  # R Lines
  # RN RC RP RX RA RT RL RG
  # Bio::EMBL::Common#ref -> Array
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

  # Bio::EMBL::Common#references -> Bio::References
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
            value.split('.').each {|item|
              tag, xref = item.split(/; /).map {|i| i.strip }
              hash[ tag.downcase ]  = xref
            }
          end
        }
        Reference.new(hash)
      }
      @data['references'] = References.new(ary)
    end
    @data['references']
  end



  # DR Line; defabases cross-reference (>=0)
  # a cross_ref pre one line
  # "DR  database_identifier; primary_identifier; secondary_identifier."
  # Bio::EMBL::Common#dr  -> Hash w/in Array
  # Bio::EMBL::Common#dr {|k,v| } 
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
end # class EMBL
end # module Bio


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


=begin

= Bio::EMBL::Common

This module defines a common framework among EMBL, SWISS-PROT, TrEMBL.
For more details, see the documentations in each embl/*.rb libraries.


--- Bio::EMBL::Common::DELIMITER
--- Bio::EMBL::Common::RS
--- Bio::EMBL::Common::TAGSIZE


--- Bio::EMBL::Common#ac
                    #accessions

--- Bio::EMBL::Common#accession


--- Bio::EMBL::Common#de
                    #description
                    #definition


--- Bio::EMBL::Common#os


--- Bio::EMBL::Common#og


--- Bio::EMBL::Common#oc


--- Bio::EMBL::Common#kw
                    #keywords


--- Bio::EMBL::Common#ref
        Reterns R* lines in hsh w/in ary.

--- Bio::EMBL::Common#references
        Retruns Bio::References.


--- Bio::EMBL::Common#dr

=end

