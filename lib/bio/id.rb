#
# bio/id.rb - biological 'database:entry_id' link class
#
#   Copyright (C) 2001 KATAYAMA Toshiaki <k@bioruby.org>
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
#  $Id: id.rb,v 1.1 2001/12/19 12:20:04 katayama Exp $
#

require 'bio/io/brdb'
require 'bio/io/dbget'
require 'bio/io/flatfile'
require 'bio/io/pubmed'

module Bio

  class ID

    @@brclass = {}

    def self.register(db, dbclass)
      @@brclass[db] = dbclass
    end

    def self.dblist
      @@brclass.inspect
    end

    def initialize(db, entry_id)
      @db = db
      @entry_id = entry_id
      @brclass = @@brclass[db]		# nil if not found
    end

    def to_s
      "#{@db}:#{@entry_id}"
    end

    def anchor(uri = 'http://www.genome.ad.jp/dbget-bin/www_bget?')
      "<a href=\"#{uri}#{self.to_s}\">#{self.to_s}</a>"
    end

    def bget
      entry = Bio::DBGET.bget(self.to_s)
      @brclass.new(entry)
    end

    def brdb(*args)
      server = Bio::BRDB.new(*args)
      entry = server.get(@db, @entry_id)
      server.close
      @brclass.brdb(entry)
    end

    def flatfile(filename)
      ff = Bio::FlatFile.open(@brclass, filename)
      ff.each do |x|
	if @entry_id = x.entry_id
	  return x
	end
      end
    end

    # Bio::FastaFormat only (fasta:entry_id)
    def sfetch(filename)
      entry = IO.popen("sfetch -d #{filename} #{@entry_id}").read
      Bio::FastaFormat.new(entry)
    end

    # Bio::MEDLINE only (pubmed:entry_id)
    def pubmed
      entry = Bio::PubMed.query(@entry_id)
      Bio::MEDLINE.new(entry)
    end

  end

end


if __FILE__ == $0
  require 'bio'
  p a = Bio::ID.new('gb', 'AF079587')
  p a.to_s
  puts a.anchor
  p a.bget
  p a.brdb
end


=begin

= Bio::ID

The Bio::ID object is a unique identifier of the database and the entry,
and can be used for storing the external links to the entries of the other
biological databases.  This object also can retrieve the actual contents of
the entry as the fully parsed BioRuby object from several sources:

  * In-house BioRuby formatted database (BioRuby-DB/MySQL)
  * GenomeNet/((<DBGET|URL:http://www.genome.ad.jp/dbget/>)) network client
  * NCBI/PubMed literature database
  * A flatfile you specified (Note : 'sfetch' program provided by the
    ((<HMMER|URL:http://hmmer.wustl.edu/>)) package can be used to retrieve
    FASTA format sequence faster)

Any database parsers put under the bio/db/ directory should register its
abbreviated database name and the parser class name of itself.  (Or the
common database names should be defined in this class?)

--- Bio::ID.register(db, dbclass)

      Register the database name and the corresponding BioRuby class.
      Mainly used by BioRuby library internally.

--- Bio::ID.dblist

      List up available database names as Hash.

--- Bio::ID.new(db, entry_id)

      Example:
        Bio::ID.new('gb', 'AF179299')

--- Bio::ID#to_s

      Returns a String containing a database name and a entry_id joind by
      a colon such as "gb:AF179299".

--- Bio::ID#anchor(uri)

      Returns a piece of HTML having href to the 'uri'.  By default, returns
      a link to the WWW based GenomeNet/DBGET CGI.

--- Bio::ID#bget

      Returns BioRuby object by using Bio::DBGET I/O class.
        id_obj = Bio::ID.new('gb', 'AF179299')
        id_obj.bget	# => parsed Bio::GenBank object

--- Bio::ID#brdb(*args)

      Returns a BioRuby object by using Bio::BRDB I/O class if you have
      an in-house BioRuby-DB/MySQL for the corresponding database.
      The *args are equivalent for the MySQL.new().
        id_obj = Bio::ID.new('gb', 'AF179299')
        id_obj.brgb	# => parsed Bio::GenBank object

--- Bio::ID#flatfile(filename)

      Search the entry from the specified file by using Bio::FlatFile I/O
      class and returns a BioRuby object.

--- Bio::ID#sfetch(filename)

      Search the FASTA entry from the specified file by using sfetch program
      shipped with the ((<HMMER|URL:http://hmmer.wustl.edu/>)) package.

--- Bio::ID#pubmed

      Returns PubMed entry as a Bio::MEDLINE object by using Bio::PubMed I/O
      class.

=end

