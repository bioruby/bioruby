#
# = bio/shell/plugin/entry.rb - extract entry and sequence
#
# Copyright::   Copyright (C) 2005
#               Toshiaki Katayama <k@bioruby.org>
# License::     Ruby's
#
# $Id: entry.rb,v 1.8 2006/02/27 09:37:14 k Exp $
#

module Bio::Shell

  private

  # Obtain a Bio::Sequence::NA (DNA) or a Bio::Sequence::AA (Amino Acid)
  # sequence from
  #   * String     -- "atgcatgc" or "MQKKP"
  #   * IO         -- io = IO.popen("gzip -dc db.gz") (first entry only)
  #   * "filename" -- "gbvrl.gbk" (first entry only)
  #   * "db:entry" -- "embl:BUM"  (entry is retrieved by the ent method)
  def seq(arg)
    seq = ""
    if arg.kind_of?(Bio::Sequence)
      seq = arg
    elsif arg.respond_to?(:gets) or File.exists?(arg)
      ent = flatauto(arg)
    elsif arg[/:/]
      str = ent(arg)
      ent = flatparse(str)
    else
      tmp = arg
    end

    if ent.respond_to?(:seq)
      tmp = ent.seq
    elsif ent.respond_to?(:naseq)
      seq = ent.naseq
    elsif ent.respond_to?(:aaseq)
      seq = ent.aaseq
    end

    if tmp and tmp.is_a?(String) and not tmp.empty?
      seq = Bio::Sequence.auto(tmp).seq
    end
    return seq
  end

  # Obtain a database entry from
  #   * IO          -- IO object (first entry only)
  #   * "filename"  -- local file (first entry only)
  #   * "db:entry"  -- local BioFlat, OBDA, EMBOSS, KEGG API
  def ent(arg)
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
  def obj(arg)
    str = ent(arg)
    flatparse(str)
  end

end
