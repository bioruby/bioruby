# 
# bio/io/flatfile/indexer.rb - OBDA flatfile indexer
# 
#   Copyright (C) 2002 GOTO Naohisa <ngoto@gen-info.osaka-u.ac.jp> 
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
#  $Id: indexer.rb,v 1.1 2002/08/21 17:49:12 ng Exp $ 
# 

module Bio
  class FlatFileIndex

    module Indexer

      class NameSpace
	def initialize(name, method)
	  @name = name
	  @proc = method
	end
	attr_reader :name, :proc

	EMBL_STYLE = {
	  'ID' => self.new( 'ID', Proc.new { |x| x.entry_id } ),
	  'AC' => self.new( 'AC', Proc.new { |x| x.accessions } ),
	  'SV' => self.new( 'SV', Proc.new { |x| x.sv } ),
	  'DR' => self.new( 'DR', Proc.new { |x|
			     y = []
			     x.dr.each_value { |z| y << z }
			     y.flatten!
			     y.find_all { |z| z.length > 1 } }
			   )
	}

	NCBI_STYLE = {
	  'VERSION'   => self.new( 'VERSION', Proc.new { |x| x.version } ),
	  'LOCUS'     => self.new( 'LOCUS', Proc.new { |x| x.entry_id } ),
	  'ACCESSION' => self.new( 'ACCESSION',
				  Proc.new { |x| x.accession.split } ),
	  'GI'        => self.new( 'GI', Proc.new { |x|
				    x.gi.to_s.gsub(/\AGI\:/, '') } )
	}
      end #class NameSpace

      class NameSpaces < Array
	def names
	  self.collect { |x| x.name }
	end
      end

      class Parser
	# parsing data

	def initialize(dbclass, pri = nil, secs = nil)
	  @primary = nil
	  @secondary = NameSpaces.new
	  @format = nil
	  @dbclass = nil
	  @namestyle = nil

	  case dbclass.to_s
	  when 'embl', 'Bio::EMBL'
	    @format = 'embl'
	    @dbclass = Bio::EMBL
	    @namestyle = NameSpace::EMBL_STYLE
	    pri = 'ID' unless pri
	    unless secs then
	      secs = [ 'AC', 'SV' ]
	    end

	  when 'swiss', 'Bio::SPTR', 'Bio::TrEMBL', 'Bio::SwissProt'
	    @format = 'swiss'
	    @dbclass = Bio::SPTR
	    @namestyle = NameSpace::EMBL_STYLE
	    pri = 'ID' unless pri
	    unless secs then
	      secs = [ 'AC' ]
	    end

	  when 'genbank', 'Bio::GenBank', 'Bio::RefSeq', 'Bio::DDBJ'
	    @format = 'genbank'
	    @dbclass = Bio::GenBank
	    #pri = 'GI' unless pri
	    @namestyle = NameSpace::NCBI_STYLE
	    pri = 'VERSION' unless pri
	    unless secs then
	      secs = []
	      @namestyle.each_value { |x|
		secs << x.name if x.name != pri
	      }
	    end

	  when 'Bio::GenPept'
	    @format = 'genbank'
	    @dbclass = Bio::GenPept
	    @namestyle = NameSpace::NCBI_STYLE
	    pri = 'VERSION' unless pri
	    unless secs then
	      secs = []
	      @namestyle.each_value { |x|
		secs << x.name if x.name != pri
	      }
	    end

	  else
	    raise 'unknown or unsupported format'
	  end #case dbclass.to_s

	  @primary = @namestyle[pri] unless pri.is_a?(NameSpace)
	  raise 'unknown primary namespace' unless @primary
	  add_secondary_namespaces(*secs)
	end
	attr_reader :primary, :secondary, :format, :dbclass

	def add_secondary_namespaces(*names)
	  DEBUG.print "add_secondary_namespaces: #{names.inspect}\n"
	  names.each do |x|
	    unless x.is_a?(NameSpace) then
	      y = @namestyle[x]
	      raise 'unknown secondary namespace' unless y
	      @secondary << y
	    end
	  end
	  true
	end
      end #class Parser

      def self.makeindexBDB(name, format, pri, sec,
			    add_sec_ns, *files)
	DEBUG.print "makeing BDB DataBank...\n"
	fmt = Parser.new(format, pri, sec)
	fmt.add_secondary_namespaces(*add_sec_ns)

	db = DataBank.new(name, MAGIC_BDB)
	db.format = fmt.format
	db.fileids.add(*files)
	db.fileids.recalc

	db.primary = fmt.primary.name
	db.secondary = fmt.secondary.names

	DEBUG.print "writing config.dat, config, fileids ...\n"
	db.write('wb', BDBdefault::flag_write)

	dbclass = fmt.dbclass

	DEBUG.print "reading files...\n"

	pn = db.primary
	pn.file.close
	pn.file.flag = BDBdefault.flag_write

	db.secondary.each_files do |x|
	  x.file.close
	  x.file.flag = BDBdefault.flag_write
	end

	db.fileids.each_with_index do |fobj, fileid|
	  filename = fobj.filename
	  DEBUG.print fileid, " ", filename, "\n"

	  ff = Bio::FlatFile.open(dbclass, filename)
	  ff.raw = true
	  pos = ff.io.pos
	  ff.each do |txt|
	    len = txt.length
	    obj = dbclass.new(txt)
	    p = fmt.primary.proc.call(obj)
	    pn.file.add_exclusive(p, [ fileid, pos, len ])
	    DEBUG.print "#{p} #{fileid} #{pos} #{len}\n"
	    fmt.secondary.each_index do |i|
	      sn = fmt.secondary[i].name
	      s = fmt.secondary[i].proc.call(obj)
	      s.each { |x|
		db.secondary[sn].file.add_nr(x, p)
		DEBUG.print "#{x} #{p}\n"
	      }
	    end
	    pos = ff.io.pos
	  end
	  ff.close
	end
	db.close
	true
      end

      def self.makeindexFlat(name, format, pri, sec,
			 add_sec_ns, *files)
	DEBUG.print "makeing flat/1 DataBank...\n"
	fmt = Parser.new(format, pri, sec)
	fmt.add_secondary_namespaces(*add_sec_ns)

	db = DataBank.new(name, nil)
	db.format = fmt.format
	db.fileids.add(*files)
	db.primary = fmt.primary.name
	db.secondary = fmt.secondary.names

	dbclass = fmt.dbclass
	pdata = []
	sdata = Array.new(fmt.secondary.names.size)
	sdata.collect! { |x| [] }

	db.fileids.recalc
	DEBUG.print "writing DabaBank...\n"
	db.write('wb')

	DEBUG.print "reading files...\n"
	files.each_with_index do |filename, fileid|
	  DEBUG.print fileid, " ", filename, "\n"

	  ff = Bio::FlatFile.open(dbclass, filename)
	  ff.raw = true
	  pos = ff.io.pos
	  ff.each do |txt|
	    len = txt.length
	    obj = dbclass.new(txt)
	    p = fmt.primary.proc.call(obj)
	    pdata << [ p, [ fileid, pos, len ] ]
	    DEBUG.print "#{p} #{fileid} #{pos} #{len}\n"
	    fmt.secondary.each_index do |i|
	      s = fmt.secondary[i].proc.call(obj)
	      s.each { |x|
		sdata[i] << [ x, p ]
		DEBUG.print "#{x} #{p}\n"
	      }
	    end
	    pos = ff.io.pos
	  end
	  ff.close
	end

	DEBUG.print "sorting primary...\n"
	pdata.sort! do |x, y|
	  r = (x[0] <=> y[0])
	  if r == 0 then
	    raise RuntimeError, "keys must be unique, but duplicated key #{x[0].inspect} exists"
	  end
	  r
	end

	DEBUG.print "sorting secondary...\n"
	sdata.each { |a| a.sort! { |x, y| x[0] <=> y[0] } }
	  
	DEBUG.print "get record size...\n"
	psize = get_record_size(pdata)
	ssize = sdata.collect { |x| get_record_size(x) }

	DEBUG.print "writing...\n"
	write_mapfile(pdata, psize, db.primary.file)
	sdata.each_with_index do |x, i|
	  write_mapfile(x, ssize[i], db.secondary[fmt.secondary.names[i]].file)
	end

	db.close
	true
      end #def

      def self.get_record_size(a)
	size = 0
	a.each do |x|
	  l = x.flatten.join("\t").length
	  if l > size
	    size = l
	  end
	end
	size + 1
      end

      def self.write_mapfile(data, rec_size, mapfile)
	mapfile.mode = 'wb'
	mapfile.init(rec_size)
	data.each do |x|
	  mapfile.write_record(x.flatten.join("\t"))
	end
	mapfile.close
	mapfile.mode = 'rb'
	true
      end
    end #module Indexer

  end #class FlatFileIndex
end #module Bio
