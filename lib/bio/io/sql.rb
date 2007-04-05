#
# = bio/io/sql.rb - BioSQL access module
#
# Copyright::  Copyright (C) 2002 Toshiaki Katayama <k@bioruby.org>
# Copyright::  Copyright (C) 2006 Raoul Jean Pierre Bonnal <raoul.bonnal@itb.cnr.it>
# License::    The Ruby License
#
# $Id: sql.rb,v 1.8 2007/04/05 23:35:41 trevor Exp $
#

begin
  require 'dbi'
rescue LoadError
end
require 'bio/sequence'
require 'bio/feature'


module Bio

class SQL

  def initialize(db = 'dbi:Mysql:biosql', user = nil, pass = nil)
    @dbh = DBI.connect(db, user, pass)
  end

  def close
    @dbh.disconnect
  end

  # Returns Bio::SQL::Sequence object.
  def fetch(accession)	# or display_id for fall back
    query = "select * from bioentry where accession = ?"
    entry = @dbh.execute(query, accession).fetch
    return Sequence.new(@dbh, entry) if entry

    query = "select * from bioentry where display_id = ?"
    entry = @dbh.execute(query, accession).fetch
    return Sequence.new(@dbh, entry) if entry
  end
  alias get_by_id fetch


  # for lazy fetching

  class Sequence

    def initialize(dbh, entry)
      @dbh = dbh
      @bioentry_id = entry['bioentry_id']
      @database_id = entry['biodatabase_id']
      @entry_id = entry['display_id']
      @accession = entry['accession']
      @version = entry['entry_version']
      @division = entry['division']
    end
    attr_reader :accession, :division, :entry_id, :version


    def to_fasta
      if seq = seq
        return seq.to_fasta(@accession)
      end
    end

    # Returns Bio::Sequence::NA or AA object.
    def seq
      query = "select * from biosequence where bioentry_id = ?"
      row = @dbh.execute(query, @bioentry_id).fetch
      return unless row

      mol = row['alphabet']
      seq = row['seq']

      case mol
      when /.na/i			# 'dna' or 'rna'
        Bio::Sequence::NA.new(seq)
      else				# 'protein'
        Bio::Sequence::AA.new(seq)
      end
    end

    # Returns Bio::Sequence::NA or AA object (by lazy fetching).
    def subseq(from, to)
      length = to - from + 1
      query = "select alphabet, substring(seq, ?, ?) as subseq" +
              " from biosequence where bioentry_id = ?"
      row = @dbh.execute(query, from, length, @bioentry_id).fetch
      return unless row

      mol = row['alphabet']
      seq = row['subseq']

      case mol
      when /.na/i			# 'dna' or 'rna'
        Bio::Sequence::NA.new(seq)
      else				# 'protein'
        Bio::Sequence::AA.new(seq)
      end
    end


    # Returns Bio::Features object.
    def features
      array = []
      query = "select * from seqfeature where bioentry_id = ?"
      @dbh.execute(query, @bioentry_id).fetch_all.each do |row|
        next unless row

        f_id = row['seqfeature_id']
        k_id = row['type_term_id']
        s_id = row['source_term_id']
        rank = row['rank'].to_i - 1

        # key : type (gene, CDS, ...)
        type = feature_key(k_id)

        # source : database (EMBL/GenBank/SwissProt)
        database = feature_source(s_id)

        # location : position
        locations = feature_locations(f_id)

        # qualifier
        qualifiers = feature_qualifiers(f_id)

        # rank
        array[rank] = Bio::Feature.new(type, locations, qualifiers)
      end
      return Bio::Features.new(array)
    end


    # Returns reference informations in Array of Hash (not Bio::Reference).
    def references
      array = []
      query = <<-END
        select * from bioentry_reference, reference
        where bioentry_id = ? and
        bioentry_reference.reference_id = reference.reference_id
      END
      @dbh.execute(query, @bioentry_id).fetch_all.each do |row|
        next unless row

        hash = {
          'start'	=> row['start_pos'],
          'end'		=> row['end_pos'],
          'journal'	=> row['location'],
          'title'	=> row['title'],
          'authors'	=> row['authors'],
          'medline'	=> row['crc']
        }
        hash.default = ''

        rank = row['rank'].to_i - 1
        array[rank] = hash
      end
      return array
    end


    # Returns the first comment.  For complete comments, use comments method.
    def comment
      query = "select * from comment where bioentry_id = ?"
      row = @dbh.execute(query, @bioentry_id).fetch
      row ? row['comment_text'] : ''
    end

    # Returns comments in an Array of Strings.
    def comments
      array = []
      query = "select * from comment where bioentry_id = ?"
      @dbh.execute(query, @bioentry_id).fetch_all.each do |row|
        next unless row
        rank = row['rank'].to_i - 1
        array[rank] = row['comment_text']
      end
      return array
    end

    def database
      query = "select * from biodatabase where biodatabase_id = ?"
      row = @dbh.execute(query, @database_id).fetch
      row ? row['name'] : ''
    end

    def date
      query = "select * from bioentry_date where bioentry_id = ?"
      row = @dbh.execute(query, @bioentry_id).fetch
      row ? row['date'] : ''
    end

    def dblink
      query = "select * from bioentry_direct_links where source_bioentry_id = ?"
      row = @dbh.execute(query, @bioentry_id).fetch
      row ? [row['dbname'], row['accession']] : []
    end

    def definition
      query = "select * from bioentry_description where bioentry_id = ?"
      row = @dbh.execute(query, @bioentry_id).fetch
      row ? row['description'] : ''
    end

    def keyword
      query = "select * from bioentry_keywords where bioentry_id = ?"
      row = @dbh.execute(query, @bioentry_id).fetch
      row ? row['keywords'] : ''
    end

    # Use lineage, common_name, ncbi_taxa_id methods to extract in detail.
    def taxonomy
      query = <<-END
        select taxon_name.name, taxon.ncbi_taxon_id from bioentry
        join taxon_name using(taxon_id) join taxon using (taxon_id)
        where bioentry_id = ?
      END
      row = @dbh.execute(query, @bioentry_id).fetch
#     @lineage = row ? row['full_lineage'] : ''
      @common_name = row ? row['name'] : ''
      @ncbi_taxa_id = row ? row['ncbi_taxon_id'] : ''
      row ? [@lineage, @common_name, @ncbi_taxa_id] : []
    end

    def lineage
      taxonomy unless @lineage
      return @lineage
    end

    def common_name
      taxonomy unless @common_name
      return @common_name
    end

    def ncbi_taxa_id
      taxonomy unless @ncbi_taxa_id
      return @ncbi_taxa_id
    end


    private

    def feature_key(k_id)
      query = "select * from term where term_id= ?"
      row = @dbh.execute(query, k_id).fetch
      row ? row['name'] : ''
    end

    def feature_source(s_id)
      query = "select * from term where term_id = ?"
      row = @dbh.execute(query, s_id).fetch
      row ? row['name'] : ''
    end

    def feature_locations(f_id)
      locations = []
      query = "select * from location where seqfeature_id = ?"
      @dbh.execute(query, f_id).fetch_all.each do |row|
        next unless row

        location = Bio::Location.new
        location.strand = row['strand']
        location.from = row['start_pos']
        location.to = row['end_pos']

        xref = feature_locations_remote(row['dbxref_if'])
        location.xref_id = xref.shift unless xref.empty?

        # just omit fuzzy location for now...
        #feature_locations_qv(row['seqfeature_location_id'])

        rank = row['rank'].to_i - 1
        locations[rank] = location
      end
      return Bio::Locations.new(locations)
    end

    def feature_locations_remote(l_id)
      query = "select * from  dbxref where dbxref_id = ?"
      row = @dbh.execute(query, l_id).fetch
      row ? [row['accession'], row['version']] : []
    end

    def feature_locations_qv(l_id)
      query = "select * from location_qualifier_value where location_id = ?"
      row = @dbh.execute(query, l_id).fetch
      row ? [row['value'], row['int_value']] : []
    end

    def feature_qualifiers(f_id)
      qualifiers = []
      query = "select * from seqfeature_qualifier_value where seqfeature_id = ?"
      @dbh.execute(query, f_id).fetch_all.each do |row|
        next unless row

        key = feature_qualifiers_key(row['seqfeature_id'])
        value = row['value']
        qualifier = Bio::Feature::Qualifier.new(key, value)

        rank = row['rank'].to_i - 1
        qualifiers[rank] = qualifier
      end
      return qualifiers.compact	# .compact is nasty hack for a while
    end

    def feature_qualifiers_key(q_id)
      query = <<-END
        select * from seqfeature_qualifier_value
        join term using(term_id) where seqfeature_id = ?
      END
      row = @dbh.execute(query, q_id).fetch
      row ? row['name'] : ''
    end
  end

end # SQL

end # Bio


if __FILE__ == $0
  begin
    require 'pp'
    alias p pp
  rescue LoadError
  end

  db = ARGV.empty? ? 'dbi:Mysql:database=biosql;host=localhost' : ARGV.shift
  serv = Bio::SQL.new(db, 'root')

  ent0 = serv.fetch('X76706')
  ent0 = serv.fetch('A15H9FIB')
  ent1 = serv.fetch('J01902')
  ent2 = serv.fetch('X04311')

  pp ent0.features
  pp ent0.references

  pp ent1.seq
  pp ent1.seq.translate
  pp ent1.seq.gc
  pp ent1.subseq(1,20)

  pp ent2.accession
  pp ent2.comment
  pp ent2.comments
  pp ent2.common_name
  pp ent2.database
  pp ent2.date
  pp ent2.dblink
  pp ent2.definition
  pp ent2.division
  pp ent2.entry_id
  pp ent2.features
  pp ent2.keyword
  pp ent2.lineage
  pp ent2.ncbi_taxa_id
  pp ent2.references
  pp ent2.seq
  pp ent2.subseq(1,10)
  pp ent2.taxonomy
  pp ent2.version

end

