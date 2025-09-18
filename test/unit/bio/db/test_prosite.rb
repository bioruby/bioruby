#
# test/unit/bio/db/test_prosite.rb - Unit test for Bio::PROSITE
#
# Copyright::  Copyright (C) 2005 Mitsuteru Nakao <n@bioruby.org>
# License::    The Ruby License
#
#  $Id:$
#

# loading helper routine for testing bioruby
require 'pathname'
load Pathname.new(File.join(File.dirname(__FILE__), ['..'] * 3,
                            'bioruby_test_helper.rb')).cleanpath.to_s

# libraries needed for the tests
require 'test/unit'
require 'bio/db/prosite'

module Bio
  class TestPROSITEConst < Test::Unit::TestCase
    def test_delimiter
      assert_equal("\n//\n", Bio::PROSITE::DELIMITER)
      assert_equal("\n//\n", Bio::PROSITE::RS)
    end

    def test_tagsize
      assert_equal(5, Bio::PROSITE::TAGSIZE)
    end
  end # class TestPROSITEConst

  class TestPROSITE < Test::Unit::TestCase
    def setup
      data = File.read(File.join(BioRubyTestDataPath, 'prosite', 'prosite.dat'))
      data = data.split(Bio::PROSITE::RS)[0]
      @obj = Bio::PROSITE.new(data)
    end

    def test_name
      assert_equal('G_PROTEIN_RECEP_F1_1', @obj.name)
    end

    def test_division
      data = 'PATTERN'
      assert_equal(data, @obj.division)
    end

    def test_ac
      data = 'PS00237'
      assert_equal(data, @obj.ac)
    end

    def test_dt
      assert_equal('APR-1990 (CREATED); NOV-1997 (DATA UPDATE); JUL-1998 (INFO UPDATE).', @obj.dt)
    end

    def test_de
      data = 'G-protein coupled receptors family 1 signature.'
      assert_equal(data, @obj.de)
    end

    def test_pa
      pattern = '[GSTALIVMFYWC]-[GSTANCPDE]-{EDPKRH}-x(2)-[LIVMNQGA]-x(2)-[LIVMFT]-[GSTANC]-[LIVMFYWSTAC]-[DENH]-R-[FYWCSH]-x(2)-[LIVM].'
      assert_equal(pattern, @obj.pa)
    end

    def test_ma
      assert_equal('', @obj.ma)
    end

    def test_ru
      assert_equal('', @obj.ru)
    end

    def test_nr
      data = { 'FALSE_NEG' => 112, 'POSITIVE' => [1057, 1057], 'PARTIAL' => 48, 'FALSE_POS' => [64, 64],
               'RELEASE' => ['40.7', 103_373], 'TOTAL' => [1121, 1121], 'UNKNOWN' => [0, 0] }

      assert_equal(data, @obj.nr)
    end

    def test_release
      assert_equal(['40.7', 103_373], @obj.release)
    end

    def test_swissprot_release_number
      assert_equal('40.7', @obj.swissprot_release_number)
    end

    def test_swissprot_release_sequences
      assert_equal(103_373, @obj.swissprot_release_sequences)
    end

    def test_total
      assert_equal([1121, 1121], @obj.total)
    end

    def test_total_hits
      assert_equal(1121, @obj.total_hits)
    end

    def test_total_sequences
      assert_equal(1121, @obj.total_sequences)
    end

    def test_positive
      assert_equal([1057, 1057], @obj.positive)
    end

    def test_positive_hits
      assert_equal(1057, @obj.positive_hits)
    end

    def test_positive_sequences
      assert_equal(1057, @obj.positive_sequences)
    end

    def test_unknown
      assert_equal([0, 0], @obj.unknown)
    end

    def test_unknown_hits
      assert_equal(0, @obj.unknown_hits)
    end

    def test_unknown_sequences
      assert_equal(0, @obj.unknown_sequences)
    end

    def test_false_pos
      assert_equal([64, 64], @obj.false_pos)
    end

    def test_false_positive_sequences
      assert_equal(64, @obj.false_positive_sequences)
    end

    def test_false_neg
      assert_equal(112, @obj.false_neg)
    end

    def test_partial
      assert_equal(48, @obj.partial)
    end

    def test_cc
      assert_equal({ 'TAXO-RANGE' => '??E?V', 'MAX-REPEAT' => '1' }, @obj.cc)
    end

    def test_taxon_range
      assert_equal('??E?V', @obj.taxon_range)
    end

    def test_max_repeat
      assert_equal(1, @obj.max_repeat)
    end

    def test_site
      assert_equal([0, nil], @obj.site)
    end

    def test_skip_flag
      assert_equal(nil, @obj.skip_flag)
    end

    def test_dr
      assert_equal(Hash, @obj.dr.class)
      data = %w[OPSD_LIMBE T]
      assert_equal(data, @obj.dr['O42427'])
    end

    def test_list_xref
      flag = ''
      assert_equal([], @obj.list_xref(flag))
    end

    def test_list_truepositive
      data = %w[O42427
                P11617
                P46090
                P30939
                P28336
                Q9Z2J6
                Q64326
                P46092
                P07550
                Q9UKL2
                P30940
                P46093
                Q61224
                Q63384
                P46094
                Q28309
                P22328
                P46095
                O77590
                O02813
                Q9R1C8
                P22329
                O93441
                O42300
                Q10904
                O43613
                Q9Z0D9
                P18130
                O42301
                O43614
                P22330
                P22331
                Q9GLJ8
                O15552
                O43193
                P22332
                O43194
                Q9WV26
                Q9TST4
                Q62053
                P58307
                O42307
                Q9TST5
                P58308
                Q9TST6
                P41983
                P30951
                P41984
                O02824
                O88626
                P91657
                P30953
                P18825
                O62709
                O42574
                P30954
                Q28585
                O88628
                P30955
                P28221
                Q9WU02
                P28222
                P32299
                P70310
                P28223
                O76099
                P04201
                P35894
                Q15722
                P35895
                O93459
                P14416
                P35897
                P35898
                P35899
                P49578
                O42451
                P47745
                Q9Y5N1
                O42452
                P50052
                P47746
                O97878
                O02835
                Q09502
                Q28596
                O00254
                P31355
                P47747
                O97879
                O02836
                P31356
                P30966
                P79436
                P47748
                P87365
                P08099
                Q9JL21
                P47749
                P87366
                O18481
                P16582
                P87367
                P30968
                O97880
                P47750
                P87368
                Q62758
                P30969
                Q28468
                O97881
                Q09638
                P09703
                P87369
                O95918
                Q9TUE1
                O97882
                P22909
                P09704
                O18485
                O42327
                P47751
                P47883
                P18841
                O55193
                O97883
                O18486
                O42328
                P47884
                Q9EP86
                O42329
                O14626
                P48145
                P47887
                O08725
                P48146
                P30974
                O08858
                O18910
                O42330
                O55197
                O08726
                O70526
                P30975
                O18911
                Q28474
                O18912
                O70528
                O18913
                P34311
                O18914
                O42466
                O95371
                Q9WU25
                P47892
                P70596
                P33396
                P70597
                Q61130
                Q15743
                Q15612
                P51144
                P32745
                O00270
                Q00991
                Q9YGY9
                P29754
                Q9GZK3
                O02721
                Q9GZK4
                Q15615
                Q9Y5P1
                Q60613
                Q15062
                P29755
                Q9UKP6
                Q28905
                Q9YGZ0
                P47898
                Q60614
                P47899
                Q9GZK7
                Q9YGZ1
                Q9YGZ2
                O97504
                Q15619
                P30987
                Q9YGZ3
                Q9YGZ4
                Q93126
                Q15620
                Q9YGZ5
                P30989
                Q13725
                Q93127
                P16473
                P23749
                Q9YGZ6
                O54814
                O62743
                Q9YGZ7
                P52202
                Q15622
                Q9YGZ8
                P56514
                P30728
                O97772
                Q9YGZ9
                P30991
                P56515
                P30729
                Q9J529
                P56516
                P47774
                O62747
                P30992
                P35403
                P15823
                P47775
                Q9WUK7
                P30993
                O97512
                P35404
                P06002
                O08878
                P30730
                P30994
                O46635
                P35405
                P30731
                P21728
                P35406
                P42288
                P21729
                P35407
                P49217
                P31387
                P35408
                P42289
                O00155
                P31388
                O46639
                P48039
                Q64121
                P35409
                P49219
                P31389
                O18935
                Q9TU05
                P42290
                P21730
                P21731
                P18871
                P31390
                P42291
                P48040
                P31391
                P35410
                P20789
                Q13606
                P48042
                O42490
                P35411
                O88410
                P31392
                P29089
                Q13607
                P48043
                P35412
                P48044
                O89039
                P35413
                P30872
                O01668
                P35414
                P30873
                Q9YH00
                P79211
                P30874
                Q9YH01
                Q28927
                P30875
                Q9YH02
                P49912
                O08890
                P25100
                Q28928
                O95006
                Q9YH03
                P25101
                Q28929
                O95007
                O15218
                O88680
                Q9YH04
                O08892
                Q05394
                P79901
                Q9YH05
                P25102
                P33032
                Q64264
                Q9ERZ3
                P79902
                P25103
                P79217
                Q9UGF5
                Q9ERZ4
                Q9N2A2
                P79903
                P13945
                P25104
                P79218
                P33033
                Q9UGF6
                Q9N2A3
                P25105
                O97661
                O70431
                P79350
                Q9UGF7
                Q9N2A4
                P48974
                P25106
                O97663
                P03999
                P16235
                O95013
                P22269
                O97665
                P26684
                P97468
                P47798
                O97666
                P22270
                O18821
                P47799
                P49922
                Q61038
                P51050
                P25929
                P49238
                Q28807
                P28285
                P79911
                P28286
                P13953
                Q19084
                O61303
                P04000
                P25930
                P04001
                Q9NPB9
                P25931
                Q9R1K6
                P42866
                P56412
                P79914
                Q61041
                Q9GK74
                P25115
                P04950
                P25116
                P19020
                P18762
                O12948
                Q26495
                Q09561
                Q25157
                P70115
                O77830
                Q83207
                P02699
                O12000
                Q01717
                Q25158
                P29403
                P50406
                Q01718
                P29404
                O42384
                P50407
                P79234
                O42385
                O02769
                Q17232
                P79236
                P21761
                P79237
                P04274
                Q28003
                O75388
                P24603
                Q9TUK4
                P53452
                P08588
                Q28005
                P43240
                Q61184
                O08786
                P79240
                P53453
                Q13639
                Q9Y3N9
                Q9UP62
                P18089
                P53454
                P79928
                P79242
                Q01726
                P24053
                P79243
                Q17239
                Q01727
                Q14330
                P18090
                Q9R024
                O62791
                O02777
                P43114
                O62792
                P79113
                O77713
                O08790
                O62793
                P54833
                P43116
                O62794
                Q61614
                O77715
                Q00788
                P43117
                O42266
                O62795
                O88319
                Q03566
                P43118
                O62796
                O02781
                O08530
                P43119
                O42268
                P16395
                O62798
                Q9DDN6
                P05363
                P30518
                O13227
                Q9GZQ6
                P43252
                O18982
                P43253
                P79807
                O18983
                P79808
                O77721
                O35786
                P30098
                P56439
                P79809
                P20309
                O77723
                P56440
                Q28838
                P55919
                Q9UHM6
                Q9TT23
                P56441
                P97926
                Q63652
                P55920
                P56442
                P79812
                P25962
                P56443
                P35462
                P56444
                P35463
                P56445
                O97571
                P79393
                P56446
                O02662
                P49144
                P56447
                P79394
                Q25188
                P49145
                P28190
                P56448
                P24628
                P56449
                O02664
                P49146
                P33765
                Q9EQD2
                Q24563
                P33766
                Q90674
                O02666
                P56450
                P06199
                Q25190
                O02667
                Q99500
                P25021
                P56451
                P08482
                P30796
                Q9H1Y3
                Q28031
                P79266
                O14581
                P08483
                P25023
                P49019
                P25024
                P08485
                P12657
                P12526
                Q9QXZ9
                P08908
                P07700
                P25025
                P32300
                Q9Z1S9
                P35342
                P17200
                O09047
                P08909
                O76100
                Q91175
                P43140
                P49285
                P32302
                P35343
                P43141
                P49286
                P32303
                P35344
                Q91178
                P32304
                Q9Y5X5
                P35345
                P08911
                P43142
                O08556
                P49288
                P35346
                P52702
                P32305
                P08912
                P11483
                P32306
                P52703
                Q9R0M1
                P08913
                P32307
                Q62463
                P35348
                O42294
                P30542
                P32308
                P30411
                P30543
                P32309
                Q9TU77
                Q02152
                Q02284
                Q18904
                P35350
                P30545
                Q28044
                P08100
                O77616
                P35351
                P70031
                P30546
                P79148
                P30547
                P32310
                P16849
                P32311
                Q9JI35
                P30548
                P32312
                P30549
                Q9Y5Y4
                P30680
                P32313
                O08565
                Q28997
                P97266
                P11229
                Q28998
                Q9NYM4
                O93603
                P35356
                P30550
                O15973
                P35357
                P30551
                O77621
                P35358
                P58173
                P34968
                P30552
                P35359
                P34969
                P22888
                P30553
                O19012
                P30554
                P30555
                O19014
                P35360
                Q9MZV8
                P30556
                Q99788
                P35361
                Q04683
                P34970
                P35362
                P70174
                P34971
                Q9WUT7
                P30558
                Q9TUP7
                P79291
                P28088
                P35363
                P34972
                O42179
                P30559
                P79292
                Q99527
                Q01776
                P35364
                P34973
                Q64077
                P41591
                P21554
                P34974
                Q9XT45
                O88495
                P46002
                Q90309
                P41592
                P79848
                P56479
                P21555
                Q9GLX8
                P35365
                P34975
                Q29003
                P30560
                P35366
                P21556
                P47211
                P16177
                P34976
                P10980
                O42604
                P35367
                Q95247
                P34977
                Q29005
                P33533
                P34978
                P28646
                Q17292
                P41595
                P35368
                P33534
                P56481
                P79166
                P41596
                P20905
                P35369
                P28647
                P33535
                P56482
                P41597
                P24530
                P56483
                P47900
                O19024
                P35370
                P56484
                P47901
                O18766
                Q17296
                O19025
                P35371
                P51651
                P34981
                P56485
                Q9H207
                P35372
                P56486
                Q13304
                P35373
                P34982
                Q29010
                Q9H209
                P35374
                P34983
                O76000
                P08255
                P04761
                P22086
                P56488
                P35375
                Q98980
                Q28886
                Q95254
                P14842
                P34984
                O76001
                O76002
                P56489
                P35376
                P34986
                Q9XT57
                Q98982
                Q95125
                Q28756
                Q9H343
                O13018
                P35377
                P34987
                Q9XT58
                P97288
                P56490
                Q9H344
                P35378
                P70612
                P56491
                P79175
                P34989
                P35379
                P16610
                P56492
                O19032
                P79176
                Q9H346
                P49059
                P56493
                P79177
                P56494
                Q9NQN1
                P56495
                P79863
                P97292
                Q91081
                P79178
                P97714
                Q99677
                P35382
                P35383
                O54798
                P56496
                Q99678
                O19037
                Q04573
                P34992
                P34993
                P15409
                O54799
                P56497
                Q99679
                Q94741
                P97717
                P34994
                Q29154
                P97295
                Q90328
                P56498
                P32211
                Q92847
                P34995
                P32212
                P34996
                Q60474
                P34997
                Q63447
                Q60475
                P10608
                Q60476
                Q62928
                Q13585
                O95665
                P79188
                P37288
                Q9DGG4
                Q90334
                P51436
                P26255
                P37289
                Q17053
                O16005
                Q28509
                P21450
                P55167
                Q9Z2D5
                P79190
                P21451
                Q9QZN9
                P79191
                P21452
                P51675
                Q28642
                P21453
                P51676
                Q60483
                P49892
                P14600
                P51677
                Q60484
                Q9ES90
                Q9HC97
                P51678
                P17124
                P79748
                P51679
                O18793
                Q62805
                P41231
                P28678
                P41232
                Q9Y2T5
                P51680
                P18599
                Q9TT96
                Q9WVD0
                P28679
                O19054
                Q18007
                P32229
                Q9XT82
                O35599
                P51681
                P51682
                P47800
                P28680
                Q25414
                P28681
                P51683
                Q90214
                Q28519
                Q90215
                P51684
                P28682
                O60755
                P28683
                P29371
                P51685
                Q9H3N8
                O16017
                P21462
                P25089
                O00574
                P21463
                P28684
                P79756
                O54689
                P51686
                P47936
                O16018
                P51582
                O16019
                P22671
                Q9UM60
                P47937
                O77408
                Q9TTQ9
                Q95154
                P26824
                P25090
                Q95155
                O16020
                P52500
                Q95156
                Q28524
                O35210
                P32236
                Q95157
                P48302
                Q90352
                P32237
                O35476
                P02700
                P48303
                P32238
                O02213
                P25095
                P32239
                O35214
                O35478
                P32240
                P20395
                P79763
                P18901
                Q16581
                P25099
                P79898
                O77680
                P32244
                Q9PUI7
                P28564
                P49650
                P32245
                P28565
                P49651
                P32246
                P28566
                P49652
                Q98894
                P32247
                Q9H255
                Q98895
                P32248
                P32249
                P20272
                P43088
                Q95170
                P50128
                P32250
                P50391
                P70658
                P08172
                P50129
                P08173
                P32251
                P46616
                Q9QYN8
                P50130
                P51470
                P14763
                P51471
                P50132
                Q27987
                P49660
                P51472
                P51473
                O60412
                P51474
                P51475
                Q90373
                Q95179
                P51476
                P58406
                O88853
                P70536
                Q17094
                O88854
                Q11082
                P37067
                Q90245
                P79785
                P37068
                O13076
                Q92633
                P46626
                Q91559
                P37069
                P46627
                P21917
                P23944
                O97967
                P46628
                P56971
                P43657
                O62809
                Q28553
                P21918
                P23945
                P20288
                O19091
                O15529
                P37070
                Q28422
                P29274
                P37071
                P29275
                Q9Z0Z6
                P29276
                Q25321
                Q18179
                P30372
                Q90252
                O14843
                Q9Z2I3
                Q25322
                Q08520
                Q28558
                P51488
                P41143
                P23265
                Q28691
                P51489
                P09241
                O18312
                P41144
                Q61212
                P23266
                Q9WV08
                P41145
                P46636
                P23267
                P56718
                P41146
                P21109
                P51490
                P79400
                Q9UPC5
                Q62035
                P56719
                P23269
                O14718
                P79798
                P51491
                O18315
                P41149
                P23270
                O60431
                P49681
                P23271
                P19327
                P30935
                P11613
                P49682
                P23272
                P41968
                O43603
                P19328
                Q63931
                P30936
                P49683
                P11614
                P23273
                P46089
                P28334
                P49684
                P30937
                P11615
                P23274
                P28335
                O13092
                O43869
                P97520
                Q01337
                P30938
                P49685
                P11616
                P23275
                Q01338]
      assert_equal(data.sort, @obj.list_truepositive.sort)
    end

    def test_list_falsenegative
      data = %w[P18259
                Q13813
                Q55593
                Q00274
                P54466
                Q9HJA4
                P55687
                Q9W0K0
                Q42608
                P45873
                P45198
                P15828
                P18609
                Q51758
                P24151
                P23892
                P41510
                P22817
                P46457
                O15910
                P23515
                O59098
                P26560
                P26561
                P47551
                P22023
                P21503
                Q9VNB3
                P25147
                Q42675
                P21524
                P06882
                Q61647
                P42790
                Q10775
                O84877
                P51656
                P75548
                Q92839
                P51657
                P37274
                P34724
                P07751
                P00498
                P07886
                P26258
                O67284
                Q25410
                P46724
                P76097
                P16086
                P08032
                P14198
                P77916
                O60779
                P13688
                Q03834
                Q63912
                O68824
                P77932
                Q53547
                P77933
                P34529
                Q00126]
      assert_equal(data.sort, @obj.list_falsenegative.sort)
    end

    def test_list_falsepositive
      data = %w[P41985
                P41986
                P17645
                Q60612
                Q60879
                P52592
                Q60882
                Q60883
                Q60884
                Q60885
                Q60886
                Q60887
                Q60888
                Q60889
                Q60890
                P49218
                Q60891
                Q60892
                P49220
                Q60893
                Q60894
                Q60895
                O70430
                O70432
                P51046
                P51047
                P51048
                P51049
                P51051
                P51052
                Q98913
                Q98914
                Q61616
                Q61618
                P79250
                P14803
                P49287
                Q28602
                P97267
                Q90305
                Q29006
                Q95252
                P34985
                Q90456
                Q95136
                Q95137
                Q62953
                Q95195]
      assert_equal(data.sort, @obj.list_falsepositive.sort)
    end

    def test_list_potentialhit
      data = %w[P41985
                P41986
                P17645
                Q60612
                Q60879
                P52592
                Q60882
                Q60883
                Q60884
                Q60885
                Q60886
                Q60887
                Q60888
                Q60889
                Q60890
                P49218
                Q60891
                Q60892
                P49220
                Q60893
                Q60894
                Q60895
                O70430
                O70432
                P51046
                P51047
                P51048
                P51049
                P51051
                P51052
                Q98913
                Q98914
                Q61616
                Q61618
                P79250
                P14803
                P49287
                Q28602
                P97267
                Q90305
                Q29006
                Q95252
                P34985
                Q90456
                Q95136
                Q95137
                Q62953
                Q95195]
      assert_equal(data.sort, @obj.list_potentialhit.sort)
    end

    def test_list_unknown
      data = []
      assert_equal(data, @obj.list_unknown)
    end

    def test_pdb_xref
      data = %w[1BOJ 1BOK 1F88]
      assert_equal(data, @obj.pdb_xref)
    end

    def test_pdoc_xref
      data = 'PDOC00210'
      assert_equal(data, @obj.pdoc_xref)
    end

    def test_pa2re
      pa = '[AC]-x-V-x(4)-{ED}.'
      assert_equal(/[AC].V.{4}[^ED]/i, @obj.pa2re(pa))
    end

    def test_self_pa2re
      pa = '[AC]-x-V-x(4)-{ED}.'
      assert_equal(/[AC].V.{4}[^ED]/i, Bio::PROSITE.pa2re(pa))
    end
  end # class TestPROSITE
end
