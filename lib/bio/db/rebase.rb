#
# bio/db/rebase.rb - Interface for EMBOSS formatted REBASE files
#
# Author::    Trevor Wennblom  <mailto:trevor@corevx.com>
# Copyright:: Copyright (c) 2005-2007 Midwinter Laboratories, LLC (http://midwinterlabs.com)
# License::   The Ruby License
#
#  $Id: rebase.rb,v 1.8 2007/04/05 23:35:40 trevor Exp $
#

autoload :YAML, 'yaml'

module Bio #:nodoc:

autoload :Reference, 'bio/reference'

#
# bio/db/rebase.rb - Interface for EMBOSS formatted REBASE files
#
# Author::    Trevor Wennblom  <mailto:trevor@corevx.com>
# Copyright:: Copyright (c) 2005-2007 Midwinter Laboratories, LLC (http://midwinterlabs.com)
# License::   The Ruby License
#
#
# = Description
# 
# Bio::REBASE provides utilties for interacting with REBASE data in EMBOSS
# format.  REBASE is the Restriction Enzyme Database, more information
# can be found here:
# 
# * http://rebase.neb.com
# 
# EMBOSS formatted files located at:
# 
# * http://rebase.neb.com/rebase/rebase.f37.html
# 
# These files are the same as the "emboss_?.???" files located at:
# 
# * ftp://ftp.neb.com/pub/rebase/
# 
# To easily get started with the data you can simply type this command
# at your shell prompt:
# 
#   % wget ftp://ftp.neb.com/pub/rebase/emboss*
# 
# 
# = Usage
# 
#   require 'bio'
#   require 'pp'
# 
#   enz = File.read('emboss_e')
#   ref = File.read('emboss_r')
#   sup = File.read('emboss_s')
# 
#   # When creating a new instance of Bio::REBASE
#   # the contents of the enzyme file must be passed.
#   # The references and suppiers file contents
#   # may also be passed.
#   rebase = Bio::REBASE.new( enz )
#   rebase = Bio::REBASE.new( enz, ref )
#   rebase = Bio::REBASE.new( enz, ref, sup )
# 
#   # The 'read' class method allows you to read in files
#   # that are REBASE EMBOSS formatted
#   rebase = Bio::REBASE.read( 'emboss_e' )
#   rebase = Bio::REBASE.read( 'emboss_e', 'emboss_r' )
#   rebase = Bio::REBASE.read( 'emboss_e', 'emboss_r', 'emboss_s' )
# 
#   # The data loaded may be saved in YAML format
#   rebase.save_yaml( 'enz.yaml' )
#   rebase.save_yaml( 'enz.yaml', 'ref.yaml' )
#   rebase.save_yaml( 'enz.yaml', 'ref.yaml', 'sup.yaml' )
# 
#   # YAML formatted files can also be read with the
#   # class method 'load_yaml'
#   rebase = Bio::REBASE.load_yaml( 'enz.yaml' )
#   rebase = Bio::REBASE.load_yaml( 'enz.yaml', 'ref.yaml' )
#   rebase = Bio::REBASE.load_yaml( 'enz.yaml', 'ref.yaml', 'sup.yaml' )
# 
#   pp rebase.enzymes[0..4]                     # ["AarI", "AasI", "AatI", "AatII", "Acc16I"]
#   pp rebase.enzyme_name?('aasi')              # true
#   pp rebase['AarI'].pattern                   # "CACCTGC"
#   pp rebase['AarI'].blunt?                    # false
#   pp rebase['AarI'].organism                  # "Arthrobacter aurescens SS2-322"
#   pp rebase['AarI'].source                    # "A. Janulaitis"
#   pp rebase['AarI'].primary_strand_cut1       # 11
#   pp rebase['AarI'].primary_strand_cut2       # 0
#   pp rebase['AarI'].complementary_strand_cut1 # 15
#   pp rebase['AarI'].complementary_strand_cut2 # 0
#   pp rebase['AarI'].suppliers                 # ["F"]
#   pp rebase['AarI'].supplier_names            # ["Fermentas International Inc."]
# 
#   pp rebase['AarI'].isoschizomers             # Currently none stored in the references file
#   pp rebase['AarI'].methylation               # ""
# 
#   pp rebase['EcoRII'].methylation             # "2(5)"
#   pp rebase['EcoRII'].suppliers               # ["F", "J", "M", "O", "S"]
#   pp rebase['EcoRII'].supplier_names  # ["Fermentas International Inc.", "Nippon Gene Co., Ltd.",
#                                       # "Roche Applied Science", "Toyobo Biochemicals",
#                                       # "Sigma Chemical Corporation"]
# 
#   # Number of enzymes in the database
#   pp rebase.size                              # 673
#   pp rebase.enzymes.size                      # 673
# 
#   rebase.each do |name, info|
#     pp "#{name}:  #{info.methylation}" unless info.methylation.empty?
#   end
#

class REBASE

  class DynamicMethod_Hash < Hash #:nodoc:
    # Define a writer or reader
    # * Allows hash[:kay]= to be accessed like hash.key=
    # * Allows hash[:key] to be accessed like hash.key
    def method_missing(method_id, *args)
      k = self.class
      if method_id.to_s[-1].chr == '='
        k.class_eval do
          define_method(method_id) { |s| self[ method_id.to_s[0..-2].to_sym ] = s }
        end
        k.instance_method(method_id).bind(self).call(args[0])
      else
        k.class_eval do
          define_method(method_id) { self[method_id] }
        end
        k.instance_method(method_id).bind(self).call
      end
    end
  end

  class EnzymeEntry < DynamicMethod_Hash #:nodoc:
    @@supplier_data = {}
    def self.supplier_data=(d); @@supplier_data = d; end

    def supplier_names
      ret = []
      self.suppliers.each { |s| ret << @@supplier_data[s] }
      ret
    end
  end

  # Calls _block_ once for each element in <tt>@data</tt> hash, passing that element as a parameter.
  #
  # ---
  # *Arguments*
  # * Accepts a block
  # *Returns*:: results of _block_ operations
  def each
    @data.each { |item| yield item }
  end

  # Make the instantiated class act like a Hash on @data
  # Does the equivalent and more of this:
  #  def []( key ); @data[ key ]; end
  #  def size; @data.size; end
  def method_missing(method_id, *args) #:nodoc:
    self.class.class_eval do
      define_method(method_id) { |a| Hash.instance_method(method_id).bind(@data).call(a) }
    end
    Hash.instance_method(method_id).bind(@data).call(*args)
  end

  # Constructor
  #
  # ---
  # *Arguments*
  # * +enzyme_lines+: (_required_) contents of EMBOSS formatted enzymes file 
  # * +reference_lines+: (_optional_) contents of EMBOSS formatted references file 
  # * +supplier_lines+: (_optional_) contents of EMBOSS formatted suppliers files 
  # * +yaml+: (_optional_, _default_ +false+) enzyme_lines, reference_lines, and supplier_lines are read as YAML if set to true 
  # *Returns*:: Bio::REBASE
  def initialize( enzyme_lines, reference_lines = nil, supplier_lines = nil, yaml = false )
    # All your REBASE are belong to us.

    if yaml
      @enzyme_data = enzyme_lines
      @reference_data = reference_lines
      @supplier_data = supplier_lines
    else
      @enzyme_data = parse_enzymes(enzyme_lines)
      @reference_data = parse_references(reference_lines)
      @supplier_data = parse_suppliers(supplier_lines)
    end

    EnzymeEntry.supplier_data = @supplier_data
    setup_enzyme_data
  end

  # List the enzymes available
  #
  # ---
  # *Arguments*
  # * _none_
  # *Returns*:: +Array+ sorted enzyme names
  def enzymes
    @data.keys.sort
  end
  
  # Check if supplied name is the name of an available enzyme
  #
  # ---
  # *Arguments*
  # * +name+: Enzyme name
  # *Returns*:: +true/false+
  def enzyme_name?(name)
    enzymes.each do |e|
      return true if e.downcase == name.downcase
    end
    return false
  end

  # Save the current data
  #  rebase.save_yaml( 'enz.yaml' )
  #  rebase.save_yaml( 'enz.yaml', 'ref.yaml' )
  #  rebase.save_yaml( 'enz.yaml', 'ref.yaml', 'sup.yaml' )
  #
  # ---
  # *Arguments*
  # * +f_enzyme+: (_required_) Filename to save YAML formatted output of enzyme data
  # * +f_reference+: (_optional_) Filename to save YAML formatted output of reference data
  # * +f_supplier+: (_optional_) Filename to save YAML formatted output of supplier data  
  # *Returns*:: nothing
  def save_yaml( f_enzyme, f_reference=nil, f_supplier=nil )
    File.open(f_enzyme, 'w') { |f| f.puts YAML.dump(@enzyme_data) }
    File.open(f_reference, 'w') { |f| f.puts YAML.dump(@reference_data) } if f_reference
    File.open(f_supplier, 'w') { |f| f.puts YAML.dump(@supplier_data) } if f_supplier
    return
  end

  # Read REBASE EMBOSS-formatted files
  #  rebase = Bio::REBASE.read( 'emboss_e' )
  #  rebase = Bio::REBASE.read( 'emboss_e', 'emboss_r' )
  #  rebase = Bio::REBASE.read( 'emboss_e', 'emboss_r', 'emboss_s' )
  #
  # ---
  # *Arguments*
  # * +f_enzyme+: (_required_) Filename to read enzyme data
  # * +f_reference+: (_optional_) Filename to read reference data
  # * +f_supplier+: (_optional_) Filename to read supplier data  
  # *Returns*:: Bio::REBASE object
  def self.read( f_enzyme, f_reference=nil, f_supplier=nil )
    e = IO.readlines(f_enzyme)
    r = f_reference ? IO.readlines(f_reference) : nil
    s = f_supplier ? IO.readlines(f_supplier) : nil
    self.new(e,r,s)
  end

  # Read YAML formatted files
  #  rebase = Bio::REBASE.load_yaml( 'enz.yaml' )
  #  rebase = Bio::REBASE.load_yaml( 'enz.yaml', 'ref.yaml' )
  #  rebase = Bio::REBASE.load_yaml( 'enz.yaml', 'ref.yaml', 'sup.yaml' )
  #
  # ---
  # *Arguments*
  # * +f_enzyme+: (_required_) Filename to read YAML-formatted enzyme data
  # * +f_reference+: (_optional_) Filename to read YAML-formatted reference data
  # * +f_supplier+: (_optional_) Filename to read YAML-formatted supplier data  
  # *Returns*:: Bio::REBASE object
  def self.load_yaml( f_enzyme, f_reference=nil, f_supplier=nil )
    e = YAML.load_file(f_enzyme)
    r = f_reference ? YAML.load_file(f_reference) : nil
    s = f_supplier ? YAML.load_file(f_supplier) : nil
    self.new(e,r,s,true)
  end

  #########
  protected
  #########

  def setup_enzyme_data
    @data = {}
    
    @enzyme_data.each do |name, hash|
      @data[name] = EnzymeEntry.new
      d = @data[name]
      d.pattern                   = hash[:pattern]
      # d.blunt?= is a syntax error
      d[:blunt?] = (hash[:blunt].to_i == 1 ? true : false)
      d.primary_strand_cut1       = hash[:c1].to_i
      d.complementary_strand_cut1 = hash[:c2].to_i
      d.primary_strand_cut2       = hash[:c3].to_i
      d.complementary_strand_cut2 = hash[:c4].to_i

      # Set up keys just in case there's no reference data supplied
      [:organism, :isoschizomers, 
      :methylation, :source].each { |k| d[k] = '' }
      d.suppliers = []
      d.references = []
    end

    setup_enzyme_and_reference_association
  end

  def setup_enzyme_and_reference_association
    return unless @reference_data
    @reference_data.each do |name, hash|
      d = @data[name]
      [:organism, :isoschizomers, 
      :methylation, :source].each { |k| d[k] = hash[k] }
      d.suppliers = hash[:suppliers].split('')
      d.references = []
      hash[:references].each { |k| d.references << raw_to_reference(k) }
    end
  end

  # data is a hash indexed by the :name of each entry which is also a hash
  # * data[enzyme_name] has the following keys:
  #   :name, :pattern, :len, :ncuts, :blunt, :c1, :c2, :c3, :c4
  #   :c1 => First 5' cut
  #   :c2 => First 3' cut
  #   :c3 => Second 5' cut
  #   :c4 => Seocnd 3' cut
  def parse_enzymes( lines )
    data = {}
    return data if lines == nil
    lines.each do |line|
      next if line[0].chr == '#'
      line.chomp!
      
      a = line.split("\s")
      
      data[ a[0] ] = {
        :name => a[0],
        :pattern => a[1],
        :len => a[2],
        :ncuts => a[3],
        :blunt => a[4],
        :c1 => a[5],
        :c2 => a[6],
        :c3 => a[7],
        :c4 => a[8]
      }
    end  # lines.each
    data
  end

  # data is a hash indexed by the :name of each entry which is also a hash
  # * data[enzyme_name] has the following keys:
  #   :organism, :isoschizomers, :references, :source, :methylation, :suppliers, :name, :number_of_references
  def parse_references( lines )
    data = {}
    return data if lines == nil
    index = 1
    h = {}
    references_left = 0

    lines.each do |line|
      next if line[0].chr == '#'  # Comment
      next if line[0..1] == '//'  # End of entry marker
      line.chomp!

      if (1..7).include?( index )
        h[index] = line
        references_left = h[index].to_i if index == 7
        index += 1
        next
      end

      if index == 8
        h[index] ||= []
        h[index] << line
        references_left -= 1
      end

      if references_left == 0
        data[ h[1] ] = {
          :name => h[1],
          :organism => h[2],
          :isoschizomers => h[3],
          :methylation => h[4],
          :source => h[5],
          :suppliers => h[6],
          :number_of_references => h[7],
          :references => h[8]
        }
        index = 1
        h = {}
      end
    end  # lines.each
    data
  end

  # data is a hash indexed by the supplier code
  #   data[supplier_code]
  #   returns the suppliers name
  def parse_suppliers( lines )
    data = {}
    return data if lines == nil
    lines.each do |line|
      next if line[0].chr == '#'
      data[$1] = $2 if line =~ %r{(.+?)\s(.+)}
    end
    data
  end

  # Takes a string in one of the three formats listed below and returns a
  # Bio::Reference object
  # * Possible input styles:
  #   a = 'Inagaki, K., Hikita, T., Yanagidani, S., Nomura, Y., Kishimoto, N., Tano, T., Tanaka, H., (1993) Biosci. Biotechnol. Biochem., vol. 57, pp. 1716-1721.'
  #   b = 'Nekrasiene, D., Lapcinskaja, S., Kiuduliene, L., Vitkute, J., Janulaitis, A., Unpublished observations.'
  #   c = "Grigaite, R., Maneliene, Z., Janulaitis, A., (2002) Nucleic Acids Res., vol. 30."
  def raw_to_reference( line )
    a = line.split(', ')

    if a[-1] == 'Unpublished observations.'
      title = a.pop.chop
      pages = volume = year = journal = ''
    else
      title = ''

      pages_or_volume = a.pop.chop
      if pages_or_volume =~ %r{pp\.\s}
        pages = pages_or_volume
        pages.gsub!('pp. ', '')
        volume = a.pop
      else
        pages = ''
        volume = pages_or_volume
      end

      volume.gsub!('vol. ', '')

      year_and_journal = a.pop
      year_and_journal =~ %r{\((\d+)\)\s(.+)}
      year = $1
      journal = $2
    end

    authors = []

    last_name = nil
    a.each do |e|
      if last_name
        authors << "#{last_name}, #{e}"
        last_name = nil
      else
        last_name = e
      end
    end

    ref = {
      'title' => title,
      'pages' => pages,
      'volume' => volume,
      'year' => year,
      'journal' => journal,
      'authors' => authors,
    }

    Bio::Reference.new(ref)
  end

end # REBASE
end # Bio
