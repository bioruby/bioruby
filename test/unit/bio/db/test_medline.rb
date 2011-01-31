#
# test/unit/bio/db/test_medline.rb - Unit test for Bio::MEDLINE
#
# Copyright::  Copyright (C) 2008 Collaborative Drug Discovery, Inc. <github@collaborativedrug.com>
# License::    The Ruby License
#

# loading helper routine for testing bioruby
require 'pathname'
load Pathname.new(File.join(File.dirname(__FILE__), ['..'] * 3,
                            'bioruby_test_helper.rb')).cleanpath.to_s

# libraries needed for the tests
require 'test/unit'
require 'bio/reference'
require 'bio/db/medline'

module Bio
  class TestMEDLINE_20146148 < Test::Unit::TestCase

    def setup
      filename = File.join(BioRubyTestDataPath, 'medline',
                           '20146148_modified.medline')
      @obj = Bio::MEDLINE.new(File.read(filename))
    end

    def test_self_new
      assert_instance_of(Bio::MEDLINE, @obj)
    end

    def test_reference
      h = {
        'authors' => ["Mattsson, M.", "Summala, H."],
        'affiliations' =>
        [ "Traffic Research Unit, Department of Psychology, University of Helsinki, Finland. markus.mattsson@helsinki.fi" ],
        'journal' => "Traffic Inj Prev",
        'title' =>
        "With power comes responsibility: motorcycle engine power and power-to-weight ratio in relation to accident risk.",
        'pages' => '87-95',
        'issue' => "1",
        'volume' => "11",
        'year' => "2010",
        'pubmed' => "20146148",
        'doi' => "10.1080/15389580903471126",
        'mesh' =>
        [ "Accidents, Traffic/mortality/*statistics & numerical data",
          "Adult",
          "Age Distribution",
          "Body Weight",
          "Female",
          "Finland/epidemiology",
          "Humans",
          "Linear Models",
          "Male",
          "Motorcycles/classification/legislation & jurisprudence/*statistics & numerical data",
          "Questionnaires",
          "Risk",
          "Social Responsibility",
          "Young Adult" ],
        'abstract' => 
        "(The abstract is omitted to avoid copyright issues. Please find the abstract at http://www.ncbi.nlm.nih.gov/pubmed/20146148. We believe that other information in this entry is within public domain, according to \"Copyright and Disclaimers\" in http://www.ncbi.nlm.nih.gov/About/disclaimer.html.)"
      }
      expected = Bio::Reference.new(h)
      assert_equal(expected, @obj.reference)
    end

    def test_pmid
      assert_equal("20146148", @obj.pmid)
    end

    def test_ui
      assert_equal("", @obj.ui)
    end

    def test_ta
      assert_equal("Traffic Inj Prev", @obj.ta)
    end

    def test_vi
      assert_equal("11", @obj.vi)
    end

    def test_ip
      assert_equal("1", @obj.ip)
    end

    def test_pg
      assert_equal("87-95", @obj.pg)
    end

    def test_pages
      assert_equal("87-95", @obj.pages)
    end

    def test_dp
      assert_equal("2010 Feb", @obj.dp)
    end

    def test_year
      assert_equal("2010", @obj.year)
    end

    def test_ti
      expected = "With power comes responsibility: motorcycle engine power and power-to-weight ratio in relation to accident risk."
      assert_equal(expected, @obj.ti)
    end

    def test_ab
      expected = "(The abstract is omitted to avoid copyright issues. Please find the abstract at http://www.ncbi.nlm.nih.gov/pubmed/20146148. We believe that other information in this entry is within public domain, according to \"Copyright and Disclaimers\" in http://www.ncbi.nlm.nih.gov/About/disclaimer.html.)"
      assert_equal(expected, @obj.ab)
    end

    def test_au
      expected = "Mattsson M\nSummala H"
      assert_equal(expected, @obj.au)
    end

    def test_authors
      expected = ["Mattsson, M.", "Summala, H."]
      assert_equal(expected, @obj.authors)
    end

    def test_so
      expected = "Traffic Inj Prev. 2010 Feb;11(1):87-95."
      assert_equal(expected, @obj.so)
    end

    def test_mh
      expected =
        [ "Accidents, Traffic/mortality/*statistics & numerical data",
          "Adult",
          "Age Distribution",
          "Body Weight",
          "Female",
          "Finland/epidemiology",
          "Humans",
          "Linear Models",
          "Male",
          "Motorcycles/classification/legislation & jurisprudence/*statistics & numerical data",
          "Questionnaires",
          "Risk",
          "Social Responsibility",
          "Young Adult"
        ]
      assert_equal(expected, @obj.mh)
    end

    def test_ad
      expected = [ "Traffic Research Unit, Department of Psychology, University of Helsinki, Finland. markus.mattsson@helsinki.fi" ]
      assert_equal(expected, @obj.ad)
    end

    def test_doi
      assert_equal("10.1080/15389580903471126", @obj.doi)
    end

    def test_pii
      assert_equal("919158438", @obj.pii)
    end

    def test_pt
      expected = [ "Journal Article", "Research Support, Non-U.S. Gov't" ]
      assert_equal(expected, @obj.pt)
    end
  end #class TestMEDLINE_20146148

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
