#
# = bio/io/flatfile/autodetection.rb - file format auto-detection
#
#   Copyright (C) 2001-2006 Naohisa Goto <ng@bioruby.org>
#
# License:: The Ruby License
#
#  $Id:$
#
#
#  See documents for Bio::FlatFile::AutoDetect and Bio::FlatFile.
#

require 'tsort'
require 'bio/io/flatfile'

module Bio

  class FlatFile

    # AutoDetect automatically determines database class of given data.
    class AutoDetect

      include TSort

      # Array to store autodetection rules.
      # This is defined only for inspect.
      class RulesArray < Array
        # visualize contents
        def inspect
          "[#{self.collect { |e| e.name.inspect }.join(' ')}]"
        end
      end #class RulesArray

      # Template of a single rule of autodetection
      class RuleTemplate
        # Creates a new element.
        def self.[](*arg)
          self.new(*arg)
        end
        
        # Creates a new element.
        def initialize
          @higher_priority_elements = RulesArray.new
          @lower_priority_elements  = RulesArray.new
          @name = nil
        end

        # self is prior to the _elem_.
        def is_prior_to(elem)
          return nil if self == elem
          elem.higher_priority_elements << self
          self.lower_priority_elements << elem
          true
        end

        # higher priority elements
        attr_reader :higher_priority_elements
        # lower priority elements
        attr_reader :lower_priority_elements

        # database classes
        attr_reader :dbclasses

        # unique name of the element
        attr_accessor :name

        # If given text (and/or meta information) is known, returns
        # the database class.
        # Otherwise, returns nil or false.
        #
        # _text_ will be a String.
        # _meta_ will be a Hash.
        # _meta_ may contain following keys.
        # :path => pathname, filename or uri.
        def guess(text, meta)
          nil
        end

        private
        # Gets constant from constant name given as a string.
        def str2const(str)
          const = Object
          str.split(/\:\:/).each do |x|
            const = const.const_get(x)
          end
          const
        end

        # Gets database class from given object.
        # Current implementation is: 
        # if _obj_ is kind of String, regarded as a constant.
        # Otherwise, returns _obj_ as is.
        def get_dbclass(obj)
          obj.kind_of?(String) ? str2const(obj) : obj
        end
      end #class Rule_Template

      # RuleDebug is a class for debugging autodetect classes/methods
      class RuleDebug < RuleTemplate
        # Creates a new instance.
        def initialize(name)
          super()
          @name = name
        end

        # prints information to the $stderr.
        def guess(text, meta)
          $stderr.puts @name
          $stderr.puts text.inspect
          $stderr.puts meta.inspect
          nil
        end
      end #class RuleDebug

      # Special element that is always top or bottom priority.
      class RuleSpecial < RuleTemplate
        def initialize(name)
          #super()
          @name = name
        end
        # modification of @name is inhibited.
        def name=(x)
          raise 'cannot modify name'
        end

        # always returns void array
        def higher_priority_elements
          []
        end
        # always returns void array
        def lower_priority_elements
          []
        end
      end #class RuleSpecial

      # Special element that is always top priority.
      TopRule = RuleSpecial.new('top')
      # Special element that is always bottom priority.
      BottomRule = RuleSpecial.new('bottom')

      # A autodetection rule to use a regular expression
      class RuleRegexp < RuleTemplate
        # Creates a new instance.
        def initialize(dbclass, re)
          super()
          @re = re
          @name = dbclass.to_s
          @dbclass = nil
          @dbclass_lazy = dbclass
        end

        # database class (lazy evaluation)
        def dbclass
          unless @dbclass
            @dbclass = get_dbclass(@dbclass_lazy)
          end
          @dbclass
        end
        private :dbclass

        # returns database classes
        def dbclasses
          [ dbclass ]
        end

        # If given text matches the regexp, returns the database class.
        # Otherwise, returns nil or false.
        # _meta_ is ignored.
        def guess(text, meta)
          @re =~ text ? dbclass : nil
        end
      end #class RuleRegexp

      # A autodetection rule to use more than two regular expressions.
      # If given string matches one of the regular expressions,
      # returns the database class.
      class RuleRegexp2 < RuleRegexp
        # Creates a new instance.
        def initialize(dbclass, *regexps)
          super(dbclass, nil)
          @regexps = regexps
        end

        # If given text matches one of the regexp, returns the database class.
        # Otherwise, returns nil or false.
        # _meta_ is ignored.
        def guess(text, meta)
          @regexps.each do |re|
            return dbclass if re =~ text
          end
          nil
        end
      end #class RuleRegexp

      # A autodetection rule that passes data to the proc object.
      class RuleProc < RuleTemplate
        # Creates a new instance.
        def initialize(*dbclasses, &proc)
          super()
          @proc = proc
          @dbclasses = nil
          @dbclasses_lazy = dbclasses
          @name = dbclasses.collect { |x| x.to_s }.join('|')
        end

        # database classes (lazy evaluation)
        def dbclasses
          unless @dbclasses
            @dbclasses = @dbclasses_lazy.collect { |x| get_dbclass(x) }
          end
          @dbclasses
        end

        # If given text (and/or meta information) is known, returns
        # the database class.
        # Otherwise, returns nil or false.
        #
        # Refer RuleTemplate#guess for _meta_.
        def guess(text, meta)
          @proc.call(text)
        end
      end #class RuleProc
      
      # Creates a new Autodetect object
      def initialize
        # stores autodetection rules.
        @rules = Hash.new
        # stores elements (cache)
        @elements = nil
        self.add(TopRule)
        self.add(BottomRule)
      end

      # Adds a new element.
      # Returns _elem_.
      def add(elem)
        raise 'element name conflicts' if @rules[elem.name]
        @elements = nil
        @rules[elem.name] = elem
        elem
      end

      # (required by TSort.)
      # For all elements, yields each element.
      def tsort_each_node(&x)
        @rules.each_value(&x)
      end

      # (required by TSort.)
      # For a given element, yields each child
      # (= lower priority elements) of the element.
      def tsort_each_child(elem)
        if elem == TopRule then
          @rules.each_value do |e|
            yield e unless e == TopRule or 
              e.lower_priority_elements.index(TopRule)
          end
        elsif elem == BottomRule then
          @rules.each_value do |e|
            yield e if e.higher_priority_elements.index(BottomRule)
          end
        else
          elem.lower_priority_elements.each do |e|
            yield e if e != BottomRule
          end
          unless elem.higher_priority_elements.index(BottomRule)
            yield BottomRule
          end
        end
      end

      # Returns current elements as an array
      # whose order fulfills all elements' priorities.
      def elements
        unless @elements
          ary = tsort
          ary.reverse!
          @elements = ary
        end
        @elements
      end

      # rebuilds the object and clears internal cache.
      def rehash
        @rules.rehash
        @elements = nil
      end

      # visualizes the object (mainly for debug)
      def inspect
        "<#{self.class.to_s} " +
          self.elements.collect { |e| e.name.inspect }.join(' ') +
          ">"
      end

      # Iterates over each element.
      def each_rule(&x) #:yields: elem
        elements.each(&x)
      end

      # Autodetect from the text.
      # Returns a database class if succeeded.
      # Returns nil if failed.
      def autodetect(text, meta = {})
        r = nil
        elements.each do |e|
          #$stderr.puts e.name
          r = e.guess(text, meta)
          break if r
        end
        r
      end

      # autodetect from the FlatFile object.
      # Returns a database class if succeeded.
      # Returns nil if failed.
      def autodetect_flatfile(ff, lines = 31)
        meta = {}
        stream = ff.instance_eval { @stream }
        begin
          path = stream.path
        rescue NameError
        end
        if path then
          meta[:path] = path
          # call autodetect onece with meta and without any read action
          if r = self.autodetect(stream.prefetch_buffer, meta)
            return r
          end
        end
        # reading stream
        1.upto(lines) do |x|
          break unless line = stream.prefetch_gets
          if line.strip.size > 0 then
            if r = self.autodetect(stream.prefetch_buffer, meta)
              return r
            end
          end
        end
        return nil
      end

      # default autodetect object for class method
      @default = nil

      # returns the default autodetect object
      def self.default
        unless @default then
          @default = self.make_default
        end
        @default
      end

      # sets the default autodetect object.
      def self.default=(ad)
        @default = ad
      end

      # make a new autodetect object
      def self.[](*arg)
        a = self.new
        arg.each { |e| a.add(e) }
        a
      end

      # make a default of default autodetect object
      def self.make_default
        a = self[
          genbank  = RuleRegexp[ 'Bio::GenBank',
            /^LOCUS       .+ bp .*[a-z]*[DR]?NA/ ],
          genpept  = RuleRegexp[ 'Bio::GenPept',
            /^LOCUS       .+ aa .+/ ],
          RuleRegexp[ 'Bio::MEDLINE',
            /^PMID\- [0-9]+$/ ],
          embl     = RuleRegexp[ 'Bio::EMBL',
            /^ID   .+\; .*(DNA|RNA|XXX)\;/ ],
          sptr     = RuleRegexp2[ 'Bio::SPTR',
            /^ID   .+\; *PRT\;/,
            /^ID   [-A-Za-z0-9_\.]+ .+\; *[0-9]+ *AA\./ ],
          prosite  = RuleRegexp[ 'Bio::PROSITE',
            /^ID   [-A-Za-z0-9_\.]+\; (PATTERN|RULE|MATRIX)\.$/ ],
          transfac = RuleRegexp[ 'Bio::TRANSFAC',
            /^AC  [-A-Za-z0-9_\.]+$/ ],

          RuleProc.new('Bio::AAindex1', 'Bio::AAindex2') do |text|
            if /^H [-A-Z0-9_\.]+$/ =~ text then
              if text =~ /^M [rc]/ then
                Bio::AAindex2
              elsif text =~ /^I    A\/L/ then
                Bio::AAindex1
              else
                false #fail to determine
              end
            else
              nil
            end
          end,

          RuleRegexp[ 'Bio::LITDB',
            /^CODE        [0-9]+$/ ],
          pathway_module = RuleRegexp[ 'Bio::KEGG::MODULE',
            /^ENTRY       .+ Pathway\s+Module\s*/ ],
          pathway  = RuleRegexp[ 'Bio::KEGG::PATHWAY',
            /^ENTRY       .+ Pathway\s*/ ],
          brite    = RuleRegexp[ 'Bio::KEGG::BRITE',
            /^Entry           [A-Z0-9]+/ ],
          orthology = RuleRegexp[ 'Bio::KEGG::ORTHOLOGY',
            /^ENTRY       .+ KO\s*/ ],
          drug     = RuleRegexp[ 'Bio::KEGG::DRUG',
            /^ENTRY       .+ Drug\s*/ ],
          glycan   = RuleRegexp[ 'Bio::KEGG::GLYCAN',
            /^ENTRY       .+ Glycan\s*/ ],
          enzyme   = RuleRegexp2[ 'Bio::KEGG::ENZYME',
            /^ENTRY       EC [0-9\.]+$/,
            /^ENTRY       .+ Enzyme\s*/
          ],
          compound = RuleRegexp2[ 'Bio::KEGG::COMPOUND',
            /^ENTRY       C[A-Za-z0-9\._]+$/,
            /^ENTRY       .+ Compound\s*/
          ],
          reaction = RuleRegexp2[ 'Bio::KEGG::REACTION',
            /^ENTRY       R[A-Za-z0-9\._]+$/,
            /^ENTRY       .+ Reaction\s*/
          ],
          genes    = RuleRegexp[ 'Bio::KEGG::GENES',
            /^ENTRY       .+ (CDS|gene|.*RNA|Contig) / ],
          genome   = RuleRegexp[ 'Bio::KEGG::GENOME',
            /^ENTRY       [a-z]+$/ ],

          RuleProc.new('Bio::FANTOM::MaXML::Cluster',
                                'Bio::FANTOM::MaXML::Sequence') do |text|
            if /\<\!DOCTYPE\s+maxml\-(sequences|clusters)\s+SYSTEM/ =~ text
              case $1
              when 'clusters'
                Bio::FANTOM::MaXML::Cluster
              when 'sequences'
                Bio::FANTOM::MaXML::Sequence
              else
                nil #unknown
              end
            else
              nil
            end
          end,

          pdb = RuleRegexp[ 'Bio::PDB',
            /^HEADER    .{40}\d\d\-[A-Z]{3}\-\d\d   [0-9A-Z]{4}/ ],
          het = RuleRegexp[ 'Bio::PDB::ChemicalComponent',
            /^RESIDUE +.+ +\d+\s*$/ ],

          RuleRegexp2[ 'Bio::ClustalW::Report',
            /^CLUSTAL .*\(.*\).*sequence +alignment/,
            /^CLUSTAL FORMAT for T-COFFEE/ ],

          RuleRegexp[ 'Bio::GCG::Msf',
            /^!!(N|A)A_MULTIPLE_ALIGNMENT .+/ ],

          RuleRegexp[ 'Bio::GCG::Seq',
            /^!!(N|A)A_SEQUENCE .+/ ],

          RuleRegexp[ 'Bio::Blast::Report',
            /\<\!DOCTYPE BlastOutput PUBLIC / ],
          wublast  = RuleRegexp[ 'Bio::Blast::WU::Report',
            /^BLAST.? +[\-\.\w]+\-WashU +\[[\-\.\w ]+\]/ ],
          wutblast = RuleRegexp[ 'Bio::Blast::WU::Report_TBlast',
            /^TBLAST.? +[\-\.\w]+\-WashU +\[[\-\.\w ]+\]/ ],
          blast    = RuleRegexp[ 'Bio::Blast::Default::Report',
            /^BLAST.? +[\-\.\w]+ +\[[\-\.\w ]+\]/ ],
          tblast   = RuleRegexp[ 'Bio::Blast::Default::Report_TBlast',
            /^TBLAST.? +[\-\.\w]+ +\[[\-\.\w ]+\]/ ],
          RuleRegexp[ 'Bio::Blast::RPSBlast::Report',
            /^RPS\-BLAST.? +[\-\.\w]+ +\[[\-\.\w ]+\]/ ],

          RuleRegexp[ 'Bio::Blat::Report',
            /^psLayout version \d+/ ],
          RuleRegexp[ 'Bio::Spidey::Report',
            /^\-\-SPIDEY version .+\-\-$/ ],
          RuleRegexp[ 'Bio::HMMER::Report',
            /^HMMER +\d+\./ ],
          RuleRegexp[ 'Bio::Sim4::Report',
            /^seq1 \= .*\, \d+ bp(\r|\r?\n)seq2 \= .*\, \d+ bp(\r|\r?\n)/ ],

          fastq  = RuleRegexp[ 'Bio::Fastq',
            /^\@.+(?:\r|\r?\n)(?:[^\@\+].*(?:\r|\r?\n))+/ ],

          fastaformat = RuleProc.new('Bio::FastaFormat',
                                     'Bio::NBRF',
                                     'Bio::FastaNumericFormat') do |text|
            if /^>.+$/ =~ text
              case text
              when /^>([PF]1|[DR][LC]|N[13]|XX)\;.+/
                Bio::NBRF
              when /^>.+$\s+(^\#.*$\s*)*^\s*\d*\s*[-a-zA-Z_\.\[\]\(\)\*\+\$]+/
                  Bio::FastaFormat
              when /^>.+$\s+^\s*\d+(\s+\d+)*\s*$/
                Bio::FastaNumericFormat
              else
                false
              end
            else
              nil
            end
          end
        ]

        # dependencies
        # NCBI
        genbank.is_prior_to genpept
        # EMBL/UniProt
        embl.is_prior_to sptr
        sptr.is_prior_to prosite
        prosite.is_prior_to transfac
        # KEGG
        #aaindex.is_prior_to litdb
        #litdb.is_prior_to brite
        pathway_module.is_prior_to pathway
        pathway.is_prior_to brite
        brite.is_prior_to orthology
        orthology.is_prior_to drug
        drug.is_prior_to glycan
        glycan.is_prior_to enzyme
        enzyme.is_prior_to compound
        compound.is_prior_to reaction
        reaction.is_prior_to genes
        genes.is_prior_to genome
        # PDB
        pdb.is_prior_to het
        # BLAST
        wublast.is_prior_to wutblast
        wutblast.is_prior_to blast
        blast.is_prior_to tblast
        # Fastq
        BottomRule.is_prior_to(fastq)
        fastq.is_prior_to(fastaformat)
        # FastaFormat
        BottomRule.is_prior_to(fastaformat)

        # for debug
        #debug_first = RuleDebug.new('debug_first')
        #a.add(debug_first)
        #debug_first.is_prior_to(TopRule)

        ## for debug
        #debug_last = RuleDebug.new('debug_last')
        #a.add(debug_last)
        #BottomRule.is_prior_to(debug_last)
        #fastaformat.is_prior_to(debug_last)

        a.rehash
        return a
      end
      
    end #class AutoDetect
  end #class FlatFile
end #module Bio

