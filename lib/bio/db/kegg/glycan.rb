#
# = bio/db/kegg/glycan.rb - KEGG GLYCAN database class
#
# Copyright::  Copyright (C) 2004 Toshiaki Katayama <k@bioruby.org>
# License::    The Ruby License
#
# $Id:$
#

require 'bio/db'
require 'bio/db/kegg/common'

module Bio
class KEGG

class GLYCAN < KEGGDB

  DELIMITER	= RS = "\n///\n"
  TAGSIZE	= 12

  include Common::DblinksAsHash
  # Returns a Hash of the DB name and an Array of entry IDs in DBLINKS field.
  def dblinks_as_hash; super; end if false #dummy for RDoc
  alias dblinks dblinks_as_hash

  include Common::PathwaysAsHash
  # Returns a Hash of the pathway ID and name in PATHWAY field.
  def pathways_as_hash; super; end if false #dummy for RDoc
  alias pathways pathways_as_hash

  include Common::OrthologsAsHash
  # Returns a Hash of the orthology ID and definition in ORTHOLOGY field.
  def orthologs_as_hash; super; end if false #dummy for RDoc
  alias orthologs orthologs_as_hash

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
      @data['MASS'] = field_fetch('MASS')[/[\d\.]+/].to_f
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
  def pathways_as_strings
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
  def orthologs_as_strings
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
  def dblinks_as_strings
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

