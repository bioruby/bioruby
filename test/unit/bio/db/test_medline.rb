#
# test/unit/bio/db/test_medline.rb - Unit test for Bio::MEDLINE
#
# Copyright::  Copyright (C) 2008 Collaborative Drug Discovery, Inc. <github@collaborativedrug.com>
# License::    The Ruby License
#

require 'pathname'
libpath = Pathname.new(File.join(File.dirname(__FILE__), ['..'] * 4, 'lib')).cleanpath.to_s
$:.unshift(libpath) unless $:.include?(libpath)

require 'test/unit'
require 'bio/db/medline'

module Bio
  class TestMEDLINE < Test::Unit::TestCase
    def test_authors
      assert_equal(["Kane, D. W.",
                    "Hohman, M. M.",
                    "Cerami, E. G.",
                    "McCormick, M. W.",
                    "Kuhlmann, K. F.",
                    "Byrd, J. A."], Bio::MEDLINE.new(AGILE).authors)
    end
   
    def test_authors_with_suffix
      assert_equal(["Jenkins, F. A. Jr"], Bio::MEDLINE.new("AU  - Jenkins FA Jr").authors)
    end
    
    def test_authors_with_last_name_all_caps
      assert_equal(["GARTLER, S. M."], Bio::MEDLINE.new("AU  - GARTLER SM").authors)
    end
    
    AGILE = <<-EOMED
PMID- 16734914
OWN - NLM
STAT- MEDLINE
DA  - 20060811
DCOM- 20060928
LR  - 20081120
IS  - 1471-2105 (Electronic)
VI  - 7
DP  - 2006
TI  - Agile methods in biomedical software development: a multi-site experience
      report.
PG  - 273
AB  - BACKGROUND: Agile is an iterative approach to software development that
      relies on strong collaboration and automation to keep pace with dynamic
      environments. We have successfully used agile development approaches to
      create and maintain biomedical software, including software for
      bioinformatics. This paper reports on a qualitative study of our
      experiences using these methods. RESULTS: We have found that agile methods
      are well suited to the exploratory and iterative nature of scientific
      inquiry. They provide a robust framework for reproducing scientific
      results and for developing clinical support systems. The agile development
      approach also provides a model for collaboration between software
      engineers and researchers. We present our experience using agile
      methodologies in projects at six different biomedical software development
      organizations. The organizations include academic, commercial and
      government development teams, and included both bioinformatics and
      clinical support applications. We found that agile practices were a match
      for the needs of our biomedical projects and contributed to the success of
      our organizations. CONCLUSION: We found that the agile development
      approach was a good fit for our organizations, and that these practices
      should be applicable and valuable to other biomedical software development
      efforts. Although we found differences in how agile methods were used, we
      were also able to identify a set of core practices that were common to all
      of the groups, and that could be a focus for others seeking to adopt these
      methods.
AD  - SRA International, 4300 Fair Lakes Court, Fairfax, VA 22033, USA.
      david_kane@sra.com
FAU - Kane, David W
AU  - Kane DW
FAU - Hohman, Moses M
AU  - Hohman MM
FAU - Cerami, Ethan G
AU  - Cerami EG
FAU - McCormick, Michael W
AU  - McCormick MW
FAU - Kuhlmann, Karl F
AU  - Kuhlmann KF
FAU - Byrd, Jeff A
AU  - Byrd JA
LA  - eng
GR  - U01 MH061915-03/MH/NIMH NIH HHS/United States
GR  - U01 MH061915-04/MH/NIMH NIH HHS/United States
GR  - U01 MH61915/MH/NIMH NIH HHS/United States
PT  - Journal Article
PT  - Research Support, N.I.H., Extramural
PT  - Research Support, Non-U.S. Gov't
DEP - 20060530
PL  - England
TA  - BMC Bioinformatics
JT  - BMC bioinformatics
JID - 100965194
SB  - IM
MH  - Algorithms
MH  - Automation
MH  - Computational Biology/*methods
MH  - Computers
MH  - Database Management Systems
MH  - Databases, Genetic
MH  - Diffusion of Innovation
MH  - Hospital Information Systems
MH  - Hospitals
MH  - Humans
MH  - Medical Informatics
MH  - Multicenter Studies as Topic
MH  - Programming Languages
MH  - Software
MH  - *Software Design
MH  - Systems Integration
PMC - PMC1539031
OID - NLM: PMC1539031
EDAT- 2006/06/01 09:00
MHDA- 2006/09/29 09:00
CRDT- 2006/06/01 09:00
PHST- 2005/11/17 [received]
PHST- 2006/05/30 [accepted]
PHST- 2006/05/30 [aheadofprint]
AID - 1471-2105-7-273 [pii]
AID - 10.1186/1471-2105-7-273 [doi]
PST - epublish
SO  - BMC Bioinformatics. 2006 May 30;7:273.
EOMED
  end
end
