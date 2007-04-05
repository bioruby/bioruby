#
# test/unit/bio/db/test_rebase.rb - Unit test for Bio::REBASE
#
# Author::    Trevor Wennblom  <mailto:trevor@corevx.com>
# Copyright:: Copyright (c) 2005-2007 Midwinter Laboratories, LLC (http://midwinterlabs.com)
# License::   The Ruby License
#
#  $Id: test_rebase.rb,v 1.5 2007/04/05 23:35:43 trevor Exp $
#

require 'pathname'
libpath = Pathname.new(File.join(File.dirname(__FILE__), ['..'] * 4, 'lib')).cleanpath.to_s
$:.unshift(libpath) unless $:.include?(libpath)

require 'test/unit'
require 'bio/db/rebase'

module Bio #:nodoc:
  class TestREBASE < Test::Unit::TestCase #:nodoc:
    
    def setup
      enzyme_data = <<END
#
# REBASE version 511                                              emboss_e.511
#
AarI  CACCTGC 7 2 0 11  15  0 0
AasI  GACNNNNNNGTC  12  2 0 7 5 0 0
AatI  AGGCCT  6 2 1 3 3 0 0
END

      reference_data = <<END
#
# REBASE version 511                                              emboss_r.511
#
#
AarI
Arthrobacter aurescens SS2-322


A. Janulaitis
F
2
Grigaite, R., Maneliene, Z., Janulaitis, A., (2002) Nucleic Acids Res., vol. 30.
Maneliene, Z., Zakareviciene, L., Unpublished observations.
//
AasI
Arthrobacter aurescens RFL3


V. Butkus
F
1
Kazlauskiene, R., Vaitkevicius, D., Maneliene, Z., Trinkunaite, L., Kiuduliene, L., Petrusyte, M., Butkus, V., Janulaitis, A., Unpublished observations.
//
AatI
Acetobacter aceti


IFO 3281
O
2
Sato, H., Yamada, Y., (1990) J. Gen. Appl. Microbiol., vol. 36, pp. 273-277.
Sugisaki, H., Maekawa, Y., Kanazawa, S., Takanami, M., (1982) Nucleic Acids Res., vol. 10, pp. 5747-5752.
//
END

      supplier_data = <<END
#
# REBASE version 511                                              emboss_s.511
#
A GE Healthcare
B Invitrogen Corporation
C Minotech Biotechnology
E Stratagene
F Fermentas International Inc.
G Qbiogene
O Toyobo Biochemicals
END

      @obj = Bio::REBASE.new(enzyme_data, reference_data, supplier_data)
    end

    def test_methods
      a = @obj
      assert_equal(a['AarI'].organism, 'Arthrobacter aurescens SS2-322')
      assert_equal(a['AarI'].references.size, 2)
      assert_equal(a['AarI'].supplier_names, ['Fermentas International Inc.'])
      assert_equal(a['AarI'].pattern, 'CACCTGC')

      assert_equal(a['AatI'].supplier_names, ['Toyobo Biochemicals'])
      assert_equal(a['AatI'].suppliers, ['O'])
      
      assert_equal(a.enzyme_name?('aasi'), true)
      assert_equal(a.enzyme_name?('AarI'), true)
      assert_equal(a.enzyme_name?('Aari'), true)
      assert_equal(a.enzyme_name?('AbrI'), false)
    end

  end

end
