#
# = bio/shell/plugin/keggapi.rb - plugin for KEGG API
#
# Copyright::	Copyright (C) 2005
#		Toshiaki Katayama <k@bioruby.org>
# License::	LGPL
#
# $Id: keggapi.rb,v 1.5 2005/11/28 07:18:14 k Exp $
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

require 'bio/io/keggapi'

module Bio::Shell

  module Private
    def keeggapi_definition2tab(list)
      ary = []
      list.each do |entry|
        ary << "#{entry.entry_id}:\t#{entry.definition}"
      end
      return ary
    end
  end

  private

  def keggapi
    unless @keggapi
      @keggapi = Bio::KEGG::API.new
    end
    return @keggapi
  end

  # DBGET

  def binfo(db = "all")
    result = keggapi.binfo(db)
    display result
    return result
  end

  def bfind(str)
    result = keggapi.bfind(str)
    display result
    return result
  end

  def bget(str)
    result = keggapi.bget(str)
    if block_given?
      yield result
    else
      return result
    end
  end

  def btit(str)
    result = keggapi.btit(str)
    display result
    return result
  end

  def bconv(str)
    result = keggapi.bconv(str)
    display result
    return result
  end

  # DATABASES

  def keggdbs
    list = keggapi.list_databases
    result = Bio::Shell.keggapi_definition2tab(list).join("\n")
    display result
    return result
  end

  def keggorgs
    list = keggapi.list_organisms
    result = Bio::Shell.keggapi_definition2tab(list).sort.join("\n")
    display result
    return result
  end

  def keggpathways(org = "map")
    list = keggapi.list_pathways(org)
    result = Bio::Shell.keggapi_definition2tab(list).join("\n")
    display result
    return result
  end

=begin
  def kegggenome(org)	# *TODO* use das instead?
    result = ""
    require 'net/ftp'
    Net::FTP.open("ftp.genome.jp", "anonymous") do |ftp|
      path = "/pub/kegg/genomes/#{org}"
      list = ftp.nlst(path)
      file = list.grep(/.*genome$/).shift
      if file
        base = File.basename(file)
        ftp.getbinaryfile(file, base)
        result = File.read(base)
      end
    end
    return result
  end
=end

end

=begin
--- get_linkdb_by_entry(entry_id, db, start, max_results)
--- get_best_best_neighbors_by_gene(genes_id, start, max_results)
--- get_best_neighbors_by_gene(genes_id, start, max_results)
--- get_reverse_best_neighbors_by_gene(genes_id, start, max_results)
--- get_paralogs_by_gene(genes_id, start, max_results)
--- get_motifs_by_gene(genes_id, db)
--- get_genes_by_motifs(motif_id_list, start, max_results)
--- get_ko_by_gene(genes_id)
--- get_ko_by_ko_class(ko_class_id)
--- get_genes_by_ko_class(ko_class_id, org, start, max_results)
--- get_genes_by_ko(ko_id, org)
--- get_oc_members_by_gene(genes_id, start, max_results)
--- get_pc_members_by_gene(genes_id, start, max_results)
--- mark_pathway_by_objects(pathway_id, object_id_list)
--- color_pathway_by_objects(pathway_id, object_id_list, fg_color_list, bg_color_list)
--- get_html_of_marked_pathway_by_objects(pathway_id, object_id_list)
--- get_html_of_colored_pathway_by_objects(pathway_id, object_id_list, fg_color_list, bg_color_list)
--- get_genes_by_pathway(pathway_id)
--- get_enzymes_by_pathway(pathway_id)
--- get_compounds_by_pathway(pathway_id)
--- get_glycans_by_pathway(pathway_id)
--- get_reactions_by_pathway(pathway_id)
--- get_kos_by_pathway(pathway_id)
--- get_pathways_by_genes(genes_id_list)
--- get_pathways_by_enzymes(enzyme_id_list)
--- get_pathways_by_compounds(compound_id_list)
--- get_pathways_by_glycans(glycan_id_list)
--- get_pathways_by_reactions(reaction_id_list)
--- get_pathways_by_kos(ko_id_list, org)
--- get_linked_pathways(pathway_id)
--- get_genes_by_enzyme(enzyme_id, org)
--- get_enzymes_by_gene(genes_id)
--- get_enzymes_by_compound(compound_id)
--- get_enzymes_by_glycan(glycan_id)
--- get_enzymes_by_reaction(reaction_id)
--- get_compounds_by_enzyme(enzyme_id)
--- get_compounds_by_reaction(reaction_id)
--- get_glycans_by_enzyme(enzyme_id)
--- get_glycans_by_reaction(reaction_id)
--- get_reactions_by_enzyme(enzyme_id)
--- get_reactions_by_compound(compound_id)
--- get_reactions_by_glycan(glycan_id)
--- get_genes_by_organism(org, start, max_results)
--- get_number_of_genes_by_organism(org)
--- convert_mol_to_kcf(mol_text)
=end
