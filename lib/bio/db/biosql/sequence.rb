
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
	    ontology_annotation_tags = Ontology.find_or_create_by_name('Annotation Tags')
            term  = Term.find_or_create_by_name(:name => synonym, :ontology=> ontology_annotation_tags)
            bioentry_qualifier_values = @entry.bioentry_qualifier_values.find_all_by_term_id(term)          
            bioentry_qualifier_values.map{|row| row.value} unless bioentry_qualifier_values.nil?
          rescue Exception => e 
            puts "Reader Error: #{synonym} #{e.message}"
          end
        end
        
        send :define_method, method_writer_operator do |value|
          begin
	    ontology_annotation_tags = Ontology.find_or_create_by_name('Annotation Tags')
            term  = Term.find_or_create_by_name(:name => synonym, :ontology=> ontology_annotation_tags)
            datas = @entry.bioentry_qualifier_values.find_all_by_term_id(term.term_id)
            #add an element incrementing the rank or setting the first to 1
            @entry.bioentry_qualifier_values.create(:term_id=>term.term_id, :rank=>datas.empty? ? 1 : datas.last.rank.succ, :value=>value)
          rescue Exception => e 
            puts "WriterOperator= Error: #{synonym} #{e.message}"
          end
        end
        
        send :define_method, method_writer_modder do |value, rank|
          begin
	    ontology_annotation_tags = Ontology.find_or_create_by_name('Annotation Tags')
            term  = Term.find_or_create_by_name(:name => synonym, :ontology=> ontology_annotation_tags)
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

                        puts "primary" if $DEBUG
            self.primary_accession = bs.primary_accession

                        puts "def" if $DEBUG
            self.definition = bs.definition unless bs.definition.nil?

                        puts "seqver" if $DEBUG
            self.sequence_version = bs.sequence_version || 0

                        puts "divi" if $DEBUG
            self.division = bs.division unless bs.division.nil?

            @entry.save!
                        puts "secacc" if $DEBUG
            
            bs.secondary_accessions.each do |sa|
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
            #FIX: problem settinf taxon_name: embl has "Arabidopsis thaliana (thale cress)" but in taxon_name table there isn't this name. I must check if there is a new version of the table
            puts "spec" if $DEBUG
            self.species = bs.species unless bs.species.nil?
                        puts "Debug: #{bs.species}" if $DEBUG
                        puts "Debug: feat..start" if $DEBUG
            
            bs.features.each do |feat|
              self.feature=feat
            end unless bs.features.nil?
			puts "Debug: feat...end" if $DEBUG
            
            #TODO: add comments and references
	    bs.references.each do |reference|
		 #   puts reference.inspect
              self.reference=reference
	    end unless bs.references.nil?
            
            bs.comments.each do |comment|
            	self.comment=comment
            end unless bs.comments.nil?
            
          end #transaction
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
        taxon_name=TaxonName.find_by_name_and_name_class(value.gsub(/\s+\(.+\)/,''),'scientific name')
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
        @entry.seqfeatures.collect {|sf|
          self.get_seqfeature(sf)}
      end
      
      def feature=(feat)
	      #ToDo: avoid Ontology find here, probably more efficient create class variables
	type_term_ontology = Ontology.find_or_create_by_name('SeqFeature Keys')
        type_term = Term.find_or_create_by_name(:name=>feat.feature, :ontology=>type_term_ontology)
	source_term_ontology = Ontology.find_or_create_by_name('SeqFeature Sources')
	source_term = Term.find_or_create_by_name(:name=>'EMBLGenBankSwit',:ontology=>source_term_ontology)
        seqfeature = Seqfeature.create(:bioentry=>@entry, :source_term=>source_term, :type_term=>type_term, :rank=>@entry.seqfeatures.count.succ, :display_name=>'')
        #seqfeature.save!       
        feat.locations.each do |loc|
          location = Location.new(:seqfeature=>seqfeature, :start_pos=>loc.from, :end_pos=>loc.to, :strand=>loc.strand, :rank=>seqfeature.locations.count.succ)
          location.save!
        end
	qual_term_ontology = Ontology.find_or_create_by_name('Annotation Tags')
        feat.each do |qualifier|
          qual_term = Term.find_or_create_by_name(:name=>qualifier.qualifier, :ontology=>qual_term_ontology)
          qual = SeqfeatureQualifierValue.new(:seqfeature=>seqfeature, :term=>qual_term, :value=>qualifier.value.to_s, :rank=>seqfeature.seqfeature_qualifier_values.count.succ)
          qual.save!          
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

        #chk which type of alphabet is, NU/NA/nil
        if @entry.biosequence.nil?
#          puts "intoseq1"
          @entry.biosequence = Biosequence.new(:seq=>value)
	  @entry.biosequence.save!

        else
          @entry.biosequence.seq=value
        end
        self.length=value.length
        #@entry.biosequence.length=value.length
        #break
        @entry.save!
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
	      reference=Reference.find_or_create_by_title(:title=>value.title, :authors=>value.authors.join(' '), :location=>locations.join('|'))
	      
	      bio_reference=BioentryReference.new(:bioentry=>@entry,:reference=>reference,:rank=>value.embl_gb_record_number, :start_pos=>start_pos, :end_pos=>end_pos)
	      bio_reference.save!
      end 
      
      def comment=(value)
      		comment=Comment.new(:bioentry=>@entry, :comment_text=>value, :rank=>@entry.comments.count.succ)
      		comment.save!
      end
      
      def save
        #I should add chks for SQL errors
        @entry.biosequence.save!
        @entry.save!
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
      
      
      
      def to_biosequence
	 Bio::Sequence.adapter(self,Bio::Sequence::Adapter::BioSQL)
      end
    end #Sequence
    
    
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
