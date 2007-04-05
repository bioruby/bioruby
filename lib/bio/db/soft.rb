#
# bio/db/soft.rb - Interface for SOFT formatted files
#
# Author::    Trevor Wennblom  <mailto:trevor@corevx.com>
# Copyright:: Copyright (c) 2007 Midwinter Laboratories, LLC (http://midwinterlabs.com)
# License::   The Ruby License
#
#  $Id: soft.rb,v 1.2 2007/04/05 23:35:40 trevor Exp $
#

module Bio #:nodoc:

#
# bio/db/soft.rb - Interface for SOFT formatted files
#
# Author::    Trevor Wennblom  <mailto:trevor@corevx.com>
# Copyright:: Copyright (c) 2007 Midwinter Laboratories, LLC (http://midwinterlabs.com)
# License::   The Ruby License
#
#
# = Description
# 
# "SOFT (Simple Omnibus in Text Format) is a compact, simple, line-based, 
# ASCII text format that incorporates experimental data and metadata."
# -- <em>GEO, National Center for Biotechnology Information</em>
#
# The Bio::SOFT module reads SOFT Series or Platform formatted files that 
# contain information
# describing one database, one series, one platform, and many samples (GEO
# accessions).  The data from the file can then be viewed with Ruby methods.
#
# Bio::SOFT also supports the reading of SOFT DataSet files which contain
# one database, one dataset, and many subsets.
#
# Format specification is located here:
# * http://www.ncbi.nlm.nih.gov/projects/geo/info/soft2.html#SOFTformat
#
# SOFT data files may be directly downloaded here:
# * ftp://ftp.ncbi.nih.gov/pub/geo/DATA/SOFT
#
# NCBI's Gene Expression Omnibus (GEO) is here:
# * http://www.ncbi.nlm.nih.gov/geo
#
# = Usage
# 
# If an attribute has more than one value then the values are stored in an
# Array of String objects.  Otherwise the attribute is stored as a String.
#
# The platform and each sample may contain a table of data.  A dataset from a
# DataSet file may also contain a table.
#
# Attributes are dynamically created based on the data in the file.
# Predefined keys have not been created in advance due to the variability of
# SOFT files in-the-wild.
#
# Keys are generally stored as Symbols.  In the case of keys for samples and
# table headings may alternatively be accessed with Strings.
# The names of samples (geo accessions) are case sensitive.  Table headers 
# are case insensitive.
#
#   require 'bio'
#
#   lines = IO.readlines('GSE3457_family.soft') 
#   soft = Bio::SOFT.new(lines)
#   
#   soft.platform[:geo_accession]             # => "GPL2092"
#   soft.platform[:organism]                  # => "Populus"
#   soft.platform[:contributor]               # => ["Jingyi,,Li", "Olga,,Shevchenko", "Steve,H,Strauss", "Amy,M,Brunner"]
#   soft.platform[:data_row_count]            # => "240"
#   soft.platform.keys.sort {|a,b| a.to_s <=> b.to_s}[0..2] # => [:contact_address, :contact_city, :contact_country]
#   soft.platform[:"contact_zip/postal_code"] # => "97331"
#   soft.platform[:table].header              # => ["ID", "GB_ACC", "SPOT_ID", "Function/Family", "ORGANISM", "SEQUENCE"]
#   soft.platform[:table].header_description  # => {"ORGANISM"=>"sequence sources", "SEQUENCE"=>"oligo sequence used", "Function/Family"=>"gene functions and family", "ID"=>"", "SPOT_ID"=>"", "GB_ACC"=>"Gene bank accession number"}
#   soft.platform[:table].rows.size           # => 240
#   soft.platform[:table].rows[5]             # => ["A039P68U", "AI163321", "", "TF, flowering protein CONSTANS", "P. tremula x P. tremuloides", "AGAAAATTCGATATACTGTCCGTAAAGAGGTAGCACTTAGAATGCAACGGAATAAAGGGCAGTTCACCTC"]
#   soft.platform[:table].rows[5][4]          # => "P. tremula x P. tremuloides"
#   soft.platform[:table].rows[5][:organism]  # => "P. tremula x P. tremuloides"
#   soft.platform[:table].rows[5]['ORGANISM'] # => "P. tremula x P. tremuloides"
#   
#   soft.series[:geo_accession]               # => "GSE3457"
#   soft.series[:contributor]                 # => ["Jingyi,,Li", "Olga,,Shevchenko", "Ove,,Nilsson", "Steve,H,Strauss", "Amy,M,Brunner"]
#   soft.series[:platform_id]                 # => "GPL2092"
#   soft.series[:sample_id].size              # => 74
#   soft.series[:sample_id][0..4]             # => ["GSM77557", "GSM77558", "GSM77559", "GSM77560", "GSM77561"]
#   
#   soft.database[:name]                      # => "Gene Expression Omnibus (GEO)"
#   soft.database[:ref]                       # => "Nucleic Acids Res. 2005 Jan 1;33 Database Issue:D562-6"
#   soft.database[:institute]                 # => "NCBI NLM NIH"
#   
#   soft.samples.size                         # => 74
#   soft.samples[:GSM77600][:series_id]       # => "GSE3457"
#   soft.samples['GSM77600'][:series_id]      # => "GSE3457"
#   soft.samples[:GSM77600][:platform_id]     # => "GPL2092"
#   soft.samples[:GSM77600][:type]            # => "RNA"
#   soft.samples[:GSM77600][:title]           # => "jst2b2"
#   soft.samples[:GSM77600][:table].header    # => ["ID_REF", "VALUE"]
#   soft.samples[:GSM77600][:table].header_description # => {"ID_REF"=>"", "VALUE"=>"normalized signal intensities"}
#   soft.samples[:GSM77600][:table].rows.size # => 217
#   soft.samples[:GSM77600][:table].rows[5]   # => ["A039P68U", "8.19"]
#   soft.samples[:GSM77600][:table].rows[5][0]        # => "A039P68U"
#   soft.samples[:GSM77600][:table].rows[5][:id_ref]  # => "A039P68U"
#   soft.samples[:GSM77600][:table].rows[5]['ID_REF'] # => "A039P68U"
#
#   
#   lines = IO.readlines('GDS100.soft') 
#   soft = Bio::SOFT.new(lines)
#   
#   soft.database[:name]                      # => "Gene Expression Omnibus (GEO)"
#   soft.database[:ref]                       # => "Nucleic Acids Res. 2005 Jan 1;33 Database Issue:D562-6"
#   soft.database[:institute]                 # => "NCBI NLM NIH"
#   
#   soft.subsets.size                         # => 8
#   soft.subsets.keys                         # => ["GDS100_1", "GDS100_2", "GDS100_3", "GDS100_4", "GDS100_5", "GDS100_6", "GDS100_7", "GDS100_8"]
#   soft.subsets[:GDS100_7]                   # => {:dataset_id=>"GDS100", :type=>"time", :sample_id=>"GSM548,GSM543", :description=>"60 minute"}
#   soft.subsets['GDS100_7'][:sample_id]      # => "GSM548,GSM543"
#   soft.subsets[:GDS100_7][:sample_id]       # => "GSM548,GSM543"
#   soft.subsets[:GDS100_7][:dataset_id]      # => "GDS100"
#   
#   soft.dataset[:order]                      # => "none"
#   soft.dataset[:sample_organism]            # => "Escherichia coli"
#   soft.dataset[:table].header               # => ["ID_REF", "IDENTIFIER", "GSM549", "GSM542", "GSM543", "GSM547", "GSM544", "GSM545", "GSM546", "GSM548"]
#   soft.dataset[:table].rows.size            # => 5764
#   soft.dataset[:table].rows[5]              # => ["6", "EMPTY", "0.097", "0.217", "0.242", "0.067", "0.104", "0.162", "0.104", "0.154"]
#   soft.dataset[:table].rows[5][4]           # => "0.242"
#   soft.dataset[:table].rows[5][:gsm549]     # => "0.097"
#   soft.dataset[:table].rows[5][:GSM549]     # => "0.097"
#   soft.dataset[:table].rows[5]['GSM549']    # => "0.097"
# 
class SOFT
  attr_accessor :database
  attr_accessor :series, :platform, :samples
  attr_accessor :dataset, :subsets
  
  LINE_TYPE_ENTITY_INDICATOR = '^'
  LINE_TYPE_ENTITY_ATTRIBUTE = '!'
  LINE_TYPE_TABLE_HEADER = '#'
  # data table row defined by absence of line type character
  
  TABLE_COLUMN_DELIMITER = "\t"
  
  # Constructor
  #
  # ---
  # *Arguments*
  # * +lines+: (_required_) contents of SOFT formatted file 
  # *Returns*:: Bio::SOFT
  def initialize(lines=nil)
    @database = Database.new
    
    @series = Series.new
    @platform = Platform.new
    @samples = Samples.new
    
    @dataset = Dataset.new
    @subsets = Subsets.new
    
    process(lines)
  end
  
  # Classes for Platform and Series files
  
  class Samples < Hash #:nodoc:
    def [](x)
      x = x.to_s if x.kind_of?( Symbol )
      super(x)
    end
  end
  
  class Entity < Hash #:nodoc:
  end

  class Sample < Entity #:nodoc:
  end
  
  class Platform < Entity #:nodoc:
  end
  
  class Series < Entity #:nodoc:
  end
  
  # Classes for DataSet files
  
  class Subsets < Samples #:nodoc:
  end
  
  class Subset < Entity #:nodoc:
  end
  
  class Dataset < Entity #:nodoc:
  end
  
  # Classes important for all types

  class Database < Entity #:nodoc:
  end
  
  class Table #:nodoc:
    attr_accessor :header
    attr_accessor :header_description
    attr_accessor :rows
    
    class Header < Array #:nodoc:
      # @column_index contains column name => numerical index of column
      attr_accessor :column_index
      
      def initialize
        @column_index = {}
      end
    end
    
    class Row < Array #:nodoc:
      attr_accessor :header_object
      
      def initialize( n, header_object=nil )
        @header_object = header_object
        super(n)
      end
      
      def [](x)
        if x.kind_of?( Fixnum )
          super(x)
        else
          begin
            x = x.to_s.downcase.to_sym
            z = @header_object.column_index[x]
            unless z.kind_of?( Fixnum )
              raise IndexError, "#{x.inspect} is not a valid index.  Contents of @header_object.column_index: #{@header_object.column_index.inspect}"
            end
            self[ z ]
          rescue NoMethodError
            unless @header_object
              $stderr.puts "Table::Row @header_object undefined!"
            end
            raise
          end
        end
      end
    end
    
    def initialize()
      @header_description = {}
      @header = Header.new
      @rows = []
    end
    
    def add_header( line )
      raise "Can only define one header" unless @header.empty?      
      @header = @header.concat( parse_row( line ) )  # beware of clobbering this into an Array
      @header.each_with_index do |key, i|
        @header.column_index[key.downcase.to_sym] = i
      end
    end
    
    def add_row( line )
      @rows << Row.new( parse_row( line ), @header )
    end
    
    def add_header_or_row( line )
      @header.empty? ? add_header( line ) : add_row( line )        
    end
    
    protected
    def parse_row( line )
      line.split( TABLE_COLUMN_DELIMITER )
    end
  end
  
  #########
  protected
  #########
  
  def process(lines)
    current_indicator = nil
    current_class_accessor = nil
    in_table = false
        
    lines.each_with_index do |line, line_number|
      line.strip!
      next if line.nil? or line.empty?
      case line[0].chr
      when LINE_TYPE_ENTITY_INDICATOR
        current_indicator, value = split_label_value_in( line[1..-1] )

        case current_indicator
        when 'DATABASE'
          current_class_accessor = @database
        when 'DATASET'
          current_class_accessor = @dataset
        when 'PLATFORM'
          current_class_accessor = @platform
        when 'SERIES'
          current_class_accessor = @series
        when 'SAMPLE'
          @samples[value] = Sample.new
          current_class_accessor = @samples[value]
        when 'SUBSET'
          @subsets[value] = Subset.new
          current_class_accessor = @subsets[value]
        else
          custom_raise( line_number, error_msg(40, line) )
        end
          
      when LINE_TYPE_ENTITY_ATTRIBUTE
        if( current_indicator == nil )
          custom_raise( line_number, error_msg(30) )
        end
        
        # Handle lines such as '!platform_table_begin' and '!platform_table_end'
        if in_table
          if line =~ %r{table_begin}
            next
          elsif line =~ %r{table_end}
            in_table = false
            next
          end
        end
        
        key, value = split_label_value_in( line, true )
        key_s = key.to_sym
        
        if current_class_accessor.include?( key_s )
          if current_class_accessor[ key_s ].class != Array
            current_class_accessor[ key_s ] = [ current_class_accessor[ key_s ] ]
          end
          current_class_accessor[key.to_sym] << value
        else
          current_class_accessor[key.to_sym] = value
        end
        
      when LINE_TYPE_TABLE_HEADER
        if( (current_indicator != 'SAMPLE') and (current_indicator != 'PLATFORM') and (current_indicator != 'DATASET') )
          custom_raise( line_number, error_msg(20, current_indicator.inspect) )
        end
        
        in_table = true   # may be redundant, computationally not worth checking

        # We only expect one table per platform or sample
        current_class_accessor[:table] ||= Table.new
        key, value = split_label_value_in( line )
        # key[1..-1] -- Remove first character which is the LINE_TYPE_TABLE_HEADER
        current_class_accessor[:table].header_description[ key[1..-1] ] = value
        
      else
        # Type: No line type - should be a row in a table.
        
        if( (current_indicator == nil) or (in_table == false) )
          custom_raise( line_number, error_msg(10) )
        end
        current_class_accessor[:table].add_header_or_row( line )
      end
    end
  end
  
  def error_msg( i, extra_info=nil )
    case i
    when 10
      x = ["Lines without line-type characters are rows in a table, but",
      "a line containing an entity indicator such as",
      "\"#{LINE_TYPE_ENTITY_INDICATOR}SAMPLE\",",
      "\"#{LINE_TYPE_ENTITY_INDICATOR}PLATFORM\",",
      "or \"#{LINE_TYPE_ENTITY_INDICATOR}DATASET\" has not been",
      "previously encountered or it does not appear that this line is",
      "in a table."]
    when 20
      # tables are allowed inside samples and platforms
      x = ["Tables are only allowed inside SAMPLE and PLATFORM.",
        "Current table information found inside #{extra_info}."]
    when 30
      x = ["Entity attribute line (\"#{LINE_TYPE_ENTITY_ATTRIBUTE}\")",
        "found before entity indicator line (\"#{LINE_TYPE_ENTITY_INDICATOR}\")"]
    when 40
      x = ["Unkown entity indicator.  Must be DATABASE, SAMPLE, PLATFORM,",
        "SERIES, DATASET, or SUBSET."]
    else
      raise IndexError, "Unknown error message requested."
    end
    
    x.join(" ")
  end
  
  def custom_raise( line_number_with_0_based_indexing, msg )
    raise ["Error processing input line: #{line_number_with_0_based_indexing+1}",
      msg].join("\t")
  end
  
  def split_label_value_in( line, shift_key=false )
    line =~ %r{\s*=\s*}
    key, value = $`, $'
    
    if shift_key
      key =~ %r{_}
      key = $'
    end
    
    if( (key == nil) or (value == nil) )
      puts line.inspect
      raise
    end
    
    [key, value]
  end

end # SOFT
end # Bio