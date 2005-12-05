#
# test/unit/bio/db/test_rebase.rb - Unit test for Bio::REBASE
#
# Copyright::  Copyright (C) 2005 Trevor Wennblom <trevor@corevx.com>
# License::    LGPL
#
#  $Id: test_rebase.rb,v 1.1 2005/12/05 19:44:07 trevor Exp $
#
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
#

require 'pathname'
libpath = Pathname.new(File.join(File.dirname(__FILE__), ['..'] * 4, 'lib')).cleanpath.to_s
$:.unshift(libpath) unless $:.include?(libpath)

require 'test/unit'
require 'bio/db/rebase'

module Bio
  class TestGFF < Test::Unit::TestCase
    
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
    end

  end

end
