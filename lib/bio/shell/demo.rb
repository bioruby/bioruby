#
# = bio/shell/demo.rb - demo mode for the BioRuby shell
#
# Copyright::   Copyright (C) 2006
#               Toshiaki Katayama <k@bioruby.org>
# License::     The Ruby License
#
# $Id: demo.rb,v 1.4 2007/04/05 23:35:41 trevor Exp $
#

module Bio::Shell

  private

  def demo(part = nil)
    demo = Demo.new
    if part
      demo.send(part)
    else
      demo.all
    end
  end

  class Demo

    def initialize
      @bind = Bio::Shell.cache[:binding]
    end

    def all
      sequence &&
      entry &&
      shell &&
      pdb &&
      true
    end

    def tutorial
    end

    def aldh2
    end

    def mito
      run(%q[entry = getent("data/kumamushi.gb")], "Load kumamushi gene from GenBank database entry ...", false) &&
      run(%q[disp entry], "Check the contents ...", false) &&
      run(%q[kuma = flatparse(entry)], "Parse the database entry ...", true) &&
      run(%q[web], "Start BioRuby on Rails...", false) &&
      run(%q[puts kuma.entry_id], "Extract entry ID ...", false) &&
      run(%q[puts kuma.definition], "Extract definition ...", false) &&
      run(%q[gene = kuma.seq], "Extract DNA sequence of the gene ...", true) &&
      run(%q[doublehelix(gene)], "Show the sequence in ascii art ...", false) &&
      run(%q[seqstat(gene)], "Statistics of the gene ...", false) &&
      run(%q[config :color], "Change to color mode...", false) &&
      run(%q[seqstat(gene)], "Statistics of the gene ...", false) &&
      #run(%q[codontable], "Codontalble ...", false) &&
      run(%q[protein = gene.translate], "Translate DNA into protein ...", true) &&
      run(%q[comp = protein.composition], "Composition of the amino acids ...", false) &&
      run(%q[pp comp], "Check the composition ...", false) &&
      run(%q[puts protein.molecular_weight], "Molecular weight ...", false) &&
      run(%q[midifile("data/kumamushi.mid", gene)], "Gene to music ...", false) &&
      run(%q[`open "data/kumamushi.mid"`], "Let's listen ...", false) &&
      true
    end

    def sequence
      run(%q[dna = getseq("atgc" * 100)], "Generating DNA sequence ...", true) &&
      run(%q[doublehelix dna], "Double helix representation", false) &&
      run(%q[protein = dna.translate], "Translate DNA into Protein ...", true) &&
      run(%q[protein.molecular_weight], "Calculating molecular weight ...", true) &&
      run(%q[protein.composition], "Amino acid composition ...", true) &&
      true
    end

    def entry
      run(%q[kuma = getobj("gb:AF237819")], "Obtain an entry from GenBank database", false) &&
      run(%q[kuma.definition], "Definition of the entry", true) &&
      run(%q[kuma.naseq], "Sequence of the entry", true) &&
      run(%q[kuma.naseq.translate], "Translate the sequence to protein", true) &&
      run(%q[midifile("data/AF237819.mid", kuma.naseq)], "Generate gene music ...", false) &&
      true
    end

    def shell
      run(%q[pwd], "Show current working directory ...", false) &&
      run(%q[dir], "Show directory contents ...", false) &&
      run(%q[dir "shell/session"], "Show directory contents ...", false) &&
      true
    end

    def pdb
      run(%q[ent_1bl8 = getent("pdb:1bl8")], "Retrieving PDB entry 1BL8 ...", false) &&
      run(%q[head ent_1bl8], "Head part of the entry ...", false) &&
      run(%q[savefile("1bl8.pdb", ent_1bl8)], "Saving the original entry in file ...", false) &&
      run(%q[disp "data/1bl8.pdb"], "Look through the entire entry ...", false) &&
      run(%q[pdb_1bl8 = flatparse(ent_1bl8)], "Parsing the entry ...", false) &&
      run(%q[pdb_1bl8.entry_id], "Showing the entry ID ...", true) &&
      run(%q[pdb_1bl8.each_heterogen { |heterogen| p heterogen.resName }], "Showing each heterogen object ...", false) &&
      true
    end

    def pdb_hetdic
#      run(%q[het_dic = open("http://deposit.pdb.org/het_dictionary.txt").read],
#          "Retrieving the het_dic database ...", false) &&
#      run(%q[savefile("data/het_dictionary.txt", het_dic)],
#          "Saving the file ... ", false) &&
      run(%q[het_dic.size], "Bytes of the file ...", true) &&
      run(%q[disp "data/het_dictionary.txt"], "Take a look on the contents ...", true) &&
      run(%q[flatindex("het_dic", "data/het_dictionary.txt")],
          "Creating index to make the seaarchable database ...", false) &&
      run(%q[ethanol = flatsearch("het_dic", "EOH")], "Search an ethanol entry ...", true) &&
      run(%q[osake = flatparse(ethanol)], "Parse the entry ...", true) &&
      run(%q[osake.conect], "Showing connect table (conect) of the molecule ...", true) &&
      true
    end

    private

    def run(cmd, msg, echo)
      comment(msg)
      splash(cmd)
      result = eval(cmd, @bind)
      if echo
        pp result
      end
      continue?
    end

    def comment(msg)
      puts "### #{msg}"
    end

    def splash(msg)
      Bio::Shell.splash_message_action("bioruby> #{msg}")
      print "bioruby> #{msg}"
      gets
    end

    def continue?
      Bio::Shell.ask_yes_or_no("Continue? [y/n] ")
    end

  end

end

