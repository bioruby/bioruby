#
# = bio/shell/plugin/flatfile.rb - plugin for flatfile database
#
# Copyright::	Copyright (C) 2005
#		Toshiaki Katayama <k@bioruby.org>
# License::	LGPL
#
# $Id: flatfile.rb,v 1.7 2005/11/25 16:47:10 k Exp $
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

require 'bio/io/flatfile'

module Bio::Shell

  private

  def flatfile(filename)
    if block_given?
      Bio::FlatFile.auto(filename) do |flat|
        flat.each do |entry|
          yield flat.entry_raw
        end
      end
    else
      entry = ''
      Bio::FlatFile.auto(filename) do |flat|
        flat.next_entry
        entry = flat.entry_raw
      end
      return entry
    end
  end

  def flatauto(filename)
    if block_given?
      Bio::FlatFile.auto(filename) do |flat|
        flat.each do |entry|
          yield entry
        end
      end
    else
      entry = ''
      Bio::FlatFile.auto(filename) do |flat|
        entry = flat.next_entry
      end
      return entry
    end
  end

  def parse(entry)
    if cls = Bio::FlatFile.autodetect(entry)
      return cls.new(entry)
    end
  end

  def flatfasta(fastafile, *flatfiles)
    puts "Saving fasta file (#{fastafile}) ... "
    File.open(fastafile, "w") do |fasta|
      flatfiles.each do |flatfile|
        puts "  converting -- #{flatfile}"
        Bio::FlatFile.auto(flatfile) do |flat|
          flat.each do |entry|
            header = "#{entry.entry_id} #{entry.definition}"
            fasta.puts entry.seq.to_fasta(header, 50)
          end
        end
      end
    end
    puts "done"
  end

  def flatindex(dbname, *flatfiles)
    prefix = Bio::Shell.create_save_dir + Core::BIOFLAT
    idxdir = prefix + dbname.to_s
    begin
      print "Creating BioFlat index (#{idxdir}) ... "
      bdb = format = options = nil
      Bio::FlatFileIndex.makeindex(bdb, idxdir, format, options, *flatfiles)
      puts "done"
    rescue
      warn "Error: Failed to create index (#{idxdir}) : #{$!}"
    end
  end

  def flatsearch(dbname, keyword)
    dir = Core::SAVEDIR + Core::BIOFLAT + dbname.to_s
    dir = Core::USERDIR + Core::BIOFLAT + dbname.to_s unless File.exists?(dir)
    Bio::FlatFileIndex.open(dir) do |db|
      if results = db.include?(keyword)
        results.each do |entry_id|
          display db.search_primary(entry_id)
        end
      else
        display "No hits found"
      end
    end
  end

=begin
  def bioflat_namespaces(dbname)
    dir = Core::SAVEDIR + Core::BIOFLAT + dbname.to_s
    db = Bio::FlatFileIndex.open(dir)
    display db.namespaces.inspect
    db.close
  end
=end

end
