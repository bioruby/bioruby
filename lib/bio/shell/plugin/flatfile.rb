#
# = bio/shell/plugin/flatfile.rb - plugin for flatfile database
#
# Copyright::   Copyright (C) 2005
#               Toshiaki Katayama <k@bioruby.org>
# License::     The Ruby License
#
# $Id: flatfile.rb,v 1.13 2007/04/05 23:45:11 trevor Exp $
#

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

  def flatparse(entry)
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
    begin
      dir = Bio::Shell.create_flat_dir(dbname)
      print "Creating BioFlat index (#{dir}) ... "
      bdb = format = options = nil
      Bio::FlatFileIndex.makeindex(bdb, dir, format, options, *flatfiles)
      puts "done"
    rescue
      warn "Error: Failed to create index (#{dir}) : #{$!}"
    end
  end

  def flatsearch(dbname, keyword)
    dir = Bio::Shell.find_flat_dir(dbname)
    unless dir
      warn "Error: Failed to open database (#{dbname})"
      return
    end
    entry = ''
    Bio::FlatFileIndex.open(dir) do |db|
      if results = db.include?(keyword)
        results.each do |entry_id|
          entry << db.search_primary(entry_id).to_s
        end
      else
        warn "Error: No hits found in #{dbname} (#{keyword})"
      end
    end
    return entry
  end

end
