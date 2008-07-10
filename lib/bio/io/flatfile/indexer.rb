# 
# = bio/io/flatfile/indexer.rb - OBDA flatfile indexer
# 
# Copyright:: Copyright (C) 2002 GOTO Naohisa <ng@bioruby.org> 
# License::   The Ruby License
# 
#  $Id: indexer.rb,v 1.26 2007/12/11 15:13:32 ngoto Exp $ 
# 

require 'bio/io/flatfile/index'

module Bio
  class FlatFileIndex

    module Indexer

      class NameSpace
        def initialize(name, method)
          @name = name
          @proc = method
        end
        attr_reader :name, :proc
      end #class NameSpace

      class NameSpaces < Hash
        def initialize(*arg)
          super()
          arg.each do |x|
            self.store(x.name, x)
          end
        end
        def names
          self.keys
        end
        def <<(x)
          self.store(x.name, x)
        end
        def add(x)
          self.store(x.name, x)
        end
        #alias each_orig each
        alias each each_value
      end

      module Parser
        def self.new(format, *arg)
          case format.to_s
          when 'embl', 'Bio::EMBL'
            EMBLParser.new(*arg)
          when 'swiss', 'Bio::SPTR', 'Bio::TrEMBL', 'Bio::SwissProt'
            SPTRParser.new(*arg)
          when 'genbank', 'Bio::GenBank', 'Bio::RefSeq', 'Bio::DDBJ'
            GenBankParser.new(*arg)
          when 'Bio::GenPept'
            GenPeptParser.new(*arg)
          when 'fasta', 'Bio::FastaFormat'
            FastaFormatParser.new(*arg)
          when 'Bio::FANTOM::MaXML::Sequence'
            MaXMLSequenceParser.new(*arg)
          when 'Bio::FANTOM::MaXML::Cluster'
            MaXMLClusterParser.new(*arg)
          when 'Bio::Blast::Default::Report'
            BlastDefaultParser.new(Bio::Blast::Default::Report, *arg)
          when 'Bio::Blast::Default::Report_TBlast'
            BlastDefaultParser.new(Bio::Blast::Default::Report_TBlast, *arg)
          when 'Bio::Blast::WU::Report'
            BlastDefaultParser.new(Bio::Blast::WU::Report, *arg)
          when 'Bio::Blast::WU::Report_TBlast'
            BlastDefaultParser.new(Bio::Blast::WU::Report_TBlast, *arg)
          when 'Bio::PDB::ChemicalComponent'
            PDBChemicalComponentParser.new(Bio::PDB::ChemicalComponent, *arg)
          else
            raise 'unknown or unsupported format'
          end #case dbclass.to_s
        end

        class TemplateParser
          NAMESTYLE = NameSpaces.new
          def initialize
            @namestyle = self.class::NAMESTYLE
            @secondary = NameSpaces.new
            @errorlog = []
          end
          attr_reader :primary, :secondary, :format, :dbclass
          attr_reader :errorlog

          def set_primary_namespace(name)
            DEBUG.print "set_primary_namespace: #{name.inspect}\n"
            if name.is_a?(NameSpace) then
              @primary = name
            else
              @primary = @namestyle[name] 
            end
            raise 'unknown primary namespace' unless @primary
            @primary
          end
        
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

          # administration of a single flatfile
          def open_flatfile(fileid, file)
            @fileid = fileid
            @flatfilename = file
            DEBUG.print "fileid=#{fileid} file=#{@flatfilename.inspect}\n"
            @flatfile = Bio::FlatFile.open(@dbclass, file, 'rb')
            @flatfile.raw = nil
            @flatfile.entry_pos_flag = true
            @entry = nil
          end
          attr_reader :fileid

          def each
            @flatfile.each do |x|
              @entry = x
              pos = @flatfile.entry_start_pos
              len = @flatfile.entry_ended_pos - @flatfile.entry_start_pos
              begin
                yield pos, len
              rescue RuntimeError, NameError => evar
                DEBUG.print "Caught error: #{evar.inspect}\n"
                DEBUG.print "in #{@flatfilename.inspect} position #{pos}\n"
                DEBUG.print "===begin===\n"
                DEBUG.print @flatfile.entry_raw.to_s.chomp
                DEBUG.print "\n===end===\n"
                @errorlog << [ evar, @flatfilename, pos ]
                if @fatal then
                  DEBUG.print "Fatal error occurred, stop creating index...\n"
                  raise evar
                else
                  DEBUG.print "This entry shall be incorrectly indexed.\n"
                end
              end #rescue
            end
          end

          def parse_primary
            r = self.primary.proc.call(@entry)
            unless r.is_a?(String) and r.length > 0
              #@fatal = true
              raise 'primary id must be a non-void string (skipped this entry)'
            end
            r
          end

          def parse_secondary
            self.secondary.each do |x|
              p = x.proc.call(@entry)
              p.each do |y|
                yield x.name, y if y.length > 0
              end
            end
          end

          def close_flatfile
            DEBUG.print "close flatfile #{@flatfilename.inspect}\n"
            @flatfile.close
          end

          protected
          attr_writer :format, :dbclass
        end #class TemplateParser

        class GenBankParser < TemplateParser
          NAMESTYLE = NameSpaces.new(
             NameSpace.new( 'VERSION', Proc.new { |x| x.acc_version } ),
             NameSpace.new( 'LOCUS', Proc.new { |x| x.entry_id } ),
             NameSpace.new( 'ACCESSION',
                           Proc.new { |x| x.accessions } ),
             NameSpace.new( 'GI', Proc.new { |x|
                             x.gi.to_s.gsub(/\AGI\:/, '') } )
                                     )
          PRIMARY = 'VERSION'
          def initialize(pri_name = nil, sec_names = nil)
            super()
            self.format = 'genbank'
            self.dbclass = Bio::GenBank
            self.set_primary_namespace((pri_name or PRIMARY))
            unless sec_names then
              sec_names = []
              @namestyle.each_value do |x|
                sec_names << x.name if x.name != self.primary.name
              end
            end
            self.add_secondary_namespaces(*sec_names)
          end
        end #class GenBankParser

        class GenPeptParser < GenBankParser
          def initialize(*arg)
            super(*arg)
            self.dbclass = Bio::GenPept
          end
        end #class GenPeptParser

        class EMBLParser < TemplateParser
          NAMESTYLE = NameSpaces.new(
             NameSpace.new( 'ID', Proc.new { |x| x.entry_id } ),
             NameSpace.new( 'AC', Proc.new { |x| x.accessions } ),
             NameSpace.new( 'SV', Proc.new { |x| x.sv } ),
             NameSpace.new( 'DR', Proc.new { |x|
                             y = []
                             x.dr.each_value { |z| y << z }
                             y.flatten!
                             y.find_all { |z| z.length > 1 } }
                           )
                                     )
          PRIMARY = 'ID'
          SECONDARY = [ 'AC', 'SV' ]
          def initialize(pri_name = nil, sec_names = nil)
            super()
            self.format = 'embl'
            self.dbclass = Bio::EMBL
            self.set_primary_namespace((pri_name or PRIMARY))
            unless sec_names then
              sec_names = self.class::SECONDARY
            end
            self.add_secondary_namespaces(*sec_names)
          end
        end #class EMBLParser

        class SPTRParser < EMBLParser
          SECONDARY = [ 'AC' ]
          def initialize(*arg)
            super(*arg)
            self.format = 'swiss'
            self.dbclass = Bio::SPTR
          end
        end #class SPTRParser

        class FastaFormatParser < TemplateParser
          NAMESTYLE = NameSpaces.new(
             NameSpace.new( 'UNIQUE', nil ),
             NameSpace.new( 'entry_id', Proc.new { |x| x.entry_id } ),
             NameSpace.new( 'accession', Proc.new { |x| x.accessions } ),
             NameSpace.new( 'id_string', Proc.new { |x| 
                             x.identifiers.id_strings
                           }),
             NameSpace.new( 'word', Proc.new { |x|
                             x.identifiers.words
                           })
                                     )
          PRIMARY = 'UNIQUE'
          SECONDARY = [ 'entry_id', 'accession', 'id_string', 'word' ]

          def unique_primary_key
            r = "#{@flatfilename}:#{@count}"
            @count += 1
            r
          end
          private :unique_primary_key

          def parse_primary
            if p = self.primary.proc then
              r = p.call(@entry)
              unless r.is_a?(String) and r.length > 0
                #@fatal = true
                raise 'primary id must be a non-void string (skipped this entry)'
              end
              r
            else
              unique_primary_key
            end
          end
                                     
          def initialize(pri_name = nil, sec_names = nil)
            super()
            self.format = 'fasta'
            self.dbclass = Bio::FastaFormat
            self.set_primary_namespace((pri_name or PRIMARY))
            unless sec_names then
              sec_names = self.class::SECONDARY
            end
            self.add_secondary_namespaces(*sec_names)
          end
          def open_flatfile(fileid, file)
            super
            @count = 1
            @flatfilename_base = File.basename(@flatfilename)
            @flatfile.pos = 0
            begin
              pos = @flatfile.pos
              line = @flatfile.gets
            end until (!line or line =~ /^\>/)
            @flatfile.pos = pos
          end
        end #class FastaFormatParser

        class MaXMLSequenceParser < TemplateParser
          NAMESTYLE = NameSpaces.new(
             NameSpace.new( 'id', Proc.new { |x| x.entry_id } ),
             NameSpace.new( 'altid', Proc.new { |x| x.id_strings } ),
             NameSpace.new( 'gene_ontology', Proc.new { |x|
                             x.annotations.get_all_by_qualifier('gene_ontology').collect { |y|
                               y.anntext
                             }
                           }),
             NameSpace.new( 'datasrc', Proc.new { |x|
                             a = []
                             x.annotations.each { |y|
                               y.datasrc.each { |z|
                                 a << z.split('|',2)[-1]
                                 a << z
                               }
                             }
                             a.sort!
                             a.uniq!
                             a
                           })
                                     )
          PRIMARY = 'id'
          SECONDARY = [ 'altid', 'gene_ontology', 'datasrc' ]
          def initialize(pri_name = nil, sec_names = nil)
            super()
            self.format = 'raw'
            self.dbclass = Bio::FANTOM::MaXML::Sequence
            self.set_primary_namespace((pri_name or PRIMARY))
            unless sec_names then
              sec_names = self.class::SECONDARY
            end
            self.add_secondary_namespaces(*sec_names)
          end
        end #class MaXMLSequenceParser

        class MaXMLClusterParser < TemplateParser
          NAMESTYLE = NameSpaces.new(
             NameSpace.new( 'id', Proc.new { |x| x.entry_id } ),
             NameSpace.new( 'altid', Proc.new { |x| x.sequences.id_strings } ),
             NameSpace.new( 'datasrc', Proc.new { |x|
                             a = x.sequences.collect { |y|
                               MaXMLSequenceParser::NAMESTYLE['datasrc'].proc.call(y)
                             }
                             a.flatten!
                             a.sort!
                             a.uniq!
                             a
                           }),
             NameSpace.new( 'gene_ontology', Proc.new { |x|
                             a = x.sequences.collect { |y|
                               MaXMLSequenceParser::NAMESTYLE['gene_ontology'].proc.call(y)
                             }
                             a.flatten!
                             a.sort!
                             a.uniq!
                             a
                           })
                                     )
          PRIMARY = 'id'
          SECONDARY = [ 'altid', 'gene_ontology', 'datasrc' ]
          def initialize(pri_name = nil, sec_names = nil)
            super()
            self.format = 'raw'
            self.dbclass = Bio::FANTOM::MaXML::Cluster
            self.set_primary_namespace((pri_name or PRIMARY))
            unless sec_names then
              sec_names = self.class::SECONDARY
            end
            self.add_secondary_namespaces(*sec_names)
          end
        end #class MaXMLSequenceParser

        class BlastDefaultParser < TemplateParser
          NAMESTYLE = NameSpaces.new(
             NameSpace.new( 'QUERY', Proc.new { |x| x.query_def } ),
             NameSpace.new( 'query_id', Proc.new { |x| 
                             a = Bio::FastaDefline.new(x.query_def.to_s).id_strings
                             a << x.query_def.to_s.split(/\s+/,2)[0]
                             a
                           } ),
             NameSpace.new( 'hit', Proc.new { |x|
                             a = x.hits.collect { |y|
                               b = Bio::FastaDefline.new(y.definition.to_s).id_strings
                               b << y.definition
                               b << y.definition.to_s.split(/\s+/,2)[0]
                               b
                             }
                             a.flatten!
                             a
                           } )
                             )
          PRIMARY = 'QUERY'
          SECONDARY = [ 'query_id', 'hit' ]
          def initialize(klass, pri_name = nil, sec_names = nil)
            super()
            self.format = 'raw'
            self.dbclass = klass
            self.set_primary_namespace((pri_name or PRIMARY))
            unless sec_names then
              sec_names = []
              @namestyle.each_value do |x|
                sec_names << x.name if x.name != self.primary.name
              end
            end
            self.add_secondary_namespaces(*sec_names)
          end
          def open_flatfile(fileid, file)
            super
            @flatfile.rewind
            @flatfile.dbclass = nil
            @flatfile.autodetect
            @flatfile.dbclass = self.dbclass unless @flatfile.dbclass
            @flatfile.rewind
            begin
              pos = @flatfile.pos
              line = @flatfile.gets
            end until (!line or line =~ /^T?BLAST/)
            @flatfile.pos = pos
          end
        end #class BlastDefaultReportParser

        class PDBChemicalComponentParser < TemplateParser
          NAMESTYLE = NameSpaces.new(
             NameSpace.new( 'UNIQUE', Proc.new { |x| x.entry_id } )
                                     )
          PRIMARY = 'UNIQUE'
          def initialize(klass, pri_name = nil, sec_names = nil)
            super()
            self.format = 'raw'
            self.dbclass = Bio::PDB::ChemicalComponent
            self.set_primary_namespace((pri_name or PRIMARY))
            unless sec_names then
              sec_names = []
              @namestyle.each_value do |x|
                sec_names << x.name if x.name != self.primary.name
              end
            end
            self.add_secondary_namespaces(*sec_names)
          end
          def open_flatfile(fileid, file)
            super
            @flatfile.pos = 0
            begin
              pos = @flatfile.pos
              line = @flatfile.gets
            end until (!line or line =~ /^RESIDUE /)
            @flatfile.pos = pos
          end
        end #class PDBChemicalComponentParser

      end #module Parser

      def self.makeindexBDB(name, parser, options, *files)
        # options are not used in this method
        unless defined?(BDB)
          raise RuntimeError, "Berkeley DB support not found"
        end
        DEBUG.print "makeing BDB DataBank...\n"
        db = DataBank.new(name, MAGIC_BDB)
        db.format = parser.format
        db.fileids.add(*files)
        db.fileids.recalc

        db.primary = parser.primary.name
        db.secondary = parser.secondary.names

        DEBUG.print "writing config.dat, config, fileids ...\n"
        db.write('wb', BDBdefault::flag_write)

        DEBUG.print "reading files...\n"

        addindex_bdb(db, BDBdefault::flag_write, (0...(files.size)),
                     parser, options)
        db.close
        true
      end #def

      def self.addindex_bdb(db, flag, need_update, parser, options)
        DEBUG.print "reading files...\n"

        pn = db.primary
        pn.file.close
        pn.file.flag = flag

        db.secondary.each_files do |x|
          x.file.close
          x.file.flag = flag
          x.file.open
          x.file.close
        end

        need_update.each do |fileid|
          filename = db.fileids[fileid].filename
          parser.open_flatfile(fileid, filename)
          parser.each do |pos, len|
            p = parser.parse_primary
            #pn.file.add_exclusive(p, [ fileid, pos, len ])
            pn.file.add_overwrite(p, [ fileid, pos, len ])
            #DEBUG.print "#{p} #{fileid} #{pos} #{len}\n"
            parser.parse_secondary do |sn, sp|
              db.secondary[sn].file.add_nr(sp, p)
              #DEBUG.print "#{sp} #{p}\n"
            end
          end
          parser.close_flatfile
        end
        true
      end #def

      def self.makeindexFlat(name, parser, options, *files)
        DEBUG.print "makeing flat/1 DataBank using temporary files...\n"

        db = DataBank.new(name, nil)
        db.format = parser.format
        db.fileids.add(*files)
        db.primary = parser.primary.name
        db.secondary = parser.secondary.names
        db.fileids.recalc
        DEBUG.print "writing DabaBank...\n"
        db.write('wb')

        addindex_flat(db, :new, (0...(files.size)), parser, options)
        db.close
        true
      end #def

      def self.addindex_flat(db, mode, need_update, parser, options)
        require 'tempfile'
        prog = options['sort_program']
        env = options['env_program']
        env_args = options['env_program_arguments']

        return false if need_update.to_a.size == 0

        DEBUG.print "prepare temporary files...\n"
        tempbase = "bioflat#{rand(10000)}-"
        pfile = Tempfile.open(tempbase + 'primary-')
        DEBUG.print "open temporary file #{pfile.path.inspect}\n"
        sfiles = {}
        parser.secondary.names.each do |x|
          sfiles[x] =  Tempfile.open(tempbase + 'secondary-')
          DEBUG.print "open temporary file #{sfiles[x].path.inspect}\n"
        end

        DEBUG.print "reading files...\n"
        need_update.each do |fileid|
          filename = db.fileids[fileid].filename
          parser.open_flatfile(fileid, filename)
          parser.each do |pos, len|
            p = parser.parse_primary
            pfile << "#{p}\t#{fileid}\t#{pos}\t#{len}\n"
            #DEBUG.print "#{p} #{fileid} #{pos} #{len}\n"
            parser.parse_secondary do |sn, sp|
              sfiles[sn] << "#{sp}\t#{p}\n"
              #DEBUG.print "#{sp} #{p}\n"
            end
          end
          parser.close_flatfile
          fileid += 1
        end

        sort_proc = chose_sort_proc(prog, mode, env, env_args)
        pfile.close(false)
        DEBUG.print "sorting primary (#{parser.primary.name})...\n"
        db.primary.file.import_tsv_files(true, mode, sort_proc, pfile.path)
        pfile.close(true)

        parser.secondary.names.each do |x|
          DEBUG.print "sorting secondary (#{x})...\n"
          sfiles[x].close(false)
          db.secondary[x].file.import_tsv_files(false, mode, sort_proc,
                                                sfiles[x].path)
          sfiles[x].close(true)
        end
        true
      end #def

      # default sort program
      DEFAULT_SORT = '/usr/bin/sort'

      # default env program (run a program in a modified environment)
      DEFAULT_ENV = '/usr/bin/env'

      # default arguments for env program
      DEFAULT_ENV_ARGS = [ 'LC_ALL=C' ]

      def self.chose_sort_proc(prog, mode = :new,
                               env = nil, env_args = nil)
        case prog
        when /^builtin$/i, /^hs$/i, /^lm$/i
          DEBUG.print "sort: internal sort routine\n"
          sort_proc = Flat_1::FlatMappingFile::internal_sort_proc
        when nil, ''
          if FileTest.executable?(DEFAULT_SORT)
            return chose_sort_proc(DEFAULT_SORT, mode, env, env_args)
          else
            DEBUG.print "sort: internal sort routine\n"
            sort_proc = Flat_1::FlatMappingFile::internal_sort_proc
          end
        else
          env_args ||= DEFAULT_ENV_ARGS
          if env == '' or env == false then # inhibit to use env program
            prefixes = [ prog ]
          elsif env then # uses given env program
            prefixes = [ env ] + env_args + [ prog ]
          else # env == nil; uses default env program if possible
            if FileTest.executable?(DEFAULT_ENV)
              prefixes = [ DEFAULT_ENV ] + env_args + [ prog ]
            else
              prefixes = [ prog ]
            end
          end
          DEBUG.print "sort: #{prefixes.join(' ')}\n"
          if mode == :new then
            sort_proc = Flat_1::FlatMappingFile::external_sort_proc(prefixes)
          else
            sort_proc = Flat_1::FlatMappingFile::external_merge_sort_proc(prefixes)
          end
        end
        sort_proc
      end

      def self.update_index(name, parser, options, *files)
        db = DataBank.open(name)

        if parser then
          raise 'file format mismatch' if db.format != parser.format
        else

          begin
            dbclass_orig =
              Bio::FlatFile.autodetect_file(db.fileids[0].filename)
          rescue TypeError, Errno::ENOENT
          end
          begin
            dbclass_new =
              Bio::FlatFile.autodetect_file(files[0])
          rescue TypeError, Errno::ENOENT
          end

          case db.format
          when 'swiss', 'embl'
            parser = Parser.new(db.format)
            if dbclass_new and dbclass_new != parser.dbclass
              raise 'file format mismatch'
            end
          when 'genbank'
            dbclass = dbclass_orig or dbclass_new
            if dbclass == Bio::GenBank or dbclass == Bio::GenPept
              parser = Parser.new(dbclass_orig)
            elsif !dbclass then
              raise 'cannnot determine format. please specify manually.'
            else
              raise 'file format mismatch'
            end
            if dbclass_new and dbclass_new != parser.dbclass
              raise 'file format mismatch'
            end
          else
            raise 'unsupported format'
          end
        end

        parser.set_primary_namespace(db.primary.name)
        parser.add_secondary_namespaces(*db.secondary.names)

        if options['renew'] then
          newfiles = db.fileids.filenames.find_all do |x|
            FileTest.exist?(x)
          end
          newfiles.concat(files)
          newfiles2 = newfiles.sort
          newfiles2.uniq!
          newfiles3 = []
          newfiles.each do |x|
            newfiles3 << x if newfiles2.delete(x)
          end
          t = db.index_type
          db.close
          case t
          when MAGIC_BDB
            Indexer::makeindexBDB(name, parser, options, *newfiles3)
          when MAGIC_FLAT
            Indexer::makeindexFlat(name, parser, options, *newfiles3)
          else
            raise 'Unsupported index type'
          end
          return true
        end

        need_update = []
        newfiles = files.dup
        db.fileids.cache_all
        db.fileids.each_with_index do |f, i|
          need_update << i unless f.check
          newfiles.delete(f.filename)
        end

        b = db.fileids.size
        begin
          db.fileids.recalc
        rescue Errno::ENOENT => evar
          DEBUG.print "Error: #{evar}\n"
          DEBUG.print "assumed --renew option\n"
          db.close
          options = options.dup
          options['renew'] = true
          update_index(name, parser, options, *files)
          return true
        end
        # add new files
        db.fileids.add(*newfiles)
        db.fileids.recalc

        need_update.concat((b...(b + newfiles.size)).to_a)

        DEBUG.print "writing DabaBank...\n"
        db.write('wb', BDBdefault::flag_append)

        case db.index_type
        when MAGIC_BDB
          addindex_bdb(db, BDBdefault::flag_append,
                       need_update, parser, options)
        when MAGIC_FLAT
          addindex_flat(db, :add, need_update, parser, options)
        else
          raise 'Unsupported index type'
        end

        db.close
        true
      end #def
    end #module Indexer

    ##############################################################
    def self.formatstring2class(format_string)
      case format_string
      when /genbank/i
        dbclass = Bio::GenBank
      when /genpept/i
        dbclass = Bio::GenPept
      when /embl/i
        dbclass = Bio::EMBL
      when /sptr/i
        dbclass = Bio::SPTR
      when /fasta/i
        dbclass = Bio::FastaFormat
      else
        raise "Unsupported format : #{format}"
      end
    end

    def self.makeindex(is_bdb, dbname, format, options, *files)
      if format then
        dbclass = formatstring2class(format)
      else
        dbclass = Bio::FlatFile.autodetect_file(files[0])
        raise "Cannot determine format" unless dbclass
        DEBUG.print "file format is #{dbclass}\n"
      end

      options = {} unless options
      pns = options['primary_namespace']
      sns = options['secondary_namespaces']

      parser = Indexer::Parser.new(dbclass, pns, sns)

      #if /(EMBL|SPTR)/ =~ dbclass.to_s then
        #a = [ 'DR' ]
        #parser.add_secondary_namespaces(*a)
      #end
      if sns = options['additional_secondary_namespaces'] then
        parser.add_secondary_namespaces(*sns)
      end

      if is_bdb then
        Indexer::makeindexBDB(dbname, parser, options, *files)
      else
        Indexer::makeindexFlat(dbname, parser, options, *files)
      end
    end #def makeindex

    def self.update_index(dbname, format, options, *files)
      if format then
        parser = Indexer::Parser.new(dbclass)
      else
        parser = nil
      end
      Indexer::update_index(dbname, parser, options, *files)
    end #def update_index

  end #class FlatFileIndex
end #module Bio

=begin

= Bio::FlatFile

--- Bio::FlatFile.makeindex(is_bdb, dbname, format, options, *files)

      Create index files (called a databank) of given files.

--- Bio::FlatFile.update_index(dbname, format, options, *files)

      Add entries to databank.

=end
