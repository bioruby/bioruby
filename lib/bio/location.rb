#
# = bio/location.rb - Locations/Location class (GenBank location format)
#
# Copyright::	Copyright (C) 2001, 2005 Toshiaki Katayama <k@bioruby.org>
# Copyright::   Copyright (C) 2006 Jan Aerts <jan.aerts@bbsrc.ac.uk>
# License::	The Ruby License
#
# $Id: location.rb,v 0.28 2007/04/05 23:35:39 trevor Exp $
#

module Bio

# == Description
#
# The Bio::Location class describes the position of a genomic locus.
# Typically, Bio::Location objects are created automatically when the
# user creates a Bio::Locations object, instead of initialized directly.
#
# == Usage
#
#   location = Bio::Location.new('500..550')
#   puts "start=" + location.from.to_s + ";end=" + location.to.to_s
#
#   #, or better: through Bio::Locations
#   locations = Bio::Locations.new('500..550')
#   locations.each do |location|
#     puts "start=" + location.from.to_s + ";end=" + location.to.to_s
#   end
#
class Location

  include Comparable
	
  # Parses a'location' segment, which can be 'ID:' + ('n' or 'n..m' or 'n^m'
  # or "seq") with '<' or '>', and returns a Bio::Location object.
  #
  #   location = Bio::Location.new('500..550')
  # 
  # ---
  # *Arguments*:
  # * (required) _str_: GenBank style position string (see Bio::Locations
  #   documentation)
  # *Returns*:: the Bio::Location object
  def initialize(location = nil)

    if location
      if location =~ /:/				# (G) ID:location
        xref_id, location = location.split(':')
      end
      if location =~ /</				# (I) <,>
        lt = true
      end
      if location =~ />/
        gt = true
      end
    end

    # s : start base, e : end base => from, to
    case location
    when /^[<>]?(\d+)$/					# (A, I) n
      s = e = $1.to_i
    when /^[<>]?(\d+)\.\.[<>]?(\d+)$/			# (B, I) n..m
      s = $1.to_i
      e = $2.to_i
      if e - s < 0
#       raise "Error: invalid range : #{location}"
        $stderr.puts "[Warning] invalid range : #{location}" if $DEBUG
      end
    when /^[<>]?(\d+)\^[<>]?(\d+)$/			# (C, I) n^m
      s = $1.to_i
      e = $2.to_i
      if e - s != 1
#       raise "Error: invalid range : #{location}"
        $stderr.puts "[Warning] invalid range : #{location}" if $DEBUG
      end
    when /^"?([ATGCatgc]+)"?$/                  # (H) literal sequence
      sequence = $1.downcase
      s = e = nil
    when nil
      ;
    else
      raise "Error: unknown location format : #{location}"
    end

    @from       = s             # start position of the location
    @to         = e             # end position of the location
    @strand     = 1             # strand direction of the location
                                #   forward => 1 or complement => -1
    @sequence   = sequence      # literal sequence of the location
    @lt         = lt            # true if the position contains '<'
    @gt         = gt            # true if the position contains '>'
    @xref_id    = xref_id       # link to the external entry as GenBank ID
  end

  attr_accessor :from, :to, :strand, :sequence, :lt, :gt, :xref_id

  # Complements the sequence (i.e. alternates the strand).
  # ---
  # *Returns*:: the Bio::Location object
  def complement
    @strand *= -1
    self					# return Location object
  end

  # Replaces the sequence of the location.
  # ---
  # *Arguments*:
  # * (required) _sequence_: sequence to be used to replace the sequence
  #   at the location
  # *Returns*:: the Bio::Location object
  def replace(sequence)
    @sequence = sequence.downcase
    self					# return Location object
  end

  # Returns the range (from..to) of the location as a Range object.
  def range
    @from..@to
  end

  # Check where a Bio::Location object is located compared to another
  # Bio::Location object (mainly to facilitate the use of Comparable).
  # A location A is upstream of location B if the start position of
  # location A is smaller than the start position of location B. If
  # they're the same, the end positions are checked.
  # ---
  # *Arguments*:
  # * (required) _other location_: a Bio::Location object
  # *Returns*::
  # * 1 if self < other location
  # * -1 if self > other location
  # * 0 if both location are the same
  # * nil if the argument is not a Bio::Location object
  def <=>(other)
    if ! other.kind_of?(Bio::Location)
      return nil
    end

    if @from.to_f < other.from.to_f
      return -1
    elsif @from.to_f > other.from.to_f
      return 1
    end

    if @to.to_f < other.to.to_f
      return -1
    elsif @to.to_f > other.to.to_f
      return 1
    end
    return 0
  end

end # Location

# == Description
#
# The Bio::Locations class is a container for Bio::Location objects:
# creating a Bio::Locations object (based on a GenBank style position string)
# will spawn an array of Bio::Location objects.
#
# == Usage
#
#   locations = Bio::Locations.new('join(complement(500..550), 600..625)')
#   locations.each do |loc|
#     puts "class = " + loc.class.to_s
#     puts "range = #{loc.from}..#{loc.to} (strand = #{loc.strand})"
#   end
#   # Output would be:
#   #   class = Bio::Location
#   #   range = 500..550 (strand = -1)
#   #   class = Bio::Location
#   #   range = 600..625 (strand = 1)
# 
#  # For the following three location strings, print the span and range
#  ['one-of(898,900)..983',
#   'one-of(5971..6308,5971..6309)',
#   '8050..one-of(10731,10758,10905,11242)'].each do |loc|
#      location = Bio::Locations.new(loc)
#      puts location.span
#      puts location.range
#  end
#
# === GenBank location descriptor classification
# 
# ==== Definition of the position notation of the GenBank location format
# 
# According to the GenBank manual 'gbrel.txt', position notations were
# classified into 10 patterns - (A) to (J).
# 
#   3.4.12.2 Feature Location
#   
#     The second column of the feature descriptor line designates the
#   location of the feature in the sequence. The location descriptor
#   begins at position 22. Several conventions are used to indicate
#   sequence location.
#   
#     Base numbers in location descriptors refer to numbering in the entry,
#   which is not necessarily the same as the numbering scheme used in the
#   published report. The first base in the presented sequence is numbered
#   base 1. Sequences are presented in the 5 to 3 direction.
#   
#   Location descriptors can be one of the following:
#       
#   (A) 1. A single base;
#         
#   (B) 2. A contiguous span of bases;
#         
#   (C) 3. A site between two bases;
#         
#   (D) 4. A single base chosen from a range of bases;
#     
#   (E) 5. A single base chosen from among two or more specified bases;
#     
#   (F) 6. A joining of sequence spans;
#     
#   (G) 7. A reference to an entry other than the one to which the feature
#        belongs (i.e., a remote entry), followed by a location descriptor
#        referring to the remote sequence;
#     
#   (H) 8. A literal sequence (a string of bases enclosed in quotation marks).
#   
# ==== Description commented with pattern IDs.
#  
#   (C)   A site between two residues, such as an endonuclease cleavage site, is
#       indicated by listing the two bases separated by a carat (e.g., 23^24).
#     
#   (D)   A single residue chosen from a range of residues is indicated by the
#       number of the first and last bases in the range separated by a single
#       period (e.g., 23.79). The symbols < and > indicate that the end point
#   (I) of the range is beyond the specified base number.
# 
#   (B)   A contiguous span of bases is indicated by the number of the first and
#       last bases in the range separated by two periods (e.g., 23..79). The
#   (I) symbols < and > indicate that the end point of the range is beyond the
#       specified base number. Starting and ending positions can be indicated
#       by base number or by one of the operators described below.
# 
#         Operators are prefixes that specify what must be done to the indicated
#       sequence to locate the feature. The following are the operators
#       available, along with their most common format and a description.
# 
#   (J) complement (location): The feature is complementary to the location
#       indicated. Complementary strands are read 5 to 3.
# 
#   (F) join (location, location, .. location): The indicated elements should
#       be placed end to end to form one contiguous sequence.
# 
#   (F) order (location, location, .. location): The elements are found in the
#       specified order in the 5 to 3 direction, but nothing is implied about
#       the rationality of joining them.
# 
#   (F) group (location, location, .. location): The elements are related and
#       should be grouped together, but no order is implied.
# 
#   (E) one-of (location, location, .. location): The element can be any one,
#     but only one, of the items listed.
# 
# === Reduction strategy of the position notations
# 
# * (A) Location n
# * (B) Location n..m
# * (C) Location n^m
# * (D) (n.m)			=> Location n
# * (E)
#   * one-of(n,m,..)		=> Location n
#   * one-of(n..m,..)		=> Location n..m
# * (F)
#   * order(loc,loc,..)		=> join(loc, loc,..)
#   * group(loc,loc,..)		=> join(loc, loc,..)
#   * join(loc,loc,..)		=> Sequence
# * (G) ID:loc			=> Location with ID
# * (H) "atgc"			=> Location only with Sequence
# * (I)
#   * <n			=> Location n with lt flag
#   * >n			=> Location n with gt flag
#   * <n..m			=> Location n..m with lt flag
#   * n..>m			=> Location n..m with gt flag
#   * <n..>m			=> Location n..m with lt, gt flag
# * (J) complement(loc)		=> Sequence
# * (K) replace(loc, str)	=> Location with replacement Sequence
# 
class Locations

  include Enumerable

  # Parses a GenBank style position string and returns a Bio::Locations
  # object, which contains a list of Bio::Location objects.
  #
  #   locations = Bio::Locations.new('join(complement(500..550), 600..625)')
  #
  # ---
  # *Arguments*:
  # * (required) _str_: GenBank style position string
  # *Returns*:: Bio::Locations object
  def initialize(position)
    if position.is_a? Array
      @locations = position
    else
      position   = gbl_cleanup(position)	# preprocessing
      @locations = gbl_pos2loc(position)	# create an Array of Bio::Location objects
    end
  end

  # An Array of Bio::Location objects
  attr_accessor :locations

  # Evaluate equality of Bio::Locations object.
  def equals?(other)
    if ! other.kind_of?(Bio::Locations)
      return nil
    end
    if self.sort == other.sort
      return true
    else
      return false
    end
  end

  # Iterates on each Bio::Location object.
  def each
    @locations.each do |x|
      yield(x)
    end
  end

  # Returns nth Bio::Location object.
  def [](n)
    @locations[n]
  end

  # Returns first Bio::Location object.
  def first
    @locations.first
  end

  # Returns last Bio::Location object.
  def last
    @locations.last
  end

  # Returns an Array containing overall min and max position [min, max]
  # of this Bio::Locations object.
  def span
    span_min = @locations.min { |a,b| a.from <=> b.from }
    span_max = @locations.max { |a,b| a.to   <=> b.to   }
    return span_min.from, span_max.to
  end

  # Similar to span, but returns a Range object min..max
  def range
    min, max = span
    min..max
  end

  # Returns a length of the spliced RNA.
  def length
    len = 0
    @locations.each do |x|
      if x.sequence
        len += x.sequence.size
      else
        len += (x.to - x.from + 1)
      end
    end
    len
  end
  alias size length

  # Converts absolute position in the whole of the DNA sequence to relative 
  # position in the locus.
  # 
  # This method can for example be used to relate positions in a DNA-sequence
  # with those in RNA. In this use, the optional ':aa'-flag returns the
  # position of the associated amino-acid rather than the nucleotide.
  #
  #   loc = Bio::Locations.new('complement(12838..13533)')
  #   puts loc.relative(13524)        # => 10
  #   puts loc.relative(13506, :aa)   # => 3
  #
  # ---
  # *Arguments*:
  # * (required) _position_: nucleotide position within whole of the sequence
  # * _:aa_: flag that lets method return position in aminoacid coordinates
  # *Returns*:: position within the location
  def relative(n, type = nil)
    case type
    when :location
      ;
    when :aa
      if n = abs2rel(n)
        (n - 1) / 3 + 1
      else
        nil
      end
    else
      abs2rel(n)
    end
  end

  # Converts relative position in the locus to position in the whole of the
  # DNA sequence.
  # 
  # This method can for example be used to relate positions in a DNA-sequence
  # with those in RNA. In this use, the optional ':aa'-flag returns the
  # position of the associated amino-acid rather than the nucleotide.
  #
  #   loc = Bio::Locations.new('complement(12838..13533)')
  #   puts loc.absolute(10)          # => 13524
  #   puts loc.absolute(10, :aa)     # => 13506
  #
  # ---
  # *Arguments*:
  # * (required) _position_: nucleotide position within locus
  # * _:aa_: flag to be used if _position_ is a aminoacid position rather than
  #   a nucleotide position
  # *Returns*:: position within the whole of the sequence
  def absolute(n, type = nil)
    case type
    when :location
      ;
    when :aa
      n = (n - 1) * 3 + 1
      rel2abs(n)
    else
      rel2abs(n)
    end
  end


  private


  # Preprocessing to clean up the position notation.
  def gbl_cleanup(position)
    # sometimes position contains white spaces...
    position.gsub!(/\s+/, '')

    # select one base					# (D) n.m
    #               ..         n          m           :
    #     <match>   $1       ( $2         $3       not   )
    position.gsub!(/(\.{2})?\(?([<>\d]+)\.([<>\d]+)(?!:)\)?/) do |match|
      if $1
        $1 + $3						# ..(n.m)  => ..m
      else
        $2						# (?n.m)?  => n
      end
    end

    # select the 1st location				# (E) one-of()
    #     <match>   ..      one-of ($2     ,$3      )
    position.gsub!(/(\.{2})?one-of\(([^,]+),([^)]+)\)/) do |match|
      if $1
        $1 + $3.gsub(/.*,(.*)/, '\1')			# ..one-of(n,m)  => ..m
      else
        $2						# one-of(n,m)    => n
      end
    end

    # substitute order(), group() by join()		# (F) group(), order()
    position.gsub!(/(order|group)/, 'join')

    return position
  end


  # Parse position notation and create Location objects.
  def gbl_pos2loc(position)
    ary = []

    case position

    when /^join\((.*)\)$/				# (F) join()
      position = $1

      join_list = []		# sub positions to join
      bracket   = []		# position with bracket
      s_count   = 0		# stack counter

      position.split(',').each do |sub_pos|
        case sub_pos
        when /\(.*\)/
          join_list << sub_pos
        when /\(/
          s_count += 1
          bracket << sub_pos
        when /\)/
          s_count -= 1
          bracket << sub_pos
          if s_count == 0
            join_list << bracket.join(',')
          end
        else
          if s_count == 0
            join_list << sub_pos
          else
            bracket << sub_pos
          end
        end
      end

      join_list.each do |position|
        ary << gbl_pos2loc(position)
      end

    when /^complement\((.*)\)$/				# (J) complement()
      position =       $1
      gbl_pos2loc(position).reverse_each do |location|
        ary << location.complement
      end

    when /^replace\(([^,]+),"?([^"]*)"?\)/		# (K) replace()
      position =    $1
      sequence =              $2
      ary << gbl_pos2loc(position).first.replace(sequence)

    else						# (A, B, C, G, H, I)
      ary << Location.new(position)

    end

    return ary.flatten
  end


  # Convert the relative position to the absolute position
  def rel2abs(n) 
    return nil unless n > 0			# out of range 

    cursor = 0 
    @locations.each do |x|      
      if x.sequence 
        len = x.sequence.size 
      else 
        len = x.to - x.from + 1 
      end  
      if n > cursor + len 
        cursor += len 
      else 
        if x.strand < 0 
          return x.to - (n - cursor - 1) 
        else 
          return x.from + (n - cursor - 1) 
        end 
      end                             
    end 
    return nil					# out of range 
  end

  # Convert the absolute position to the relative position
  def abs2rel(n)
    return nil unless n > 0			# out of range

    cursor = 0
    @locations.each do |x|
      if x.sequence
        len = x.sequence.size
      else
        len = x.to - x.from + 1
      end
      if n < x.from or n > x.to then
        cursor += len
      else
        if x.strand < 0 then
          return x.to - (n - cursor - 1)
        else
          return n + cursor + 1 - x.from
        end
      end
    end
    return nil					# out of range
  end

end # Locations

end # Bio



# === GenBank location examples
# 
# (C) n^m
# 
# * [AB015179]	754^755
# * [AF179299]	complement(53^54)
# * [CELXOL1ES]	replace(4480^4481,"")
# * [ECOUW87]	replace(4792^4793,"a")
# * [APLPCII]	replace(1905^1906,"acaaagacaccgccctacgcc")
# 
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
# * [AP000001]	join(complement(1..61),complement(AP000007.1:252907..253505))
# * [ASNOS11]	join(AF130124.1:<2563..2964,AF130125.1:21..157,AF130126.1:12..174,AF130127.1:21..112,AF130128.1:21..162,AF130128.1:281..595,AF130128.1:661..842,AF130128.1:916..1030,AF130129.1:21..115,AF130130.1:21..165,AF130131.1:21..125,AF130132.1:21..428,AF130132.1:492..746,AF130133.1:21..168,AF130133.1:232..401,AF130133.1:475..906,AF130133.1:970..1107,AF130133.1:1176..1367,21..>128)
# 
# * [AARPOB2]	order(AF194507.1:<1..510,1..>871)
# * [AF006691]	order(912..1918,20410..21416)
# * [AF024666]	order(complement(18919..19224),complement(13965..14892))
# * [AF264948]	order(27066..27076,27089..27099,27283..27314,27330..27352)
# * [D63363]	order(3..26,complement(964..987))
# * [ECOCURLI2]	order(complement(1009..>1260),complement(AF081827.1:<1..177))
# * [S72388S2]	order(join(S72388.1:757..911,S72388.1:609..1542),1..>139)
# * [HEYRRE07]	order(complement(1..38),complement(M82666.1:1..140),complement(M82665.1:1..176),complement(M82664.1:1..215),complement(M82663.1:1..185),complement(M82662.1:1..49),complement(M82661.1:1..133))
# * [COL11A1G34]	order(AF101079.1:558..1307,AF101080.1:1..749,AF101081.1:1..898,AF101082.1:1..486,AF101083.1:1..942,AF101084.1:1..1734,AF101085.1:1..2385,AF101086.1:1..1813,AF101087.1:1..2287,AF101088.1:1..1073,AF101089.1:1..989,AF101090.1:1..5017,AF101091.1:1..3401,AF101092.1:1..1225,AF101093.1:1..1072,AF101094.1:1..989,AF101095.1:1..1669,AF101096.1:1..918,AF101097.1:1..1114,AF101098.1:1..1074,AF101099.1:1..1709,AF101100.1:1..986,AF101101.1:1..1934,AF101102.1:1..1699,AF101103.1:1..940,AF101104.1:1..2330,AF101105.1:1..4467,AF101106.1:1..1876,AF101107.1:1..2465,AF101108.1:1..1150,AF101109.1:1..1170,AF101110.1:1..1158,AF101111.1:1..1193,1..611)
# 
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
# 
# * [AARPOB2]	order(AF194507.1:<1..510,1..>871)
# * [AF178221S4]	join(AF178221.1:<1..60,AF178222.1:1..63,AF178223.1:1..42,1..>90)
# * [BOVMHDQBY4]	join(M30006.1:(392.467)..575,M30005.1:415..681,M30004.1:129..410,M30004.1:907..1017,521..534)
# * [HUMSOD102]	order(L44135.1:(454.445)..>538,<1..181)
# * [SL16SRRN1]	order(<1..>267,X67092.1:<1..>249,X67093.1:<1..>233)
# 
# (I) <, >
# 
# * [A5U48871]	<1..>318
# * [AA23SRRNP]	<1..388
# * [AA23SRRNP]	503..>1010
# * [AAM5961]	complement(<1..229)
# * [AAM5961]	complement(5231..>5598)
# * [AF043934]	join(<1,60..99,161..241,302..370,436..594,676..887,993..1141,1209..1329,1387..1559,1626..1646,1708..>1843)
# * [BACSPOJ]	<180..(731.761)
# * [BBU17998]	(88.89)..>1122
# * [AARPOB2]	order(AF194507.1:<1..510,1..>871)
# * [SL16SRRN1]	order(<1..>267,X67092.1:<1..>249,X67093.1:<1..>233)
# 
# (J) complement
# 
# * [AF179299]	complement(53^54)	<= hoge insertion site etc.
# * [AP000001]	join(complement(1..61),complement(AP000007.1:252907..253505))
# * [AF209868S2]	order(complement(1..>308),complement(AF209868.1:75..336))
# * [AP000001]	join(complement(1..61),complement(AP000007.1:252907..253505))
# * [CPPLCG]	complement(<1..(1093.1098))
# * [D63363]	order(3..26,complement(964..987))
# * [ECHTGA]	complement((1700.1708)..(1715.1721))
# * [ECOUXW]	order(complement(1658..1663),complement(1636..1641))
# * [LPATOVGNS]	complement((64.74)..1525)
# * [AF129075]	complement(join(71606..71829,75327..75446,76039..76203,76282..76353,76914..77029,77114..77201,77276..77342,78138..78316,79755..79892,81501..81562,81676..81856,82341..82490,84208..84287,85032..85122,88316..88403))
# * [ZFDYST2]	join(AF137145.1:<1..18,complement(<1..99))
# 
# (K) replace
# 
# * [CSU27710]	replace(64,"A")
# * [CELXOL1ES]	replace(5256,"t")
# * [ANICPC]	replace(1..468,"")
# * [CSU27710]	replace(67..68,"GC")
# * [CELXOL1ES]	replace(4480^4481,"")	<= ? only one case in GenBank 122.0
# * [ECOUW87]	replace(4792^4793,"a")
# * [CEU34893]	replace(1..22,"ggttttaacccagttactcaag")
# * [APLPCII]	replace(1905^1906,"acaaagacaccgccctacgcc")
# * [MBDR3S1]	replace(1400..>9281,"")
# * [HUMMHDPB1F]	replace(complement(36..37),"ttc")
# * [HUMMIC2A]	replace((651.655)..(651.655),"")
# * [LEIMDRPGP]	replace(1..1554,"L01572")
# * [TRBND3]	replace(376..395,"atttgtgtgtggtaatta")
# * [TRBND3]	replace(376..395,"atttgtgtgggtaatttta")
# * [TRBND3]	replace(376..395,"attttgttgttgttttgttttgaatta")
# * [TRBND3]	replace(376..395,"atgtgtggtgaatta")
# * [TRBND3]	replace(376..395,"atgtgtgtggtaatta")
# * [TRBND3]	replace(376..395,"gatttgttgtggtaatttta")
# * [MSU09460]	replace(193,		<= replace(193, "t")
# * [HUMMAGE12X]	replace(3002..3003,	<= replace(3002..3003, "GC")
# * [ADR40FIB]	replace(510..520,	<= replace(510..520, "taatcctaccg")
# * [RATDYIIAAB]	replace(1306..1443,"aagaacatccacggagtcagaactgggctcttcacgccggatttggcgttcgaggccattgtgaaaaagcaggcaatgcaccagcaagctcagttcctacccctgcgtggacctggttatccaggagctaatcagtacagttaggtggtcaagctgaaagagccctgtctgaaa")
#

if __FILE__ == $0
  puts "Test new & span methods"
  [
    '450',
    '500..600',
    'join(500..550, 600..625)',
    'complement(join(500..550, 600..625))',
    'join(complement(500..550), 600..625)',
    '754^755',
    'complement(53^54)',
    'replace(4792^4793,"a")',
    'replace(1905^1906,"acaaagacaccgccctacgcc")',
    '157..(800.806)',
    '(67.68)..(699.703)',
    '(45934.45974)..46135',
    '<180..(731.761)',
    '(88.89)..>1122',
    'complement((1700.1708)..(1715.1721))',
    'complement(<22..(255.275))',
    'complement((64.74)..1525)',
    'join((8298.8300)..10206,1..855)',
    'replace((651.655)..(651.655),"")',
    'one-of(898,900)..983',
    'one-of(5971..6308,5971..6309)',
    '8050..one-of(10731,10758,10905,11242)',
    'one-of(623,627,632)..one-of(628,633,637)',
    'one-of(845,953,963,1078,1104)..1354',
    'join(2035..2050,complement(1775..1818),13..345,414..992,1232..1253,1024..1157)',
    'join(complement(1..61),complement(AP000007.1:252907..253505))',
    'complement(join(71606..71829,75327..75446,76039..76203))',
    'order(3..26,complement(964..987))',
    'order(L44135.1:(454.445)..>538,<1..181)',
    '<200001..<318389',
  ].each do |pos|
    p pos
#    p Bio::Locations.new(pos)
#    p Bio::Locations.new(pos).span
#    p Bio::Locations.new(pos).range
    Bio::Locations.new(pos).each do |location|
      puts "class=" + location.class.to_s
      puts "start=" + location.from.to_s + "\tend=" + location.to.to_s + "\tstrand=" + location.strand.to_s
    end

  end

  puts "Test rel2abs/abs2rel method"
  [
    '6..15',
    'join(6..10,16..30)',
    'complement(join(6..10,16..30))',
    'join(complement(6..10),complement(16..30))',
    'join(6..10,complement(16..30))',
  ].each do |pos|
    loc = Bio::Locations.new(pos)
    p pos
#   p loc
    (1..21).each do |x|
      print "absolute(#{x}) #=> ", y = loc.absolute(x), "\n"
      print "relative(#{y}) #=> ", y ? loc.relative(y) : y, "\n"
      print "absolute(#{x}, :aa) #=> ", y = loc.absolute(x, :aa), "\n"
      print "relative(#{y}, :aa) #=> ", y ? loc.relative(y, :aa) : y, "\n"
    end
  end

  pos = 'join(complement(6..10),complement(16..30))'
  loc = Bio::Locations.new(pos)
  print "pos         : "; p pos
  print "`- loc[1]   : "; p loc[1]
  print "   `- range : "; p loc[1].range

  puts Bio::Location.new('5').<=>(Bio::Location.new('3'))
end

