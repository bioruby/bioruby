#
# test/unit/bio/test_location.rb - Unit test for Bio::Location and Bio::Locations
#
# Copyright::  Copyright (C) 2004 Moses Hohman <mmhohman@northwestern.edu>
#                            2008 Naohisa Goto <ng@bioruby.org>
# License::    The Ruby License
#
#  $Id:$
#

# loading helper routine for testing bioruby
require 'pathname'
load Pathname.new(File.join(File.dirname(__FILE__), ['..'] * 2,
                            'bioruby_test_helper.rb')).cleanpath.to_s

# libraries needed for the tests
require 'test/unit'
require 'bio/location'

module Bio
  class TestLocations < Test::Unit::TestCase
    def test_should_not_modify_argument
      assert_nothing_raised {
        Locations.new(' 123..456 '.freeze)
      }
    end

    def test_normal
      loc = Locations.new('123..456')
      assert_equal([123, 456], loc.span)
      assert_equal(123..456, loc.range)
      assert_equal(1, loc[0].strand)
    end

    def test_hat
      loc = Locations.new('754^755')
      assert_equal([754, 755], loc.span, "span wrong")
      assert_equal(754..755, loc.range, "range wrong")
      assert_equal(1, loc[0].strand, "strand wrong")
      assert_equal(true, loc[0].carat, "carat wrong")
    end

    def test_complement
      loc = Locations.new('complement(53^54)')
      assert_equal([53, 54], loc.span, "span wrong")
      assert_equal(53..54, loc.range, "range wrong")
      assert_equal(-1, loc[0].strand, "strand wrong")
      assert_equal(true, loc[0].carat, "carat wrong")
    end

    def test_replace_single_base
      loc = Locations.new('replace(4792^4793,"a")')
      assert_equal("a", loc[0].sequence)
    end
  end

  class TestLocationsRoundTrip < Test::Unit::TestCase

    class TestLoc
      def initialize(*arg)
        @xref_id = nil
        @lt = nil
        @from = nil
        @gt = nil
        @to = nil
        @carat = nil
        @sequence = nil
        @strand = 1
        arg.each do |x|
          case x
          when :complement
            @strand = -1
          when '<'
            @lt = true
          when '>'
            @gt = true
          when '..'
            # do nothing
          when '^'
            @carat = true
          when Integer
            @from ||= x
            @to = x
          when Hash
            @sequence ||= x[:sequence]
          else
            @xref_id ||= x
          end
        end
      end

      def to_location
        loc = Bio::Location.new
        loc.from = @from
        loc.to = @to
        loc.gt = @gt
        loc.lt = @lt
        loc.strand = @strand
        loc.xref_id = @xref_id
        loc.sequence = @sequence
        loc.carat = @carat
        loc
      end
    end #class TestLoc

    TestData =
      [
       # (C) n^m
       # 
       # * [AB015179]	754^755
       [ 'AB015179', '754^755',
         nil,
         TestLoc.new(754, '^', 755)
       ],

       # * [AF179299]	complement(53^54)
       # (see below)
       
       # * [CELXOL1ES]	replace(4480^4481,"")
       # (see below)

       # * [ECOUW87]	replace(4792^4793,"a")
       # (see below)

       # * [APLPCII]	replace(1905^1906,"acaaagacaccgccctacgcc")
       # (see below)

       # (n.m) and one-of() are not supported.
       # (D) (n.m)
       # 
       # * [HACSODA]	157..(800.806)
       # * [HALSODB]	(67.68)..(699.703)
       # * [AP001918]	(45934.45974)..46135
       # * [BACSPOJ]	<180..(731.761)
       # * [BBU17998]	(88.89)..>1122
       # * [ECHTGA]	complement((1700.1708)..(1715.1721))
       # * [ECPAP17]	complement(<22..(255.275))
       # * [LPATOVGNS]	complement((64.74)..1525)
       # * [PIP404CG]	join((8298.8300)..10206,1..855)
       # * [BOVMHDQBY4]	join(M30006.1:(392.467)..575,M30005.1:415..681,M30004.1:129..410,M30004.1:907..1017,521..534)
       # * [HUMMIC2A]	replace((651.655)..(651.655),"")
       # * [HUMSOD102]	order(L44135.1:(454.445)..>538,<1..181)
       # 
       # (n.m) and one-of() are not supported.
       # (E) one-of
       # 
       # * [ECU17136]	one-of(898,900)..983
       # * [CELCYT1A]	one-of(5971..6308,5971..6309)
       # * [DMU17742]	8050..one-of(10731,10758,10905,11242)
       # * [PFU27807]	one-of(623,627,632)..one-of(628,633,637)
       # * [BTBAINH1]	one-of(845,953,963,1078,1104)..1354
       # * [ATU39449]	join(one-of(969..1094,970..1094,995..1094,1018..1094),1518..1587,1726..2119,2220..2833,2945..3215)
       # 

       # (F) join, order, group
       # 
       # * [AB037374S2]	join(AB037374.1:1..177,1..807)
       [ 'AB037374S2',	'join(AB037374.1:1..177,1..807)',
         nil,
         TestLoc.new('AB037374.1', 1, 177),
         TestLoc.new(1, 807)
       ],

       # * [AP000001]	join(complement(1..61),complement(AP000007.1:252907..253505))
       # (see below)

       # * [ASNOS11]	join(AF130124.1:<2563..2964,AF130125.1:21..157,AF130126.1:12..174,AF130127.1:21..112,AF130128.1:21..162,AF130128.1:281..595,AF130128.1:661..842,AF130128.1:916..1030,AF130129.1:21..115,AF130130.1:21..165,AF130131.1:21..125,AF130132.1:21..428,AF130132.1:492..746,AF130133.1:21..168,AF130133.1:232..401,AF130133.1:475..906,AF130133.1:970..1107,AF130133.1:1176..1367,21..>128)
       [ 'ASNOS11', 'join(AF130124.1:<2563..2964,AF130125.1:21..157,AF130126.1:12..174,AF130127.1:21..112,AF130128.1:21..162,AF130128.1:281..595,AF130128.1:661..842,AF130128.1:916..1030,AF130129.1:21..115,AF130130.1:21..165,AF130131.1:21..125,AF130132.1:21..428,AF130132.1:492..746,AF130133.1:21..168,AF130133.1:232..401,AF130133.1:475..906,AF130133.1:970..1107,AF130133.1:1176..1367,21..>128)',
         nil,
         TestLoc.new('AF130124.1', '<', 2563, 2964),
         TestLoc.new('AF130125.1', 21, 157),
         TestLoc.new('AF130126.1', 12, 174),
         TestLoc.new('AF130127.1', 21, 112),
         TestLoc.new('AF130128.1', 21, 162),
         TestLoc.new('AF130128.1', 281, 595),
         TestLoc.new('AF130128.1', 661, 842),
         TestLoc.new('AF130128.1', 916, 1030),
         TestLoc.new('AF130129.1', 21, 115),
         TestLoc.new('AF130130.1', 21, 165),
         TestLoc.new('AF130131.1', 21, 125),
         TestLoc.new('AF130132.1', 21, 428),
         TestLoc.new('AF130132.1', 492, 746),
         TestLoc.new('AF130133.1', 21, 168),
         TestLoc.new('AF130133.1', 232, 401),
         TestLoc.new('AF130133.1', 475, 906),
         TestLoc.new('AF130133.1', 970, 1107),
         TestLoc.new('AF130133.1', 1176, 1367),
         TestLoc.new(21, '>', 128)
       ],

       # * [AARPOB2]	order(AF194507.1:<1..510,1..>871)
       # (see below)

       # * [AF006691]	order(912..1918,20410..21416)
       [ 'AF006691', 'order(912..1918,20410..21416)',
         :order,
         TestLoc.new(912,1918),
         TestLoc.new(20410,21416)
       ],

       # * [AF024666]	complement(order(13965..14892,18919..19224))
       # (Note that in older version of GenBank, the order of
       #  "order" and "complement" was different.)
       # * [AF024666]	order(complement(18919..19224),complement(13965..14892))
       [ 'AF024666', 'complement(order(13965..14892,18919..19224))',
         :complement_order,
         TestLoc.new(13965, 14892),
         TestLoc.new(18919, 19224)
       ],

       # * [AF264948]	order(27066..27076,27089..27099,27283..27314,27330..27352)
       [ 'AF264948',
         'order(27066..27076,27089..27099,27283..27314,27330..27352)',
         :order,
         TestLoc.new(27066, 27076),
         TestLoc.new(27089, 27099),
         TestLoc.new(27283, 27314),
         TestLoc.new(27330, 27352)
       ],

       # * [D63363]	order(3..26,complement(964..987))
       # (see below)

       # * [ECOCURLI2]	order(complement(1009..>1260),complement(AF081827.1:<1..177))
       [ 'ECOCURLI2',
         'order(complement(1009..>1260),complement(AF081827.1:<1..177))',
         :order,
         TestLoc.new(:complement, 1009, '>', 1260),
         TestLoc.new(:complement, 'AF081827.1', '<', 1, 177)
       ],

       # * [S72388S2]	order(join(S72388.1:757..911,S72388.1:609..1542),1..>139)
       # (not supported)

       # * [HEYRRE07]	order(complement(1..38),complement(M82666.1:1..140),complement(M82665.1:1..176),complement(M82664.1:1..215),complement(M82663.1:1..185),complement(M82662.1:1..49),complement(M82661.1:1..133))
       [ 'HEYRRE07',
         'order(complement(1..38),complement(M82666.1:1..140),complement(M82665.1:1..176),complement(M82664.1:1..215),complement(M82663.1:1..185),complement(M82662.1:1..49),complement(M82661.1:1..133))',
         :order,
         TestLoc.new(:complement, 1, 38),
         TestLoc.new(:complement, 'M82666.1', 1, 140),
         TestLoc.new(:complement, 'M82665.1', 1, 176),
         TestLoc.new(:complement, 'M82664.1', 1, 215),
         TestLoc.new(:complement, 'M82663.1', 1, 185),
         TestLoc.new(:complement, 'M82662.1', 1, 49),
         TestLoc.new(:complement, 'M82661.1', 1, 133)
       ],

       # * [COL11A1G34]	order(AF101079.1:558..1307,AF101080.1:1..749,AF101081.1:1..898,AF101082.1:1..486,AF101083.1:1..942,AF101084.1:1..1734,AF101085.1:1..2385,AF101086.1:1..1813,AF101087.1:1..2287,AF101088.1:1..1073,AF101089.1:1..989,AF101090.1:1..5017,AF101091.1:1..3401,AF101092.1:1..1225,AF101093.1:1..1072,AF101094.1:1..989,AF101095.1:1..1669,AF101096.1:1..918,AF101097.1:1..1114,AF101098.1:1..1074,AF101099.1:1..1709,AF101100.1:1..986,AF101101.1:1..1934,AF101102.1:1..1699,AF101103.1:1..940,AF101104.1:1..2330,AF101105.1:1..4467,AF101106.1:1..1876,AF101107.1:1..2465,AF101108.1:1..1150,AF101109.1:1..1170,AF101110.1:1..1158,AF101111.1:1..1193,1..611)
       [ 'COL11A1G34',
         'order(AF101079.1:558..1307,AF101080.1:1..749,AF101081.1:1..898,AF101082.1:1..486,AF101083.1:1..942,AF101084.1:1..1734,AF101085.1:1..2385,AF101086.1:1..1813,AF101087.1:1..2287,AF101088.1:1..1073,AF101089.1:1..989,AF101090.1:1..5017,AF101091.1:1..3401,AF101092.1:1..1225,AF101093.1:1..1072,AF101094.1:1..989,AF101095.1:1..1669,AF101096.1:1..918,AF101097.1:1..1114,AF101098.1:1..1074,AF101099.1:1..1709,AF101100.1:1..986,AF101101.1:1..1934,AF101102.1:1..1699,AF101103.1:1..940,AF101104.1:1..2330,AF101105.1:1..4467,AF101106.1:1..1876,AF101107.1:1..2465,AF101108.1:1..1150,AF101109.1:1..1170,AF101110.1:1..1158,AF101111.1:1..1193,1..611)',
         :order,
         TestLoc.new('AF101079.1', 558, 1307),
         TestLoc.new('AF101080.1', 1, 749),
         TestLoc.new('AF101081.1', 1, 898),
         TestLoc.new('AF101082.1', 1, 486),
         TestLoc.new('AF101083.1', 1, 942),
         TestLoc.new('AF101084.1', 1, 1734),
         TestLoc.new('AF101085.1', 1, 2385),
         TestLoc.new('AF101086.1', 1, 1813),
         TestLoc.new('AF101087.1', 1, 2287),
         TestLoc.new('AF101088.1', 1, 1073),
         TestLoc.new('AF101089.1', 1, 989),
         TestLoc.new('AF101090.1', 1, 5017),
         TestLoc.new('AF101091.1', 1, 3401),
         TestLoc.new('AF101092.1', 1, 1225),
         TestLoc.new('AF101093.1', 1, 1072),
         TestLoc.new('AF101094.1', 1, 989),
         TestLoc.new('AF101095.1', 1, 1669),
         TestLoc.new('AF101096.1', 1, 918),
         TestLoc.new('AF101097.1', 1, 1114),
         TestLoc.new('AF101098.1', 1, 1074),
         TestLoc.new('AF101099.1', 1, 1709),
         TestLoc.new('AF101100.1', 1, 986),
         TestLoc.new('AF101101.1', 1, 1934),
         TestLoc.new('AF101102.1', 1, 1699),
         TestLoc.new('AF101103.1', 1, 940),
         TestLoc.new('AF101104.1', 1, 2330),
         TestLoc.new('AF101105.1', 1, 4467),
         TestLoc.new('AF101106.1', 1, 1876),
         TestLoc.new('AF101107.1', 1, 2465),
         TestLoc.new('AF101108.1', 1, 1150),
         TestLoc.new('AF101109.1', 1, 1170),
         TestLoc.new('AF101110.1', 1, 1158),
         TestLoc.new('AF101111.1', 1, 1193),
         TestLoc.new(1, 611)
       ],

       # group() are found in the COMMENT field only (in GenBank 122.0)
       # 
       #   gbpat2.seq:            FT   repeat_region   group(598..606,611..619)
       #   gbpat2.seq:            FT   repeat_region   group(8..16,1457..1464).
       #   gbpat2.seq:            FT   variation       group(t1,t2)
       #   gbpat2.seq:            FT   variation       group(t1,t3)
       #   gbpat2.seq:            FT   variation       group(t1,t2,t3)
       #   gbpat2.seq:            FT   repeat_region   group(11..202,203..394)
       #   gbpri9.seq:COMMENT     Residues reported = 'group(1..2145);'.
       # 

       # (G) ID:location
       # * [AARPOB2]	order(AF194507.1:<1..510,1..>871)
       [ 'AARPOB2', 'order(AF194507.1:<1..510,1..>871)',
         :order,
         TestLoc.new('AF194507.1', '<', 1, 510),
         TestLoc.new(1, '>', 871)
       ],
       # * [AF178221S4]	join(AF178221.1:<1..60,AF178222.1:1..63,AF178223.1:1..42,1..>90)
       [ 'AF178221S4',
         'join(AF178221.1:<1..60,AF178222.1:1..63,AF178223.1:1..42,1..>90)',
         nil,
         TestLoc.new('AF178221.1', '<', 1,      60),
         TestLoc.new('AF178222.1',      1,      63),
         TestLoc.new('AF178223.1',      1,      42),
         TestLoc.new(                   1, '>', 90)
       ],
       # * [BOVMHDQBY4]	join(M30006.1:(392.467)..575,M30005.1:415..681,M30004.1:129..410,M30004.1:907..1017,521..534)
       # not supported

       # * [HUMSOD102]	order(L44135.1:(454.445)..>538,<1..181)
       # not supported

       # * [SL16SRRN1]	order(<1..>267,X67092.1:<1..>249,X67093.1:<1..>233)
       [ 'SL16SRRN1',
         'order(<1..>267,X67092.1:<1..>249,X67093.1:<1..>233)',
         :order,
         TestLoc.new(            '<', 1, '>', 267),
         TestLoc.new('X67092.1', '<', 1, '>', 249),
         TestLoc.new('X67093.1', '<', 1, '>', 233)
       ],

       # (I) <, >
       # * [A5U48871]	<1..>318
       [ 'A5U48871', '<1..>318',
         nil,
         TestLoc.new('<', 1, '>', 318)
       ],

       # * [AA23SRRNP]	<1..388
       [ 'AA23SRRNP', '<1..388',
         nil,
         TestLoc.new('<', 1, 388)
       ],

       # * [AA23SRRNP]	503..>1010
       [ 'AA23SRRNP', '503..>1010',
         nil,
         TestLoc.new(503, '>', 1010)
       ],

       # * [AAM5961]	complement(<1..229)
       [ 'AAM5961', 'complement(<1..229)',
         nil,
         TestLoc.new(:complement, '<', 1, 229)
       ],

       # * [AAM5961]	complement(5231..>5598)
       [ 'AAM5961', 'complement(5231..>5598)',
         nil,
         TestLoc.new(:complement, 5231, '>', 5598)
       ],

       # * [AF043934]	join(<1,60..99,161..241,302..370,436..594,676..887,993..1141,1209..1329,1387..1559,1626..1646,1708..>1843)
       [ 'AF043934', 'join(<1,60..99,161..241,302..370,436..594,676..887,993..1141,1209..1329,1387..1559,1626..1646,1708..>1843)',
         nil,
         TestLoc.new('<', 1),
         TestLoc.new(60, 99),
         TestLoc.new(161,241),
         TestLoc.new(302,370),
         TestLoc.new(436,594),
         TestLoc.new(676,887),
         TestLoc.new(993,1141),
         TestLoc.new(1209,1329),
         TestLoc.new(1387,1559),
         TestLoc.new(1626,1646),
         TestLoc.new(1708, '>', 1843)
       ],

       # * [BACSPOJ]	<180..(731.761)
       # not supported

       # * [BBU17998]	(88.89)..>1122
       # not supported

       # * [AARPOB2]	order(AF194507.1:<1..510,1..>871)
       # (see above)

       # * [SL16SRRN1]	order(<1..>267,X67092.1:<1..>249,X67093.1:<1..>233)
       # (see above)
 
       # (J) complement
       # * [AF179299]	complement(53^54)
       [ 'AF179299', 'complement(53^54)',
         nil,
         TestLoc.new(:complement, 53, '^', 54)
       ],

       # * [AP000001]	join(complement(1..61),complement(AP000007.1:252907..253505))
       [ 'AP000001',
         'join(complement(1..61),complement(AP000007.1:252907..253505))',
         nil,
         TestLoc.new(:complement, 1, 61),
         TestLoc.new(:complement, 'AP000007.1', 252907, 253505)
       ],

       # * [AF209868S2]	order(complement(1..>308),complement(AF209868.1:75..336))
       [ 'AF209868S2',
         'order(complement(1..>308),complement(AF209868.1:75..336))',
         :order,
         TestLoc.new(:complement, 1, '>', 308),
         TestLoc.new(:complement, 'AF209868.1', 75, 336)
       ],

       # * [CPPLCG]	complement(<1..(1093.1098))
       # not supported

       # * [D63363]	order(3..26,complement(964..987))
       [ 'D63363]',  'order(3..26,complement(964..987))',
         :order,
         TestLoc.new(3,26),
         TestLoc.new(:complement, 964, 987)
       ],

       # * [ECHTGA]	complement((1700.1708)..(1715.1721))
       # not supported

       # * [ECOUXW]	complement(order(1636..1641,1658..1663))
       # (Note that in older version of GenBank, the order of
       #  "order" and "complement" was different.)
       # * [ECOUXW]	order(complement(1658..1663),complement(1636..1641))
       #
       [ 'ECOUXW', 'complement(order(1636..1641,1658..1663))',
         :complement_order,
         TestLoc.new(:complement, 1636, 1641),
         TestLoc.new(:complement, 1658, 1663)
       ],

       # * [LPATOVGNS]	complement((64.74)..1525)
       # not supported

       # * [AF129075]	complement(join(71606..71829,75327..75446,76039..76203,76282..76353,76914..77029,77114..77201,77276..77342,78138..78316,79755..79892,81501..81562,81676..81856,82341..82490,84208..84287,85032..85122,88316..88403))
       [ 'AF129075',
         'complement(join(71606..71829,75327..75446,76039..76203,76282..76353,76914..77029,77114..77201,77276..77342,78138..78316,79755..79892,81501..81562,81676..81856,82341..82490,84208..84287,85032..85122,88316..88403))',
         :complement_join,
         TestLoc.new(71606,71829),
         TestLoc.new(75327,75446),
         TestLoc.new(76039,76203),
         TestLoc.new(76282,76353),
         TestLoc.new(76914,77029),
         TestLoc.new(77114,77201),
         TestLoc.new(77276,77342),
         TestLoc.new(78138,78316),
         TestLoc.new(79755,79892),
         TestLoc.new(81501,81562),
         TestLoc.new(81676,81856),
         TestLoc.new(82341,82490),
         TestLoc.new(84208,84287),
         TestLoc.new(85032,85122),
         TestLoc.new(88316,88403)
       ],

       # * [ZFDYST2]	join(AF137145.1:<1..18,complement(<1..99))
       [ 'ZFDYST2', 'join(AF137145.1:<1..18,complement(<1..99))',
         nil,
         TestLoc.new('AF137145.1', '<', 1, 18),
         TestLoc.new(:complement, '<', 1, 99)
       ],

       # (K) replace
       # * [CSU27710]	replace(64,"A")
       [ 'CSU27710', 'replace(64,"a")',
         nil,
         TestLoc.new(64, :sequence => "a")
       ],

       # * [CELXOL1ES]	replace(5256,"t")
       [ 'CELXOL1ES', 'replace(5256,"t")',
         nil,
         TestLoc.new(5256,:sequence => "t")
       ],

       # * [ANICPC]	replace(1..468,"")
       [ 'ANICPC', 'replace(1..468,"")',
         nil,
         TestLoc.new(1, 468, :sequence => "")
       ],

       # * [CSU27710]	replace(67..68,"GC")
       [ 'CSU27710', 'replace(67..68,"gc")',
         nil,
         TestLoc.new(67, 68, :sequence => "gc")
       ],

       # * [CELXOL1ES]	replace(4480^4481,"")	<= ? only one case in GenBank 122.0
       [ 'CELXOL1ES', 'replace(4480^4481,"")',
         nil,
         TestLoc.new(4480, '^', 4481, :sequence => "")
       ],

       # * [ECOUW87]	replace(4792^4793,"a")
       [ 'ECOUW87', 'replace(4792^4793,"a")',
         nil,
         TestLoc.new(4792, '^', 4793, :sequence => "a")
       ],

       # * [CEU34893]	replace(1..22,"ggttttaacccagttactcaag")
       [ 'CEU34893', 'replace(1..22,"ggttttaacccagttactcaag")',
         nil,
         TestLoc.new(1, 22, :sequence => "ggttttaacccagttactcaag")
       ],

       # * [APLPCII]	replace(1905^1906,"acaaagacaccgccctacgcc")
       [ 'APLPCII', 'replace(1905^1906,"acaaagacaccgccctacgcc")',
         nil,
         TestLoc.new(1905, '^', 1906, :sequence => "acaaagacaccgccctacgcc")
       ],

       # * [MBDR3S1]	replace(1400..>9281,"")
       [ 'MBDR3S1', 'replace(1400..>9281,"")',
         nil,
         TestLoc.new(1400, '>', 9281, :sequence => "")
       ],

       # * [HUMMHDPB1F]	replace(complement(36..37),"ttc")
       [ 'HUMMHDPB1F', 'replace(complement(36..37),"ttc")',
         nil,
         TestLoc.new(:complement, 36, 37, :sequence => "ttc")
       ],

       # * [HUMMIC2A]	replace((651.655)..(651.655),"")
       # not supported

       # * [LEIMDRPGP]	replace(1..1554,"L01572")
       # not supported

       # * [TRBND3]	replace(376..395,"atttgtgtgtggtaatta")
       [ 'TRBND3', 'replace(376..395,"atttgtgtgtggtaatta")',
         nil,
         TestLoc.new(376, 395, :sequence => "atttgtgtgtggtaatta")
       ],

       # * [TRBND3]	replace(376..395,"atttgtgtgggtaatttta")
       # * [TRBND3]	replace(376..395,"attttgttgttgttttgttttgaatta")
       # * [TRBND3]	replace(376..395,"atgtgtggtgaatta")
       # * [TRBND3]	replace(376..395,"atgtgtgtggtaatta")
       # * [TRBND3]	replace(376..395,"gatttgttgtggtaatttta")
       # (see above)

       # * [MSU09460]	replace(193,"t")
       [ 'MSU09460', 'replace(193,"t")',
         nil,
         TestLoc.new(193, :sequence => "t")
       ],

       # * [HUMMAGE12X]	replace(3002..3003, "GC")
       [ 'HUMMAGE12X', 'replace(3002..3003,"gc")',
         nil,
         TestLoc.new(3002, 3003, :sequence => "gc")
       ],

       # * [ADR40FIB]	replace(510..520, "taatcctaccg")
       [ 'ADR40FIB', 'replace(510..520,"taatcctaccg")',
         nil,
         TestLoc.new(510, 520, :sequence => "taatcctaccg")
       ],

       # * [RATDYIIAAB]	replace(1306..1443,"aagaacatccacggagtcagaactgggctcttcacgccggatttggcgttcgaggccattgtgaaaaagcaggcaatgcaccagcaagctcagttcctacccctgcgtggacctggttatccaggagctaatcagtacagttaggtggtcaagctgaaagagccctgtctgaaa")
       [ 'RATDYIIAAB',  'replace(1306..1443,"aagaacatccacggagtcagaactgggctcttcacgccggatttggcgttcgaggccattgtgaaaaagcaggcaatgcaccagcaagctcagttcctacccctgcgtggacctggttatccaggagctaatcagtacagttaggtggtcaagctgaaagagccctgtctgaaa")',
         nil,
         TestLoc.new(1306, 1443, :sequence => "aagaacatccacggagtcagaactgggctcttcacgccggatttggcgttcgaggccattgtgaaaaagcaggcaatgcaccagcaagctcagttcctacccctgcgtggacctggttatccaggagctaatcagtacagttaggtggtcaagctgaaagagccctgtctgaaa")
       ]
      ] #TestData=

    def test_locations_to_s
      TestData.each do |a|
        label = a[0]
        str = a[1]
        op = a[2]
        locs = a[3..-1]
        locs.collect! { |x| x.to_location }
        case op
        when :complement_join, :complement_order
          locs.reverse!
          locs.each { |loc| loc.strand = -1 }
          op = op.to_s.sub(/complement_/, '').intern
        end
        locations = Bio::Locations.new(locs)
        locations.operator = op if op
        assert_equal(str, locations.to_s, "to_s: wrong for #{label}")
      end
    end

    def test_locations_roundtrip
      TestData.each do |a|
        label = a[0]
        str = a[1]
        locations = Bio::Locations.new(str)
        assert_equal(str, locations.to_s, "round trip: wrong for #{label}")
      end
    end

  end
end
