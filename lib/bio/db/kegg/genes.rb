#
# bio/db/genes.rb - KEGG/GENES database class
#
#   Copyright (C) 2000, 2001 KATAYAMA Toshiaki <k@bioruby.org>
#

require 'bio/sequence'

class GENES

  def initialize(entry)
    @orig = {}					# Hash of the original entry
    @data = {}					# Hash of the parsed entry

    tag = ''					# temporal key

    entry.each_line do |line|
      if line =~ /^\w/
	tag = tag_get(line)
	@orig[tag] = '' unless @orig[tag]	# String
      end
      @orig[tag] << line
    end

    return
  end


  ### general method to return block of the tag and contens as is
  def get(tag)
    @orig[tag]			# returns nil when not found
  end


  ### general method to return contens without tag and extra white spaces
  def fetch(tag)
    if @orig[tag]
      str = ''
      @orig[tag].each_line do |line|
	str << tag_cut(line)
      end
      return truncate(str)
    else
      return nil		# compatible with get()
    end
  end


  def entry(key = nil)
    unless @data['ENTRY']
      @data['ENTRY'] = {}

      @data['ENTRY']['id']	= @orig['ENTRY'][12..29].strip
      @data['ENTRY']['type']	= @orig['ENTRY'][30..39].strip
      @data['ENTRY']['species']	= @orig['ENTRY'][40..80].strip
    end

    if key
      @data['ENTRY'][key]
    else
      if block_given?
	@data['ENTRY'].each do |k, v|
	  yield(k, v)
	end
      else
	@data['ENTRY']
      end
    end
  end
  alias each_entry entry

  def name
    @data['NAME'] = fetch('NAME') unless @data['NAME']
    @data['NAME']
  end

  def definition
    @data['DEFINITION'] = fetch('DEFINITION') unless @data['DEFINITION']
    @data['DEFINITION']
  end

  def class
    @data['CLASS'] = fetch('CLASS') unless @data['CLASS']
    @data['CLASS']
  end

  def position
    @data['POSITION'] = fetch('POSITION') unless @data['POSITION']
    @data['POSITION']
  end

  def dblinks(key = nil)
    unless @data['DBLINKS']
      @data['DBLINKS'] = {}
      if @orig['DBLINKS']
        @orig['DBLINKS'].scan(/(\S+):\s+(\S+)\n/).each do |k, v|
          @data['DBLINKS'][k] = v
        end
      end
    end

    if key
      @data['DBLINKS'][key]
    else
      if block_given?
	@data['DBLINKS'].each do |k, v|
	  yield(k, v)
	end
      else
	@data['DBLINKS']
      end
    end
  end
  alias each_link dblinks

  def codon_usage
    # please implement!!
  end
  alias cu codon_usage

  def aaseq
    unless @data['AASEQ']
      if @orig['AASEQ']
	@data['AASEQ'] = fetch('AASEQ').gsub(/[\s\d\/]+/, '')
      else
	@data['AASEQ'] = ''
      end
    end
    return AAseq.new(@data['AASEQ'])
  end
  alias aa aaseq

  def aalen
    unless @data['AALEN']
      if @orig['AASEQ']
	@data['AALEN'] = tag_cut(@orig['AASEQ'][/.*/]).to_i
      else
	@data['AALEN'] = 0
      end
    end
    @data['AALEN']
  end

  def ntseq
    unless @data['NTSEQ']
      if @orig['NTSEQ']
	@data['NTSEQ'] = fetch('NTSEQ').gsub(/[\s\d\/]+/, '')
      else
	@data['NTSEQ'] = ''
      end
    end
    return NAseq.new(@data['NTSEQ'])
  end
  alias naseq ntseq
  alias nt ntseq
  alias na ntseq

  def ntlen
    unless @data['NTLEN']
      if @orig['NTSEQ']
	@data['NTLEN'] = tag_cut(@orig['NTSEQ'][/.*/]).to_i
      else
	@data['NTLEN'] = 0
      end
    end
    @data['NTLEN']
  end
  alias nalen ntlen


  ### change the default to private method below the line
  private


  # remove extra white spaces
  def truncate(str)
    return str.gsub(/\s+/, ' ').strip
  end

  def truncate!(str)
    # do not chain these lines to avoid performing on nil
    str.gsub!(/\s+/, ' ')
    str.strip!
    return str
  end


  # remove tag field from the line
  def tag_cut(str)
    if str.length > 12		# tag field length of the GENES is 12
      return str[12..str.length]
    else
      return ''			# to avoid returning nil
    end
  end

  def tag_cut!(str)
    str[0,12] = ''
    return str
  end


  # get tag field of the line
  def tag_get(str)
    return str[0,12].strip	# tag field length of the GENES is 12
  end

end
