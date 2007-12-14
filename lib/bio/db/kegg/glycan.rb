#
# = bio/db/kegg/glycan.rb - KEGG GLYCAN database class
#
# Copyright::  Copyright (C) 2004 Toshiaki Katayama <k@bioruby.org>
# License::    The Ruby License
#
# $Id: glycan.rb,v 1.7 2007/12/14 16:20:38 k Exp $
#

require 'bio/db'

module Bio
class KEGG

class GLYCAN < KEGGDB

  DELIMITER	= RS = "\n///\n"
  TAGSIZE	= 12

  def initialize(entry)
    super(entry, TAGSIZE)
  end

  # ENTRY
  def entry_id
    field_fetch('ENTRY')[/\S+/]
  end

  # NAME
  def name
    field_fetch('NAME') 
  end

  # COMPOSITION
  def composition
    unless @data['COMPOSITION']
      hash = Hash.new(0)
      fetch('COMPOSITION').scan(/\((\S+)\)(\d+)/).each do |key, val|
        hash[key] = val.to_i
      end
      @data['COMPOSITION'] = hash
    end
    @data['COMPOSITION']
  end

  # MASS
  def mass
    unless @data['MASS']
      hash = Hash.new
      fetch('MASS').scan(/(\S+)\s+\((\S+)\)/).each do |val, key|
        hash[key] = val.to_f
      end
      @data['MASS'] = hash
    end
    @data['MASS']
  end

  # CLASS
  def keggclass
    field_fetch('CLASS') 
  end

  # COMPOUND
  def compounds
    unless @data['COMPOUND']
      @data['COMPOUND'] = fetch('COMPOUND').split(/\s+/)
    end
    @data['COMPOUND']
  end

  # REACTION
  def reactions
    unless @data['REACTION']
      @data['REACTION'] = fetch('REACTION').split(/\s+/)
    end
    @data['REACTION']
  end

  # PATHWAY
  def pathways
    lines_fetch('PATHWAY') 
  end

  # ENZYME
  def enzymes
    unless @data['ENZYME']
      field = fetch('ENZYME')
      if /\(/.match(field)	# old version
        @data['ENZYME'] = field.scan(/\S+ \(\S+\)/)
      else
        @data['ENZYME'] = field.scan(/\S+/)
      end
    end
    @data['ENZYME']
  end

  # ORTHOLOGY
  def orthologs
    unless @data['ORTHOLOGY']
      @data['ORTHOLOGY'] = lines_fetch('ORTHOLOGY')
    end
    @data['ORTHOLOGY']
  end

  # COMMENT
  def comment
    field_fetch('COMMENT')
  end

  # REMARK
  def remark
    field_fetch('REMARK')
  end

  # REFERENCE
  def references
    unless @data['REFERENCE']
      ary = Array.new
      lines = lines_fetch('REFERENCE')
      lines.each do |line|
        if /^\d+\s+\[PMID/.match(line)
          ary << line
        else
          ary.last << " #{line.strip}"
        end
      end
      @data['REFERENCE'] = ary
    end
    @data['REFERENCE']
  end

  # DBLINKS
  def dblinks
    unless @data['DBLINKS']
      @data['DBLINKS'] = lines_fetch('DBLINKS')
    end
    @data['DBLINKS']
  end

  # ATOM, BOND
  def kcf
    return "#{get('NODE')}#{get('EDGE')}"
  end

end # GLYCAN

end # KEGG
end # Bio


if __FILE__ == $0
  entry = ARGF.read	# gl:G00024
  gl = Bio::KEGG::GLYCAN.new(entry)
  p gl.entry_id
  p gl.name
  p gl.composition
  p gl.mass
  p gl.keggclass
  p gl.bindings
  p gl.compounds
  p gl.reactions
  p gl.pathways
  p gl.enzymes
  p gl.orthologs
  p gl.references
  p gl.dblinks
  p gl.kcf
end


