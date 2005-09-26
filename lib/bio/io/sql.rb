#
# bio/io/sql.rb - BioSQL access module
#
#   Copyright (C) 2002 KATAYAMA Toshiaki <k@bioruby.org>
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
#  $Id: sql.rb,v 1.4 2005/09/26 13:04:28 k Exp $
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

      def seq
        query = "select * from biosequence where bioentry_id = ?"
        row = @dbh.execute(query, @bioentry_id).fetch
        return unless row

        mol = row['molecule']
        seq = row['biosequence_str']

        case mol
        when /.na/i			# 'dna' or 'rna'
          Bio::Sequence::NA.new(seq)
        else				# 'protein'
          Bio::Sequence::AA.new(seq)
        end
      end

      def subseq(from, to)
        length = to - from + 1
        query = "select molecule, substring(biosequence_str, ?, ?) as subseq" +
                " from biosequence where bioentry_id = ?"
        row = @dbh.execute(query, from, length, @bioentry_id).fetch
        return unless row

        mol = row['molecule']
        seq = row['subseq']

        case mol
        when /.na/i			# 'dna' or 'rna'
          Bio::Sequence::NA.new(seq)
        else				# 'protein'
          Bio::Sequence::AA.new(seq)
        end
      end


      def features
        array = []
        query = "select * from seqfeature where bioentry_id = ?"
        @dbh.execute(query, @bioentry_id).fetch_all.each do |row|
          next unless row

          f_id = row['seqfeature_id']
          k_id = row['seqfeature_key_id']
          s_id = row['seqfeature_source_id']
          rank = row['seqfeature_rank'].to_i - 1

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
            'start'	=> row['reference_start'],
            'end'	=> row['reference_end'],
            'journal'	=> row['reference_location'],
            'title'	=> row['reference_title'],
            'authors'	=> row['reference_authors'],
            'medline'	=> row['reference_medline']
          }
          hash.default = ''

          rank = row['reference_rank'].to_i - 1
          array[rank] = hash
        end
        return array
      end


      def comment
        query = "select * from comment where bioentry_id = ?"
        row = @dbh.execute(query, @bioentry_id).fetch
        row ? row['comment_text'] : ''
      end

      def comments
        array = []
        query = "select * from comment where bioentry_id = ?"
        @dbh.execute(query, @bioentry_id).fetch_all.each do |row|
          next unless row
          rank = row['comment_rank'].to_i - 1
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

      def taxonomy
        query = <<-END
          select full_lineage, common_name, ncbi_taxa_id
          from bioentry_taxa, taxa
          where bioentry_id = ? and bioentry_taxa.taxa_id = taxa.taxa_id
        END
        row = @dbh.execute(query, @bioentry_id).fetch
        @lineage = row ? row['full_lineage'] : ''
        @common_name = row ? row['common_name'] : ''
        @ncbi_taxa_id = row ? row['ncbi_taxa_id'] : ''
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
        query = "select * from seqfeature_key where seqfeature_key_id = ?"
        row = @dbh.execute(query, k_id).fetch
        row ? row['key_name'] : ''
      end

      def feature_source(s_id)
        query = "select * from seqfeature_source where seqfeature_source_id = ?"
        row = @dbh.execute(query, s_id).fetch
        row ? row['source_name'] : ''
      end

      def feature_locations(f_id)
        locations = []
        query = "select * from seqfeature_location where seqfeature_id = ?"
        @dbh.execute(query, f_id).fetch_all.each do |row|
          next unless row

          location = Bio::Location.new
          location.strand = row['seq_strand']
          location.from = row['seq_start']
          location.to = row['seq_end']

          xref = feature_locations_remote(row['seqfeature_location_id'])
          location.xref_id = xref.shift unless xref.empty?

          # just omit fuzzy location for now...
          #feature_locations_qv(row['seqfeature_location_id'])

          rank = row['location_rank'].to_i - 1
          locations[rank] = location
        end
        return Bio::Locations.new(locations)
      end

      def feature_locations_remote(l_id)
        query = "select * from remote_seqfeature_name where seqfeature_location_id = ?"
        row = @dbh.execute(query, l_id).fetch
        row ? [row['accession'], row['version']] : []
      end

      def feature_locations_qv(l_id)
        query = "select * from location_qualifier_value where seqfeature_location_id = ?"
        row = @dbh.execute(query, l_id).fetch
        row ? [row['qualifier_value'], row['slot_value']] : []
      end

      def feature_qualifiers(f_id)
        qualifiers = []
        query = "select * from seqfeature_qualifier_value where seqfeature_id = ?"
        @dbh.execute(query, f_id).fetch_all.each do |row|
          next unless row

          key = feature_qualifiers_key(row['seqfeature_qualifier_id'])
          value = row['qualifier_value']
          qualifier = Bio::Feature::Qualifier.new(key, value)

          rank = row['seqfeature_qualifier_rank'].to_i - 1
          qualifiers[rank] = qualifier
        end
        return qualifiers.compact	# .compact is nasty hack for a while
      end

      def feature_qualifiers_key(q_id)
        query = "select * from seqfeature_qualifier where seqfeature_qualifier_id = ?"
        row = @dbh.execute(query, q_id).fetch
        row ? row['qualifier_name'] : ''
      end
    end

  end

end


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


=begin

= Bio::SQL

--- Bio::SQL.new(db = 'dbi:Mysql:biosql', user = nil, pass = nil)

--- Bio::SQL.close

--- Bio::SQL#fetch(accession)

      Returns Bio::SQL::Sequence object.

== Bio::SQL::Sequence

--- Bio::SQL::Sequence.new(dbh, entry)

--- Bio::SQL::Sequence#accession -> String
--- Bio::SQL::Sequence#comment -> String

      Returns the first comment.  For complete comments, use comments method.

--- Bio::SQL::Sequence#comments -> Array

      Returns comments in an Array of Strings.

--- Bio::SQL::Sequence#common_name -> String
--- Bio::SQL::Sequence#database -> String
--- Bio::SQL::Sequence#date -> String
--- Bio::SQL::Sequence#dblink -> Array
--- Bio::SQL::Sequence#definition -> String
--- Bio::SQL::Sequence#division -> String
--- Bio::SQL::Sequence#entry_id -> String

--- Bio::SQL::Sequence#features

      Returns Bio::Features object.

--- Bio::SQL::Sequence#keyword -> String
--- Bio::SQL::Sequence#lineage -> String
--- Bio::SQL::Sequence#ncbi_taxa_id -> String

--- Bio::SQL::Sequence#references -> Array

      Returns reference informations in Array of Hash (not Bio::Reference).

--- Bio::SQL::Sequence#seq

      Returns Bio::Sequence::NA or AA object.

--- Bio::SQL::Sequence#subseq(from, to)

      Returns Bio::Sequence::NA or AA object (by lazy fetching).

--- Bio::SQL::Sequence#taxonomy -> DBI::Row

      Use lineage, common_name, ncbi_taxa_id methods to extract in detail.

--- Bio::SQL::Sequence#version -> String

=end

