
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
        
        #Bio::SQL::Term.create(:name=>synonym, :ontology=> Bio::SQL::Ontology.find_by_name('Annotation Tags')) unless Bio::SQL::Term.exists?(:name =>synonym)
        send :define_method, method_reader do
          #return an array of bioentry_qualifier_values
          begin
            term  = Term.find_or_create_by_name(:name => synonym, :ontology=> Ontology.find_by_name('Annotation Tags'))
            bioentry_qualifier_values = @entry.bioentry_qualifier_values.find_all_by_term_id(term)          
            bioentry_qualifier_values.map{|row| row.value} unless bioentry_qualifier_values.nil?
          rescue Exception => e 
            puts "Reader Error: #{synonym} #{e.message}"
          end
        end
        
        send :define_method, method_writer_operator do |value|
          begin
            term  = Term.find_or_create_by_name(:name => synonym, :ontology=> Ontology.find_by_name('Annotation Tags'))
            datas = @entry.bioentry_qualifier_values.find_all_by_term_id(term.term_id)
            #add an element incrementing the rank or setting the first to 1
            @entry.bioentry_qualifier_values.create(:term_id=>term.term_id, :rank=>datas.empty? ? 1 : datas.last.rank.succ, :value=>value)
          rescue Exception => e 
            puts "WriterOperator= Error: #{synonym} #{e.message}"
          end
        end
        
        send :define_method, method_writer_modder do |value, rank|
          begin
            term  = Term.find_or_create_by_name(:name => synonym, :ontology=> Ontology.find_by_name('Annotation Tags'))
            data = @entry.bioentry_qualifier_values.find_by_term_id_and_rank(term.term_id, rank)
            if data.nil?
              send method_writer_operator, value
            else
              data.value=value
              data.save!
            end
          rescue Exception => e
            puts "WriterModder Error: #{synonym} #{e.message}"
          end
        end
        
      end
      public
      attr_reader :entry
      
      def delete
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
        options.assert_valid_keys(:entry, :biodatabase_id,:biosequence)
        return @entry = options[:entry] unless options[:entry].nil?
        return to_biosql(options[:biosequence], options[:biodatabase_id]) unless options[:biosequence].nil? or options[:biodatabase_id].nil?
      end
      
      def to_biosql(bs,biodatabase_id)
        #Transcaction works greatly!!!
        
        #
        begin
          Bioentry.transaction do           
            @entry = Bioentry.new(:biodatabase_id=>biodatabase_id, :name=>bs.entry_id)
            #            pp "primary"
            self.primary_accession = bs.primary_accession
            #            pp "def"
            self.definition = bs.definition unless bs.definition.nil?
            #            pp "seqver"
            self.sequence_version = bs.sequence_version
            #            pp "divi"
            self.division = bs.division unless bs.division.nil?
            @entry.save!
            #            pp "secacc"
            bs.secondary_accessions.each do |sa|
              #write as qualifier every secondary accession into the array
              self.secondary_accessions = sa
            end
            #to create the sequence entry needs to exists
            #            pp "seq"
            self.seq = bs.seq unless bs.seq.nil?
            #            pp "mol"
            self.molecule_type = bs.molecule_type unless bs.molecule_type.nil?
            #            pp "dc"
            self.data_class = bs.data_class unless bs.data_class.nil?
            #            pp "top"
            self.topology = bs.topology unless bs.topology.nil?
            #            pp "datec"
            self.date_created = bs.date_created unless bs.date_created.nil?
            #            pp "datemod"
            self.date_modified = bs.date_modified unless bs.date_modified.nil?
            #            pp "key"
            bs.keywords.each do |kw|
              #write as qualifier every secondary accessions into the array
              self.keywords = kw
            end
            #FIX: problem settinf texon_name: embl has "Arabidopsis thaliana (thale cress)" but in taxon_name table there isn't this name. I must check if there is a new version of the table
            #pp "spec"        
            self.species = bs.species unless bs.species.nil?
            #            pp "Debug: #{bs.species}"
            #            pp "feat"
            bs.features.each do |feat|
              self.feature=feat
            end
            
            #TODO: add comments and references
            
          end #transaction
          return self
        rescue Exception => e
          pp "to_biosql exception: #{e}"
        end
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
        @entry.taxon.nil? ? "" : @entry.taxon.taxon_scientific_name.name
      end
      alias species organism
      
      def organism=(value)
        taxon_name=TaxonName.find_by_name_and_name_class(value,'scientific name')
        if taxon_name.nil?
          puts "Error value doesn't exists in taxon_name table with scientific name constraint."
        else
          @entry.taxon_id=taxon_name.taxon_id
          @entry.save!
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
        Bio::Features.new(@entry.seqfeatures.collect {|sf|
          self.get_seqfeature(sf)})
      end
      
      def feature=(feat)
        #TODO: fix ontology_id and source_term_id 
        type_term = Term.find_or_create_by_name(:name=>feat.feature, :ontology_id=>1)
        seqfeature = Seqfeature.new(:bioentry=>@entry, :source_term_id=>2, :type_term=>type_term, :rank=>@entry.seqfeatures.count.succ, :display_name=>'')
        seqfeature.save!        
        feat.locations.each do |loc|
          location = Location.new(:seqfeature=>seqfeature, :start_pos=>loc.from, :end_pos=>loc.to, :strand=>loc.strand, :rank=>seqfeature.locations.count.succ)
          location.save!
        end
        feat.each do |qualifier|
          qual_term = Term.find_or_create_by_name(:name=>qualifier.qualifier, :ontology_id=>3)
          qual = SeqfeatureQualifierValue.new(:seqfeature=>seqfeature, :term=>qual_term, :value=>qualifier.value, :rank=>seqfeature.seqfeature_qualifier_values.count.succ)
          qual.save!          
        end
      end
      
      
      def seq
        Bio::Sequence.auto(@entry.biosequence.seq) unless @entry.biosequence.nil?
      end	
      
      def seq=(value)
        #chk which type of alphabet is, NU/NA/nil
        #value could be nil ? I think no.
        if @entry.biosequence.nil?
          @entry.biosequence = Biosequence.new(:seq=>value)
          @entry.biosequence.save!
        else
          @entry.biosequence.seq=value
        end
        
        self.length=value.length
      end
      
      def taxonomy
        tax = []
        taxon = @entry.taxon
        while taxon and taxon.taxon_id != taxon.parent_taxon_id
          tax << taxon.taxon_scientific_name.name
          #Note: I don't like this call very much, correct with a relationship in the ref class.
          taxon = Taxon.find(taxon.parent_taxon_id)
        end
        tax.reverse
      end
      
      def length 
        @entry.biosequence.length
      end
      
      def references
        #return and array of hash, hash has these keys ["title", "dbxref_id", "reference_id", "authors", "crc", "location"]
        #probably would be better to d a class refrence to collect these informations
        @entry.bioentry_references.collect do |ref|
          hash = Hash.new
          hash['authors'] = ref.reference.authors
          hash['title'] = ref.reference.title
          hash['embl_gb_record_number'] = ref.reference.rank
          #about location/journal take a look to hilmar' schema overview. 
          #TODO: solve the problem with specific comment per reference.
          #TODO: get dbxref
          hash['journal'] = ref.reference.location
          hash['xrefs'] = "#{ref.reference.dbxref.dbname}; #{ref.reference.dbxref.accession}."
          Bio::Reference.new(hash)
        end        
      end
      
      def comments
        @entry.comments.map do |comment|
          comment.comment_text
        end
      end
      
      
      def save
        #I should add chks for SQL errors
        @entry.biosequence.save
        @entry.save
      end
      def to_fasta
        #prima erano 2 print in stdout, meglio ritornare una stringa in modo che poi ci si possa fare quello che si vuole
        #print ">" + accession + "\n" 
        #print seq.gsub(Regexp.new(".{1,#{60}}"), "\\0\n")
				">" + accession + "\n" + seq.gsub(Regexp.new(".{1,#{60}}"), "\\0\n")
      end
      
      def to_fasta_reverse_complememt
				">" + accession + "\n" + seq.reverse_complement.gsub(Regexp.new(".{1,#{60}}"), "\\0\n")
      end
      
      
      # converts Bio::SQL::Sequence to Bio::Sequence
      # ---
      # *Arguments*: 
      # *Returns*:: Bio::Sequence object
      #TODO:      def to_biosequence
      #        sequence = Bio::Sequence.new(seq)
      #        sequence.entry_id = entry_id
      #        
      #        sequence.primary_accession = accession
      #        sequence.secondary_accessions = accession
      #        
      #        sequence.molecule_type = natype
      #        sequence.division = division
      #        sequence.topology = circular
      #        
      #        sequence.sequence_version = version
      #        #sequence.date_created = nil #????
      #        sequence.date_modified = date
      #        
      #        sequence.definition = definition
      #        sequence.keywords = keywords
      #        sequence.species = organism
      #        sequence.classification = self.taxonomy.to_s.sub(/\.\z/, '').split(/\s*\;\s*/)
      #        #sequence.organnella = nil # not used
      #        sequence.comments = comment
      #        sequence.references = references
      #        sequence.features = features
      #        return sequence
      #      end
      #
      #			    def load_fasta(entry, biodatabase)
      #				result=nil
      #			#	    if !entry.accession.nil? then
      #				    ##	pp biodatabase
      #					begin 
      #						Bioentry.transaction do 
      #							bioentry=Bioentry.new(:biodatabase=>biodatabase, :name=>entry.accession, :accession=>entry.accession, \
      #							  :description=>entry.definition, :version=>0)
      #						
      #			#				bioentry=Bioentry.new(:biodatabase=>biodatabase, :name=>entry.accession, :accession=>entry.accession, \
      #			#				  :description=>entry.definition, :version=>entry.acc_version.split(/\./).last, :identifier=>entry.gi)
      #					##		pp bioentry
      #							bioentry.save!
      #							result=bioentry
      #							begin
      #								Biosequence.transaction do
      #									bioentry.biosequence = Biosequence.new(:seq=>entry.seq, :version=>0, :length=>entry.seq.length, :alphabet=>'')
      #									bioentry.biosequence.save!
      #								end #Bioseqence.transaction
      #							rescue Exception => exc
      #								puts "Error Biosequence: #{exc.message}"
      #							end #Rescue Biosequence
      #						end #Bioentry.transaction
      #					rescue ActiveRecord::RecordInvalid => e
      #						puts "Error: Transaction Aborted on class #{e.record.class}, table #{e.record.class.table_name} due to:"
      #						e.record.errors.each{|att, msg|
      #							puts "#{att} => #{msg}" 
      #						}
      #					rescue Exception => exc 
      #						puts "Errore Bioentry: #{exc.message}"
      #					end #Resce Bioentry
      #			#	    end #entry chk
      #				return result
      #			    end #load_fasta
      #
      #			    def load_gb(entry, biodatabase)
      #			##	pp biodatabase
      #				result=nil
      #
      #				begin 
      #				Bioentry.transaction do 
      #					bioentry=Bioentry.new(:biodatabase=>biodatabase, :name=>entry.entry_id, :accession=>entry.entry_id, :division=>entry.division, \
      #				  :description=>entry.definition, :version=>entry.version, :identifier=>entry.gi.split(/:/).last.to_i)
      #			##		pp bioentry
      #					bioentry.save!
      #
      #					result=bioentry
      #
      #			#		end #Bioentry.transaction
      #			##debug	pp ["Bioentry", [:name=>entry.entry_id, :accession=>entry.entry_id, :division=>entry.division,
      #			##  :description=>entry.definition, :version=>entry.version, :identifier=>entry.gi.split(/:/).last.to_i]] 
      #
      #			#delete	biodatabase.bioentries << bioentry
      #				#note Alphabet not defined
      #
      #				begin
      #				rank_comment=1
      #				Comment.transaction do 
      #					if !entry.comment.empty? then
      #						bioentry.comment = Comment.new(:comment_text=>entry.comment, :rank=>rank_comment)
      #						bioentry.comment.save!
      #						rank_comment=rank_comment.next
      #					end
      #				end #Comment.transaction
      #				rescue Exception => exc
      #					puts "Error Comment: #{exc.message}"
      #				end #Rescue Command
      #			#debug	pp "Comment"
      #			##debug  	pp ["Comment", [:comment_text=>entry.comment]] if !entry.comment.empty?
      #				begin
      #				Biosequence.transaction do
      #					bioentry.biosequence = Biosequence.new(:seq=>entry.seq, :version=>0, :length=>entry.seq.length, :alphabet=>'')
      #					bioentry.biosequence.save!
      #				end #Bioseqence.transaction
      #				rescue Exception => exc
      #					puts "Error Biosequence: #{exc.message}"
      #				end #Rescue Biosequence
      #			#debug	pp "Biosequence"
      #			##debug  	pp ["Biosequence", :seq=>entry.seq, :version=>0, :length=>entry.seq.length, :alphabet=>'']
      #				begin
      #				rank_seqfeature=1
      #				Seqfeature.transaction do 
      #					entry.features.each do |feature|
      #					#note Rank default to ZERO, display_name String empty
      #					#note Chek if exists term name
      ##delete puts "Feature #{feature.inspect}"			
      ##delete puts "FeatureFeature #{feature.feature.inspect}"		
      #
      #						type_term = Term.exists?(:name=>feature.feature) ? Term.find_by_name(feature.feature) : Term.create!(:name=>feature.feature, :ontology_id=>1)
      #			#			seqfeature = Seqfeature.new(:bioentry=>bioentry, :source_term_id=>2, :typeterm=>Term.find_by_name(feature.feature), :rank=>rank_seqfeature, :display_name=>'')
      ##delete puts "Type Term #{type_term.inspect}"			
      #						seqfeature = Seqfeature.new(:bioentry=>bioentry, :source_term_id=>2, :type_term=>type_term, :rank=>rank_seqfeature, :display_name=>'')
      ##delete puts "Seqfeature #{seqfeature.inspect}"						
      #						seqfeature.save!
      #			##debug		pp ["Seqfeature", [:source_term_id=>2, :typeterm=>Term.find_by_name(feature.feature), :rank=>0, :display_name=>'']]
      #						begin
      #						Location.transaction do 	
      #							feature.locations.each do |loc|
      #								location = Location.new(:seqfeature=>seqfeature, :start_pos=>loc.from, :end_pos=>loc.to, :strand=>loc.strand)
      #								location.save!
      #			##debug			pp ["Location",[:start_pos=>loc.from, :end_pos=>loc.to, :strand=>loc.strand]]
      #							end #locations
      #						end #Location.transaction
      #						rescue Exception => exc
      #							puts "Error Location: #{exc.message}"
      #						end #Rescue Location
      #			#debug			pp "Locations"
      #			#delete			bioentry.seqfeatures << seqfeature
      ##delete if nil
      #						begin
      #						rank_seqfeaturequalifiervalue=0
      #						rank_qual_qualifier=""
      #						SeqfeatureQualifierValue.transaction do
      #							feature.each do |qual|
      #	
      #							#gestisce il livello dei qualificatori...
      #								if (rank_qual_qualifier==qual.qualifier) then 
      #									rank_seqfeaturequalifiervalue=rank_seqfeaturequalifiervalue.next
      #								else
      #									rank_seqfeaturequalifiervalue=1
      #									rank_qual_qualifier=qual.qualifier
      #								end
      #
      #			##debug			pp ["SeqfeatureQualifierValue",  qual.qualifier, [ :term=>Term.find_by_name(qual.qualifier), :value=>qual.value]]
      #								term = Term.exists?(:name=>qual.qualifier) ? Term.find_by_name(qual.qualifier) : Term.create!(:name=>qual.qualifier, :ontology_id=>3)
      #
      #			#				qual = SeqfeatureQualifierValue.new(:seqfeature=>seqfeature, :term=>Term.find_by_name(qual.qualifier), :value=>qual.value, :rank=>rank_seqfeaturequalifiervalue)
      #								qual = SeqfeatureQualifierValue.new(:seqfeature=>seqfeature, :term=>term, :value=>qual.value, :rank=>rank_seqfeaturequalifiervalue)
      #								qual.save!
      #							end #qualifiers
      #						end #SeqfeatureQualifierValue.transaction
      #						rescue Exception => exc
      #							puts "Error SeqfeatureQualifierValue: #{exc.message}"
      #						end #Rescue SeqfeatureQualifierValue
      ###delete end #debug if nil
      #			#debug			pp "SeqfeatureQualifierValue"
      #					rank_seqfeature=rank_seqfeature.next
      #					end #features
      #				end #Seqfeature.transaction
      #				rescue Exception => exc
      #					puts "Error Seqfeature: #{exc.message}"
      #				end #Rescue Seqfeature
      #
      #				end #Bioentry.transaction
      #				rescue ActiveRecord::RecordInvalid => e
      #					puts "Error: Transaction Aborted on class #{e.record.class}, table #{e.record.class.table_name} due to:"
      #					e.record.errors.each{|att, msg|
      #						puts "#{att} => #{msg}" 
      #					}
      #				rescue Exception => exc 
      #					puts "Errore Bioentry: #{exc.message}"
      #				end #Resce Bioentry
      #				return result
      #			    end #load_gb
      #			    
      #			    def load_embl(entry, biodatabase)
      #			    
      #			#	puts biodatabase
      #				result=nil
      #
      #				begin 
      #				Bioentry.transaction do 
      #					bioentry=Bioentry.new(:biodatabase=>biodatabase, :name=>entry.entry_id, :accession=>entry.entry_id, :division=>entry.division, \
      #				  :description=>entry.definition, :version=>entry.version, :identifier=>entry.entry_id)
      #			#		puts bioentry
      #					bioentry.save!
      #					result=bioentry
      #
      #			#		end #Bioentry.transaction
      #			#	puts ["Bioentry", [:name=>entry.entry_id, :accession=>entry.entry_id, :division=>entry.division,\
      #			#  :description=>entry.definition, :version=>entry.version, :identifier=>entry.entry_id]] 
      #
      #			#delete	biodatabase.bioentries << bioentry
      #				#note Alphabet not defined
      #				begin
      #				rank_comment=1
      #				#qui potrebbero essercene di più
      #				Comment.transaction do 
      #					if !entry.cc.empty?
      #						bioentry.comment = Comment.new(:comment_text=>entry.cc, :rank=>rank_comment)
      #						bioentry.comment.save!
      #						rank_comment=rank_comment.next
      #					end
      #				end #Comment.transaction
      #				rescue Exception => exc
      #					puts "Error Comment: #{exc.message}"
      #				end #Rescue Command
      #			#	puts "Comment"
      #			 # 	puts ["Comment", [:comment_text=>entry.cc]] if !entry.cc.empty?
      #				begin
      #				Biosequence.transaction do
      #					bioentry.biosequence = Biosequence.new(:seq=>entry.seq, :version=>0, :length=>entry.seq.length, :alphabet=>entry.molecule_type)
      #					bioentry.biosequence.save!
      #				end #Bioseqence.transaction
      #				rescue Exception => exc
      #					puts "Error Biosequence: #{exc.message}"
      #				end #Rescue Biosequence
      #			#debug	pp "Biosequence"
      #			##debug  	pp ["Biosequence", :seq=>entry.seq, :version=>0, :length=>entry.seq.length, :alphabet=>'']
      #				begin
      #				rank_seqfeature=1
      #				Seqfeature.transaction do 
      #					entry.features.each do |feature|
      #					#note Rank default to ZERO, display_name String empty
      #					#note Chek if exists term name
      #						type_term = Term.exists?(:name=>feature.feature) ? Term.find_by_name(feature.feature) : Term.create!(:name=>feature.feature, :ontology_id=>1)
      #			#			seqfeature = Seqfeature.new(:bioentry=>bioentry, :source_term_id=>2, :typeterm=>Term.find_by_name(feature.feature), :rank=>rank_seqfeature, :display_name=>'')
      #						seqfeature = Seqfeature.new(:bioentry=>bioentry, :source_term_id=>2, :type_term=>type_term, :rank=>rank_seqfeature, :display_name=>'')
      #						seqfeature.save!
      #			##debug		pp ["Seqfeature", [:source_term_id=>2, :typeterm=>Term.find_by_name(feature.feature), :rank=>0, :display_name=>'']]
      #						begin
      #						Location.transaction do 	
      #							feature.locations.each do |loc|
      #								location = Location.new(:seqfeature=>seqfeature, :start_pos=>loc.from, :end_pos=>loc.to, :strand=>loc.strand)
      #								location.save!
      #			##debug			pp ["Location",[:start_pos=>loc.from, :end_pos=>loc.to, :strand=>loc.strand]]
      #							end #locations
      #						end #Location.transaction
      #						rescue Exception => exc
      #							puts "Error Location: #{exc.message}"
      #						end #Rescue Location
      #			#debug			pp "Locations"
      #			#delete			bioentry.seqfeatures << seqfeature
      #						begin
      #						rank_seqfeaturequalifiervalue=0
      #						rank_qual_qualifier=""
      #						SeqfeatureQualifierValue.transaction do
      #							feature.each do |qual|
      #							#gestisce il livello dei qualificatori...
      #								if (rank_qual_qualifier==qual.qualifier) then 
      #									rank_seqfeaturequalifiervalue=rank_seqfeaturequalifiervalue.next
      #								else
      #									rank_seqfeaturequalifiervalue=1
      #									rank_qual_qualifier=qual.qualifier
      #								end
      #
      #			##debug			pp ["SeqfeatureQualifierValue",  qual.qualifier, [ :term=>Term.find_by_name(qual.qualifier), :value=>qual.value]]
      #								term = Term.exists?(:name=>qual.qualifier) ? Term.find_by_name(qual.qualifier) : Term.create!(:name=>qual.qualifier, :ontology_id=>3)
      #			#				qual = SeqfeatureQualifierValue.new(:seqfeature=>seqfeature, :term=>Term.find_by_name(qual.qualifier), :value=>qual.value, :rank=>rank_seqfeaturequalifiervalue)
      #								qual = SeqfeatureQualifierValue.new(:seqfeature=>seqfeature, :term=>term, :value=>qual.value, :rank=>rank_seqfeaturequalifiervalue)
      #
      #								qual.save!
      #							end #qualifiers
      #						end #SeqfeatureQualifierValue.transaction
      #						rescue Exception => exc
      #							puts "Error SeqfeatureQualifierValue: #{exc.message}"
      #						end #Rescue SeqfeatureQualifierValue
      #			#debug			pp "SeqfeatureQualifierValue"
      #					rank_seqfeature=rank_seqfeature.next
      #					end #features
      #				end #Seqfeature.transaction
      #				rescue Exception => exc
      #					puts "Error Seqfeature: #{exc.message}"
      #				end #Rescue Seqfeature
      #				end #Bioentry.transaction
      #				rescue ActiveRecord::RecordInvalid => e
      #					puts "Error: Transaction Aborted on class #{e.record.class}, table #{e.record.class.table_name} due to:"
      #					e.record.errors.each{|att, msg|
      #						puts "#{att} => #{msg}" 
      #					}
      #				rescue Exception => exc 
      #					puts "Errore Bioentry: #{exc.message}"
      #				end #Resce Bioentry
      #				
      #				return result
      #			    end #load_embl
      
      
      def to_biosequence
        Bio::Sequence.adapter(self, Bio::Sequence::Adapter::BioSQL)
      end
    end #Sequence
    
    #gb=Bio::FlatcFile.open(Bio::GenBank, "/Development/Projects/Cocco/Data/Riferimenti/Genomi/NC_003098_Cocco_R6.gb")
    #db=Biodatabase.find_by_name('fake')
    #gb.each_entry {|entry| Sequence.new(:entry=>entry, :biodatabase=>db)}
    
    
  end #SQL
end #Bio

#TODO create tests for sequence object, roundtrip of informations

if __FILE__ == $0
  
  require 'bio'
  require 'bio/io/sql'
  require 'pp'
  
  #  connection = Bio::SQL.establish_connection('bio/io/biosql/config/database.yml','development')
  connection = Bio::SQL.establish_connection({'development'=>{'database'=>"biorails_development", 'adapter'=>"postgresql", 'username'=>"rails", 'password'=>nil}},'development') 
  databases = Bio::SQL.list_databases
  
  #  parser = Bio::FlatFile.auto('/home/febo/Desktop/aj224122.embl')
  parser = Bio::FlatFile.auto('/home/febo/Desktop/aj224122.gb')
  #parser = Bio::FlatFile.auto('/home/febo/Desktop/aj224122.fasta')
  
  parser.each do |entry|
    biosequence = entry.to_biosequence
    result = Bio::SQL::Sequence.new(:biosequence=>biosequence,:biodatabase_id=>databases.first[:id]) unless Bio::SQL.exists_accession(biosequence.primary_accession) 
    
    if result.nil?
      pp "The sequence is already present into the biosql database"
    else
      #      pp "Sequence"
      puts result.to_biosequence.output(:genbank) #:embl
      result.delete
    end   
  end
  #NOTE: ho sistemato le features e le locations, mancano le references e i comments. poi credo che il tutto sia a posto.
  
  
  if false
    sqlseq = Bio::SQL.fetch_accession('AJ224122')
    #only output tests.
    pp "Connection"
    pp connection
    pp "Seq in dbs"
    pp Bio::SQL.list_entries
    #; NC_003098
    
    
    #pp sqlseq
    pp sqlseq.entry.inspect
    pp "sequence"
    #pp Bio::Sequence.auto(sqlseq.seq)
    pp "entry_id"
    pp sqlseq.entry_id
    
    pp "primary"
    pp sqlseq.accession
    pp "secondary_accessions"
    pp sqlseq.secondary_accessions
    pp "molecule type"
    pp sqlseq.molecule_type
    pp "data_class"
    pp sqlseq.data_class
    pp "division"
    pp sqlseq.division
    # NOTE : Topology is not represented in biosql?
    pp "topology"
    #TODO:  CIRCULAR   this at present maps to bioentry_qualifier_value, though there are plans to make it a column in table biosequence.
    pp sqlseq.topology
    pp "version"
    pp sqlseq.version
    #sequence.date_created = nil #????
    pp "date modified"
    pp sqlseq.date_modified
    pp "definition"
    pp sqlseq.definition
    pp "keywords"
    pp sqlseq.keywords
    pp "species"
    pp sqlseq.organism
    #sequence.classification = self.taxonomy.to_s.sub(/\.\z/, '').split(/\s*\;\s*/)"
    pp "classification"
    pp sqlseq.taxonomy
    #sequence.organnella = nil # not used
    pp "comments"
    pp sqlseq.comments
    pp "references"
    pp sqlseq.references
    pp "features"
    pp sqlseq.features
    puts sqlseq.to_biosequence.output(:embl)
  end
  ##
end
