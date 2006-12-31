#
# bio/util/restrction_enzyme/integer.rb - Adds method to check for negative values
#
# Author::    Trevor Wennblom  <mailto:trevor@corevx.com>
# Copyright:: Copyright (c) 2005-2007 Midwinter Laboratories, LLC (http://midwinterlabs.com)
# License::   Distributes under the same terms as Ruby
#
#  $Id: integer.rb,v 1.2 2006/12/31 21:50:31 trevor Exp $
#
class Integer #:nodoc:
  def negative?
    self < 0
  end
end
