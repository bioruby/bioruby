#
# = bio/shell/plugin/obda.rb - plugin for OBDA
#
# Copyright::   Copyright (C) 2005
#               Toshiaki Katayama <k@bioruby.org>
# License::     The Ruby License 
#
# $Id: obda.rb,v 1.10 2007/04/05 23:45:11 trevor Exp $
#

module Bio::Shell

  private

  def obda
    @obda ||= Bio::Registry.new
  end

  def obdaentry(dbname, entry_id)
    db = obda.get_database(dbname)
    unless db
      warn "Error: No such database (#{dbname})"
      return
    end
    entry = db.get_by_id(entry_id)
    if block_given?
      yield entry
    else
      return entry
    end
  end

  def obdadbs
    result = obda.databases.map {|db| db.database}
    return result
  end

  def biofetch(db, id, style = 'raw', format = 'default')
    serv = Bio::Fetch.new("http://www.ebi.ac.uk/cgi-bin/dbfetch")
    result = serv.fetch(db, id, style, format)
    return result
  end

end

