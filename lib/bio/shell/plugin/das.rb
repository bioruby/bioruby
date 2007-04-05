#
# = bio/shell/plugin/keggdas.rb - plugin for KEGG DAS
#
# Copyright::   Copyright (C) 2006
#               Toshiaki Katayama <k@bioruby.org>
# License::     The Ruby License
#
# $Id: das.rb,v 1.3 2007/04/05 23:35:41 trevor Exp $
#

module Bio

  class DAS
    def list_sequences
      result = ""
      self.get_dsn.each do |dsn|
        src = dsn.source_id
        self.get_entry_points(src).each do |ep|
          data = [src, ep.entry_id, ep.start.to_i, ep.stop.to_i, "# #{ep.description}"].join("\t") + "\n"
          puts data
          result += data
        end
      end
      return result
    end
  end

end

module Bio::Shell

  private

  # http://www.biodas.org/
  # http://www.dasregistry.org/

  def das(url = nil)
    if url
      @das = Bio::DAS.new(url)
    else
      @das ||= keggdas
    end
  end

  def keggdas(url = "http://das.hgc.jp/cgi-bin/")
    das(url)
  end

  def ensembl(url = "http://das.ensembl.org/")
    das(url)
  end

  def wormbase(url = "http://www.wormbase.org/db/")
    das(url)
  end

end

