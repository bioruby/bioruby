#
# = bio/db/embl/sptr201107.rb - UniProt/SwissProt and TrEMBL database class
# 
# Copyright::   Copyright (c) 2011 The Regents of the University of California 
# License::     The Ruby License
#
# $Id:$
#
# == Description
# 
# Updates to the sptr parser to work with uniprot as of release 2011_07
# 
# == Examples
#
#   str = File.read("p53_human.unprot")
#   obj = Bio::SPTR201107.new(str)
#   obj.entry_id #=> "P53_HUMAN"
# 
# == References
# 
# * UniProt
#   http://uniprot.org/


require 'bio/db'
require 'bio/db/embl/sptr'

module Bio

# Parser class for UniProtKB/SwissProt and TrEMBL database entry as of the 2011_07 release.
class SPTR201107 < SPTR
  # returns a Hash of the ID line.
  #
  # returns a content (Int or String) of the ID line by a given key.
  # Hash keys: ['ENTRY_NAME', 'DATA_CLASS', 'MODECULE_TYPE', 'SEQUENCE_LENGTH']
  #
  # === ID Line
  #   ID   P53_HUMAN      STANDARD;      393 AA.
  #   #"ID  #{ENTRY_NAME} #{DATA_CLASS}; #{SEQUENCE_LENGTH}."
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
      'SEQUENCE_LENGTH' => part[3].to_i 
    }
  end
  
  # returns a nil and warns about deprecation
  def molecule
    warn "[DEPRECATION] `molecule` is deprecated, the PRT section of the ID was removed by uniprot."
  end
  alias molecule_type molecule


  # returns the proposed official name of the protein.
  # 
  # === DE Line; description (>=1)
  #  "DE #{OFFICIAL_NAME} (#{SYNONYM})"
  #  "DE #{OFFICIAL_NAME} (#{SYNONYM}) [CONTEINS: #1; #2]."
  #  OFFICIAL_NAME  1/entry
  #  SYNONYM        >=0
  #  CONTEINS       >=0
  def protein_name
    get('DE').split("\n").each do |line|
      if (line[/RecName/])
        return line[/Full=([^;]*)/, 1]
      end
    end
    return nil
  end


  # returns an array of synonyms (unofficial names).
  #
  # synonyms are each placed in () following the official name on the DE line.
  def synonyms
    ary = Array.new
    get('DE').split("\n").each do |line|
      if (line[/AltName/])
        ary << line[/Full=([^;]*)/, 1]
      end
    end
    return ary
  end
  
  
  # CC   -!- WEB RESOURCE: NAME=ResourceName[; NOTE=FreeText][; URL=WWWAddress].  
  def cc_web_resource(data)
    data.map {|x|
      entry = {'NAME' => x[/Name=([^;]*)/, 1],
               'NOTE' => x[/Note=([^;]*)/, 1],
               'URL'  => x[/URL=([^;]*)/, 1]}
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
end
end
