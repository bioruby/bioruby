#
# = bio/shell/plugin/entry.rb - extract entry and sequence
#
# Copyright::   Copyright (C) 2005
#               Toshiaki Katayama <k@bioruby.org>
# License::     The Ruby License
#
# $Id: entry.rb,v 1.10 2007/04/05 23:35:41 trevor Exp $
#

module Bio::Shell

  private

  # Read a text file and collect the first word of each line in array
  def readlist(filename)
    list = []
    File.open(filename).each do |line|
      list << line[/^\S+/]
    end
    return list
  end

  # Obtain a Bio::Sequence::NA (DNA) or a Bio::Sequence::AA (Amino Acid)
  # sequence from
  #   * String     -- "atgcatgc" or "MQKKP"
  #   * IO         -- io = IO.popen("gzip -dc db.gz") (first entry only)
  #   * "filename" -- "gbvrl.gbk" (first entry only)
  #   * "db:entry" -- "embl:BUM"  (entry is retrieved by the ent method)
  def getseq(arg)
    seq = ""
    if arg.kind_of?(Bio::Sequence)
      seq = arg
    elsif arg.respond_to?(:gets) or File.exists?(arg)
      ent = flatauto(arg)
    elsif arg[/:/]
      ent = getobj(arg)
    else
      tmp = arg
    end

    if ent.respond_to?(:seq)
      tmp = ent.seq
    elsif ent.respond_to?(:naseq)
      #seq = ent.naseq
      tmp = ent.naseq
    elsif ent.respond_to?(:aaseq)
      #seq = ent.aaseq
      tmp = ent.aaseq
    end

    if tmp and tmp.is_a?(String) and not tmp.empty?
      #seq = Bio::Sequence.auto(tmp).seq
      seq = Bio::Sequence.auto(tmp)
    end
    return seq
  end

  # Obtain a database entry from
  #   * IO          -- IO object (first entry only)
  #   * "filename"  -- local file (first entry only)
  #   * "db:entry"  -- local BioFlat, OBDA, EMBOSS, KEGG API
  def getent(arg)
    entry = ""
    db, entry_id = arg.to_s.strip.split(/:/)

    # local file
    if arg.respond_to?(:gets) or File.exists?(arg)
      puts "Retrieving entry from file (#{arg})"
      entry = flatfile(arg)

    # BioFlat in ./.bioruby/bioflat/ or ~/.bioinformatics/.bioruby/bioflat/
    elsif Bio::Shell.find_flat_dir(db)
      puts "Retrieving entry from local BioFlat database (#{arg})"
      entry = flatsearch(db, entry_id)

    # OBDA in ~/.bioinformatics/seqdatabase.ini
    elsif obdadbs.include?(db)
      puts "Retrieving entry from OBDA (#{arg})"
      entry = obdaentry(db, entry_id)

    else
      # EMBOSS USA in ~/.embossrc
      str = entret(arg)
      if $?.exitstatus == 0 and str.length != 0
        puts "Retrieving entry from EMBOSS (#{arg})"
        entry = str

      # KEGG API at http://www.genome.jp/kegg/soap/
      else
        puts "Retrieving entry from KEGG API (#{arg})"
        entry = bget(arg)
      end
    end

    return entry
  end

  # Obtain a parsed object from sources that ent() supports.
  def getobj(arg)
    str = getent(arg)
    flatparse(str)
  end

end
