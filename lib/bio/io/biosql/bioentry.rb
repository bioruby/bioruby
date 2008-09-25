module Bio
    class SQL
			class Bioentry < DummyBase
#				set_sequence_name "bioentry_pk_seq"
				set_primary_key "bioentry_id"
				belongs_to :biodatabase, :class_name => "Biodatabase"
				belongs_to :taxon, :class_name => "Taxon"
				has_one :biosequence
				#, :class_name => "Biosequence", :foreign_key => "bioentry_id"
				has_many :comments, :class_name =>"Comment", :order =>'rank'
				has_many :seqfeatures
				#, :class_name => "Seqfeature", :order=>'rank'
				has_many :bioentry_references, :class_name=>"BioentryReference" #, :foreign_key => "bioentry_id"
				has_many :bioentry_dbxrefs, :class_name => "BioentryDbxref"
				has_many :object_bioentry_relationships, :class_name=>"BioentryRelationship", :foreign_key=>"object_bioentry_id" #non mi convince molto credo non funzioni nel modo corretto
				has_many :subject_bioentry_relationships, :class_name=>"BioentryRelationship", :foreign_key=>"subject_bioentry_id" #non mi convince molto credo non funzioni nel modo corretto

				has_many :cdsfeatures, :class_name=>"Seqfeature", :foreign_key =>"bioentry_id", :conditions=>["term.name='CDS'"], :include=>"type_term"
        
        has_many :terms, :through=>:bioentry_qualifier_values, :class_name => "Term"
        #NOTE: added order_by for multiple hit and manage ranks correctly
        has_many :bioentry_qualifier_values, :order=>"bioentry_id,term_id,rank", :class_name => "BioentryQualifierValue"
        
				#per la creazione richiesti:
				#name, accession, version
#				validates_uniqueness_of :accession, :scope=>[:biodatabase_id]
#				validates_uniqueness_of :name, :scope=>[:biodatabase_id] 
			#	validates_uniqueness_of :identifier, :scope=>[:biodatabase_id]
				
			end
		end #SQL
end #Bio
