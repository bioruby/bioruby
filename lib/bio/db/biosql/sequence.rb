
#TODO save on db reading from a genbank or embl object
module Bio
  class SQL



    class Sequence
      private
      #      example
      #      bioentry_qualifier_anchor :molecule_type, :synonym=>'mol_type'
      #      this function creates other 3 functions, molecule_type, molecule_type=, molecule_type_update
      #molecule_type => return an array of strings, where each string is the value associated with the qualifier, ordered by rank.
      #molecule_type=value add a bioentry_qualifier value to the table
      #molecule_type_update(value, rank) update an entry of the table with an existing rank
      #the method inferr the qualifier term from the name of the first symbol, or you can specify a synonym to use

      #creating an object with to_biosql is transaction safe.

      #TODO: implement setting for more than a qualifier-vale.
      def self.bioentry_qualifier_anchor(sym, *args)
        options = args.first || Hash.new
        #options.assert_valid_keys(:rank,:synonym,:multi)
        method_reader = sym.to_s.to_sym
        method_writer_operator = (sym.to_s+"=").to_sym
        method_writer_modder = (sym.to_s+"_update").to_sym
        synonym = options[:synonym].nil? ? sym.to_s : options[:synonym]

        #DELETE        #Bio::SQL::Term.create(:name=>synonym, :ontology=> Bio::SQL::Ontology.find_by_name('Annotation Tags')) unless Bio::SQL::Term.exists?(:name =>synonym)
        send :define_method, method_reader do
          #return an array of bioentry_qualifier_values
          begin
            #DELETE            ontology_annotation_tags = Ontology.find_or_create({:name=>'Annotation Tags'})
            term  = Term.first(:conditions=>["name = ?",synonym]) || Term.create({:name => synonym, :ontology=> Ontology.first(:conditions=>["name = ?",'Annotation Tags'])})
            bioentry_qualifier_values = @entry.bioentry_qualifier_values.all(:conditions=>["term_id = ?",term.term_id])
            data = bioentry_qualifier_values.map{|row| row.value} unless bioentry_qualifier_values.nil?
            begin
              # this block try to check if the data retrived is a
              # Date or not and change it according to GenBank/EMBL format
              # in that case return a string
              # otherwise the []
              Date.parse(data.to_s).strftime("%d-%b-%Y").upcase
            rescue ArgumentError, TypeError, NoMethodError, NameError
              data
            end
          rescue Exception => e
            puts "Reader Error: #{synonym} #{e.message}"
          end
        end

        send :define_method, method_writer_operator do |value|
          begin
            #DELETE            ontology_annotation_tags = Ontology.find_or_create({:name=>'Annotation Tags'})
            term  = Term.first(:conditions=>["name = ?",synonym]) || Term.create({:name => synonym, :ontology=> Ontology.first(:conditions=>["name = ?",'Annotation Tags'])})
            datas = @entry.bioentry_qualifier_values.all(:conditions=>["term_id = ?",term.term_id])
            #add an element incrementing the rank or setting the first to 1
            be_qu_va=@entry.bioentry_qualifier_values.build({:term=>term, :rank=>(datas.empty? ? 1 : datas.last.rank.succ), :value=>value})
            be_qu_va.save
          rescue Exception => e
            puts "WriterOperator= Error: #{synonym} #{e.message}"
          end
        end

        send :define_method, method_writer_modder do |value, rank|
          begin
            #DELETE            ontology_annotation_tags = Ontology.find_or_create({:name=>'Annotation Tags'})
            term  = Term.first(:conditions=>["name = ?",synonym]) || Term.create({:name => synonym, :ontology=> Ontology.first(:conditions=>["name = ?",'Annotation Tags'])})
            data = @entry.bioentry_qualifier_values.all(:term_id=>term.term_id, :rank=>rank)
            if data.nil?
              send method_writer_operator, value
            else
              data.value=value
              data.save
            end
          rescue Exception => e
            puts "WriterModder Error: #{synonym} #{e.message}"
          end
        end

      end

      public
      attr_reader :entry

      def delete
        #TODO: check is references connected to this bioentry are leaf or not.
        #actually I think it should be more sofisticated, check if there are
        #other bioentries connected to references; if not delete 'em
        @entry.references.each { |ref| ref.delete if ref.bioentries.size==1}
        @entry.destroy
      end

      def get_seqfeature(sf)

        #in seqfeature BioSQL class
        locations_str = sf.locations.map{|loc| loc.to_s}.join(',')
        #pp sf.locations.inspect
        locations_str = "join(#{locations_str})" if sf.locations.count>1
        Bio::Feature.new(sf.type_term.name, locations_str,sf.seqfeature_qualifier_values.collect{|sfqv| Bio::Feature::Qualifier.new(sfqv.term.name,sfqv.value)})
      end

      def length=(len)
        @entry.biosequence.length=len
      end

      def initialize(options={})
        #options.assert_valid_keys(:entry, :biodatabase,:biosequence)
        return @entry = options[:entry] unless options[:entry].nil?

        return to_biosql(options[:biosequence], options[:biodatabase]) unless options[:biosequence].nil? or options[:biodatabase].nil?

      end

      def to_biosql(bs,biodatabase)
        #DELETE        #Transcaction works greatly!!!
        begin
          #DELETE          Bioentry.transaction do
          @entry = biodatabase.bioentries.build({:name=>bs.entry_id})

          puts "primary" if $DEBUG
          self.primary_accession = bs.primary_accession

          puts "def" if $DEBUG
          self.definition = bs.definition unless bs.definition.nil?

          puts "seqver" if $DEBUG
          self.sequence_version = bs.sequence_version || 0

          puts "divi" if $DEBUG
          self.division = bs.division unless bs.division.nil?

          puts "identifier" if $DEBUG
          self.identifier = bs.other_seqids.collect{|dblink| "#{dblink.database}:#{dblink.id}"}.join(';') unless bs.other_seqids.nil?
          @entry.save
          puts "secacc" if $DEBUG

          bs.secondary_accessions.each do |sa|
            puts "#{sa}" if $DEBUG
            #write as qualifier every secondary accession into the array
            self.secondary_accessions = sa
          end unless bs.secondary_accessions.nil?


          #to create the sequence entry needs to exists
          puts "seq" if $DEBUG
          puts bs.seq if $DEBUG
          self.seq = bs.seq unless bs.seq.nil?
          puts "mol" if $DEBUG

          self.molecule_type = bs.molecule_type unless bs.molecule_type.nil?
          puts "dc" if $DEBUG

          self.data_class = bs.data_class unless bs.data_class.nil?
          puts "top" if $DEBUG
          self.topology = bs.topology unless bs.topology.nil?
          puts "datec" if $DEBUG
          self.date_created = bs.date_created unless bs.date_created.nil?
          puts "datemod" if $DEBUG
          self.date_modified = bs.date_modified unless bs.date_modified.nil?
          puts "key" if $DEBUG

          bs.keywords.each do |kw|
            #write as qualifier every secondary accessions into the array
            self.keywords = kw
          end unless bs.keywords.nil?

          puts "spec" if $DEBUG
          #self.species = bs.species unless bs.species.nil?
          self.species = bs.species unless bs.species.empty?
          puts "Debug: #{bs.species}" if $DEBUG
          puts "Debug: feat..start" if $DEBUG

          bs.features.each do |feat|
            self.feature=feat
          end unless bs.features.nil?

          puts "Debug: feat...end" if $DEBUG
          bs.references.each do |reference|
            self.reference=reference
          end unless bs.references.nil?

          bs.comments.each do |comment|
            self.comment=comment
          end unless bs.comments.nil?

          #DELETE          end #transaction
          return self
        rescue Exception => e
          puts "to_biosql exception: #{e}"
          puts $!
        end #rescue
      end #to_biosql


      def name
        @entry.name
      end
      alias entry_id name

      def name=(value)
        @entry.name=value
      end
      alias entry_id= name=

      def primary_accession
        @entry.accession
      end

      def primary_accession=(value)
        @entry.accession=value
      end

      #TODO      def secondary_accession
      #        @entry.bioentry_qualifier_values
      #      end

      def organism
        @entry.taxon.nil? ? "" : "#{@entry.taxon.taxon_scientific_name.name}"+ (@entry.taxon.taxon_genbank_common_name ? "(#{@entry.taxon.taxon_genbank_common_name.name})" : '')
      end
      alias species organism

      def organism=(value)
        #FIX there is a shortcut
        taxon_name=TaxonName.first(:conditions=>["name = ? and name_class = ?",value.gsub(/\s+\(.+\)/,''),'scientific name'])
        if taxon_name.nil?
          puts "Error value doesn't exists in taxon_name table with scientific name constraint."
        else
          @entry.taxon_id=taxon_name.taxon_id
          @entry.save
        end
      end
      alias species= organism=

      def database
        @entry.biodatabase.name
      end

      def database_desc
        @entry.biodatabase.description
      end

      def version
        @entry.version
      end
      alias sequence_version version

      def version=(value)
        @entry.version=value
      end
      alias sequence_version= version=

      def division
        @entry.division
      end

      def division=(value)
        @entry.division=value
      end

      def description
        @entry.description
      end
      alias definition description

      def description=(value)
        @entry.description=value
      end
      alias definition= description=

      def identifier
        @entry.identifier
      end
      alias other_seqids identifier

      def identifier=(value)
        @entry.identifier=value
      end

      bioentry_qualifier_anchor :data_class
      bioentry_qualifier_anchor :molecule_type, :synonym=>'mol_type'
      bioentry_qualifier_anchor :topology
      bioentry_qualifier_anchor :date_created
      bioentry_qualifier_anchor :date_modified, :synonym=>'date_changed'
      bioentry_qualifier_anchor :keywords, :synonym=>'keyword'
      bioentry_qualifier_anchor :secondary_accessions, :synonym=>'secondary_accession'

      def features
        @entry.seqfeatures.collect do |sf|
          self.get_seqfeature(sf)
        end
      end

      def feature=(feat)
        #ToDo: avoid Ontology find here, probably more efficient create class variables
        #DELETE        type_term_ontology = Ontology.find_or_create({:name=>'SeqFeature Keys'})
        puts "feature:type_term = #{feat.feature}" if $DEBUG
        type_term = Term.first(:conditions=>["name = ?", feat.feature]) || Term.create({:name=>feat.feature, :ontology=>Ontology.first(:conditions=>["name = ?",'SeqFeature Keys'])})
        #DELETE        source_term_ontology = Ontology.find_or_create({:name=>'SeqFeature Sources'})
        puts "feature:source_term" if $DEBUG
        source_term = Term.first(:conditions=>["name = ?",'EMBLGenBankSwit'])
        puts "feature:seqfeature" if $DEBUG
        seqfeature = @entry.seqfeatures.build({:source_term=>source_term, :type_term=>type_term, :rank=>@entry.seqfeatures.count.succ, :display_name=>''})
        seqfeature.save
        puts "feature:location" if $DEBUG
        feat.locations.each do |loc|
          location = seqfeature.locations.build({:seqfeature=>seqfeature, :start_pos=>loc.from, :end_pos=>loc.to, :strand=>loc.strand, :rank=>seqfeature.locations.count.succ})
          location.save
        end

        #DELETE        qual_term_ontology = Ontology.find_or_create({:name=>'Annotation Tags'})

        puts "feature:qualifier" if $DEBUG
        feat.each do |qualifier|
          #DELETE          qual_term = Term.find_or_create({:name=>qualifier.qualifier}, {:ontology=>qual_term_ontology})
          qual_term = Term.first(:conditions=>["name = ?", qualifier.qualifier]) || Term.create({:name=>qualifier.qualifier, :ontology=>Ontology.first(:conditions=>["name = ?", 'Annotation Tags'])})
          qual = seqfeature.seqfeature_qualifier_values.build({:seqfeature=>seqfeature, :term=>qual_term, :value=>qualifier.value.to_s, :rank=>seqfeature.seqfeature_qualifier_values.count.succ})
          qual.save

        end
      end

      #return the seqfeature mapped from BioSQL with a type_term like 'CDS'
      def cdsfeatures
        @entry.cdsfeatures
      end

      # Returns the sequence.
      # Returns a Bio::Sequence::Generic object.

      def seq
        s = @entry.biosequence
        Bio::Sequence::Generic.new(s ? s.seq : '')
      end

      def seq=(value)
        #TODO: revise this piece of code.
        #chk which type of alphabet is, NU/NA/nil
        if @entry.biosequence.nil?
          #DELETE          puts "intoseq1"
          @entry.biosequence = Biosequence.new(:seq=>value)
          #          biosequence = @entry.biosequence.build({:seq=>value})
          @entry.biosequence.save
          #          biosequence.save
        else
          @entry.biosequence.seq=value
        end
        self.length=value.length
        #DELETE        #@entry.biosequence.length=value.length
        #DELETE        #break
        @entry.save
      end

      #report parents and exclude info with "no rank". Now I report rank == class but ... Question ? Have to be reported taxonomy with rank=="class"?
      def taxonomy
        tax = []
        taxon = Taxon.first(:conditions=>["taxon_id = ?",@entry.taxon.parent_taxon_id])
        while taxon and taxon.taxon_id != taxon.parent_taxon_id and taxon.node_rank!='no rank'
          tax << taxon.taxon_scientific_name.name if taxon.node_rank!='class'
          #Note: I don't like this call very much, correct with a relationship in the ref class.
          taxon = Taxon.first(:conditions=>["taxon_id = ?",taxon.parent_taxon_id])
        end
        tax.reverse
      end

      def length
        @entry.biosequence.length
      end

      def references
        #return and array of hash, hash has these keys ["title", "dbxref_id", "reference_id", "authors", "crc", "location"]
        #probably would be better to d a class refrence to collect these informations
        @entry.bioentry_references.collect do |bio_ref|
          hash = Hash.new
          hash['authors'] = bio_ref.reference.authors.gsub(/\.\s/, "\.\s\|").split(/\|/)

          hash['sequence_position'] = "#{bio_ref.start_pos}-#{bio_ref.end_pos}" if (bio_ref.start_pos and bio_ref.end_pos)
          hash['title'] = bio_ref.reference.title
          hash['embl_gb_record_number'] = bio_ref.rank
          #TODO: solve the problem with specific comment per reference.
          #TODO: get dbxref
          #take a look when location is build up in def reference=(value)

          bio_ref.reference.location.split('|').each do |element|
            key,value=element.split('=')
            hash[key]=value
          end unless bio_ref.reference.location.nil?

          hash['xrefs'] = bio_ref.reference.dbxref ? "#{bio_ref.reference.dbxref.dbname}; #{bio_ref.reference.dbxref.accession}." : ''
          Bio::Reference.new(hash)
        end
      end

      def comments
        @entry.comments.map do |comment|
          comment.comment_text
        end
      end

      def reference=(value)       
        locations=Array.new
        locations << "journal=#{value.journal}" unless value.journal.empty?
        locations << "volume=#{value.volume}" unless value.volume.empty?
        locations << "issue=#{value.issue}" unless value.issue.empty?
        locations << "pages=#{value.pages}" unless value.pages.empty?
        locations << "year=#{value.year}" unless value.year.empty?
        locations << "pubmed=#{value.pubmed}" unless value.pubmed.empty?
        locations << "medline=#{value.medline}" unless value.medline.empty?
        locations << "doi=#{value.doi}" unless value.doi.nil?
        locations << "abstract=#{value.abstract}" unless value.abstract.empty?
        locations << "url=#{value.url}" unless value.url.nil?
        locations << "mesh=#{value.mesh}" unless value.mesh.empty?
        locations << "affiliations=#{value.affiliations}" unless value.affiliations.empty?
        locations << "comments=#{value.comments.join('~')}"unless value.comments.nil?
        start_pos, end_pos = value.sequence_position ? value.sequence_position.gsub(/\s*/,'').split('-') : [nil,nil]
        reference= Reference.first(:conditions=>["title = ?",value.title]) || Reference.create({:title=>value.title,:authors=>value.authors.join(' '), :location=>locations.join('|')})
        bio_reference=@entry.bioentry_references.build({:reference=>reference,:rank=>value.embl_gb_record_number, :start_pos=>start_pos, :end_pos=>end_pos})
        bio_reference.save
      end

      def comment=(value)
        #DELETE        comment=Comment.new({:bioentry=>@entry, :comment_text=>value, :rank=>@entry.comments.count.succ})
        comment = @entry.comments.build({:comment_text=>value, :rank=>@entry.comments.count.succ})
        comment.save
      end

      def save
        #I should add chks for SQL errors
        @entry.biosequence.save
        @entry.save
      end
      def to_fasta
        ">" + accession + "\n" + seq.gsub(Regexp.new(".{1,#{60}}"), "\\0\n")
      end

      def to_fasta_reverse_complememt
        ">" + accession + "\n" + seq.reverse_complement.gsub(Regexp.new(".{1,#{60}}"), "\\0\n")
      end

      def to_biosequence
        Bio::Sequence.adapter(self,Bio::Sequence::Adapter::BioSQL)
      end
    end #Sequence
  end #SQL
end #Bio
