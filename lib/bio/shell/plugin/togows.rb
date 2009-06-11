#
# = bio/shell/plugin/togows.rb - plugin for TogoWS REST service
#
# Copyright::   Copyright (C) 2009
#               Naohisa Goto <ng@bioruby.org>
# License::     The Ruby License
#
# $Id:$
#

module Bio::Shell

  private

  # Shortcut method to fetch entry(entries) by using TogoWS REST "entry"
  # service. Multiple databases may be used.
  #
  def togows(ids, *arg)
    Bio::TogoWS::REST.retrieve(ids, *arg)
  end

  # Fetches entry(entries) by using TogoWS REST "entry" service.
  # Same as Bio::TogoWS::REST.entry(database, ids, *arg).
  def togowsentry(database, ids, *arg)
    Bio::TogoWS::REST.entry(database, ids, *arg)
  end

  # Database search by using TogoWS REST "search" service.
  # Same as Bio::TogoWS::REST.search(database, term, *arg).
  def togowssearch(database, term, *arg)
    Bio::TogoWS::REST.search(database, term, *arg)
  end

  # Data format conversion by using TogoWS REST "convert" service.
  # Same as Bio::TogoWS::REST.convert(data, format_from, format_to).
  def togowsconvert(data, format_from, format_to)
    Bio::TogoWS::REST.convert(data, format_from, format_to)
  end

end
