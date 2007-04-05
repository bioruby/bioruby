#
# test/unit/bio/db/test_rebase.rb - Unit test for Bio::REBASE
#
# Author::    Trevor Wennblom  <mailto:trevor@corevx.com>
# Copyright:: Copyright (c) 2005-2007 Midwinter Laboratories, LLC (http://midwinterlabs.com)
# License::   The Ruby License
#
#  $Id: test_soft.rb,v 1.3 2007/04/05 23:35:43 trevor Exp $
#

require 'pathname'
libpath = Pathname.new(File.join(File.dirname(__FILE__), ['..'] * 4, 'lib')).cleanpath.to_s
$:.unshift(libpath) unless $:.include?(libpath)

require 'test/unit'
require 'bio/db/soft'

module Bio #:nodoc:
  class TestSOFT < Test::Unit::TestCase #:nodoc:
    
    def setup
      bioruby_root = Pathname.new(File.join(File.dirname(__FILE__), ['..'] * 4)).cleanpath.to_s
      test_data_path = Pathname.new(File.join(bioruby_root, 'test', 'data', 'soft')).cleanpath.to_s
      series_filename = File.join(test_data_path, 'GSE3457_family_partial.soft')
      dataset_filename = File.join(test_data_path, 'GDS100_partial.soft')

      @obj_series = Bio::SOFT.new( IO.readlines(series_filename))
      @obj_dataset = Bio::SOFT.new( IO.readlines(dataset_filename))
    end

    def test_series
      assert_equal( @obj_series.platform[:geo_accession], 'GPL2092')
      assert_equal( @obj_series.platform[:organism], 'Populus')
      assert_equal( @obj_series.platform[:contributor], ["Jingyi,,Li", "Olga,,Shevchenko", "Steve,H,Strauss", "Amy,M,Brunner"])
      assert_equal( @obj_series.platform[:data_row_count], '240')
      assert_equal( @obj_series.platform.keys.sort {|a,b| a.to_s <=> b.to_s}[0..2], [:contact_address, :contact_city, :contact_country])
      assert_equal( @obj_series.platform[:"contact_zip/postal_code"], '97331')
      assert_equal( @obj_series.platform[:table].header, ["ID", "GB_ACC", "SPOT_ID", "Function/Family", "ORGANISM", "SEQUENCE"])             
      assert_equal( @obj_series.platform[:table].header_description, {"ORGANISM"=>"sequence sources",
       "SEQUENCE"=>"oligo sequence used",
       "Function/Family"=>"gene functions and family",
       "ID"=>"",
       "SPOT_ID"=>"",
       "GB_ACC"=>"Gene bank accession number"}) 
      assert_equal( @obj_series.platform[:table].rows.size, 240)          
      assert_equal( @obj_series.platform[:table].rows[5], ["A039P68U",
       "AI163321",
       "",
       "TF, flowering protein CONSTANS",
       "P. tremula x P. tremuloides",
       "AGAAAATTCGATATACTGTCCGTAAAGAGGTAGCACTTAGAATGCAACGGAATAAAGGGCAGTTCACCTC"])            
      assert_equal( @obj_series.platform[:table].rows[5][4], 'P. tremula x P. tremuloides')         
      assert_equal( @obj_series.platform[:table].rows[5][:organism], 'P. tremula x P. tremuloides') 
      assert_equal( @obj_series.platform[:table].rows[5]['ORGANISM'], 'P. tremula x P. tremuloides')
      
      assert_equal( @obj_series.series[:geo_accession], 'GSE3457')           
      assert_equal( @obj_series.series[:contributor], ["Jingyi,,Li",
       "Olga,,Shevchenko",
       "Ove,,Nilsson",
       "Steve,H,Strauss",
       "Amy,M,Brunner"])             
      assert_equal( @obj_series.series[:platform_id], 'GPL2092')             
      assert_equal( @obj_series.series[:sample_id].size, 74)          
      assert_equal( @obj_series.series[:sample_id][0..4], ["GSM77557", "GSM77558", "GSM77559", "GSM77560", "GSM77561"])         
                                                                 
      assert_equal( @obj_series.database[:name], 'Gene Expression Omnibus (GEO)')                  
      assert_equal( @obj_series.database[:ref], 'Nucleic Acids Res. 2005 Jan 1;33 Database Issue:D562-6')                   
      assert_equal( @obj_series.database[:institute], 'NCBI NLM NIH')             
                                                                 
      assert_equal( @obj_series.samples.size, 2)                     
      assert_equal( @obj_series.samples[:GSM77557][:series_id], 'GSE3457')   
      assert_equal( @obj_series.samples['GSM77557'][:series_id], 'GSE3457')  
      assert_equal( @obj_series.samples[:GSM77557][:platform_id], 'GPL2092') 
      assert_equal( @obj_series.samples[:GSM77557][:type], 'RNA')        
      assert_equal( @obj_series.samples[:GSM77557][:title], 'fb6a1')       
      assert_equal( @obj_series.samples[:GSM77557][:table].header, ["ID_REF", "VALUE"])
      assert_equal( @obj_series.samples[:GSM77557][:table].header_description, {"ID_REF"=>"", "VALUE"=>"normalized signal intensities"})
      assert_equal( @obj_series.samples[:GSM77557][:table].rows.size, 217)
      assert_equal( @obj_series.samples[:GSM77557][:table].rows[5], ["A039P68U", "5.36"])  
      assert_equal( @obj_series.samples[:GSM77557][:table].rows[5][0], 'A039P68U')        
      assert_equal( @obj_series.samples[:GSM77557][:table].rows[5][:id_ref], 'A039P68U')  
      assert_equal( @obj_series.samples[:GSM77557][:table].rows[5]['ID_REF'], 'A039P68U')
    end
    
    def test_dataset
      assert_equal( @obj_dataset.database[:name], 'Gene Expression Omnibus (GEO)')

      assert_equal( @obj_dataset.database[:ref], 'Nucleic Acids Res. 2005 Jan 1;33 Database Issue:D562-6')
      assert_equal( @obj_dataset.database[:institute], 'NCBI NLM NIH')

      assert_equal( @obj_dataset.subsets.size, 8)
      assert_equal( @obj_dataset.subsets.keys, ["GDS100_1",
       "GDS100_2",
       "GDS100_3",
       "GDS100_4",
       "GDS100_5",
       "GDS100_6",
       "GDS100_7",
       "GDS100_8"])
      assert_equal( @obj_dataset.subsets[:GDS100_7],  {:sample_id=>"GSM548,GSM543",
       :dataset_id=>"GDS100",
       :description=>"60 minute",
       :type=>"time"})
      assert_equal( @obj_dataset.subsets['GDS100_7'][:sample_id], 'GSM548,GSM543')
      assert_equal( @obj_dataset.subsets[:GDS100_7][:sample_id], 'GSM548,GSM543')
      assert_equal( @obj_dataset.subsets[:GDS100_7][:dataset_id], 'GDS100')
                                                                 
      assert_equal( @obj_dataset.dataset[:order], 'none')
      assert_equal( @obj_dataset.dataset[:sample_organism], 'Escherichia coli')
      assert_equal( @obj_dataset.dataset[:table].header, ["ID_REF",
       "IDENTIFIER",
       "GSM549",
       "GSM542",
       "GSM543",
       "GSM547",
       "GSM544",
       "GSM545",
       "GSM546",
       "GSM548"])
      assert_equal( @obj_dataset.dataset[:table].rows.size, 15)
      assert_equal( @obj_dataset.dataset[:table].rows[5], ["6",
       "EMPTY",
       "0.097",
       "0.217",
       "0.242",
       "0.067",
       "0.104",
       "0.162",
       "0.104",
       "0.154"])
      assert_equal( @obj_dataset.dataset[:table].rows[5][4], '0.242')
      assert_equal( @obj_dataset.dataset[:table].rows[5][:gsm549], '0.097')
      assert_equal( @obj_dataset.dataset[:table].rows[5][:GSM549], '0.097')
      assert_equal( @obj_dataset.dataset[:table].rows[5]['GSM549'], '0.097')
    end
  end

end
