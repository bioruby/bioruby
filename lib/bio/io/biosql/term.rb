
 module Bio
    class SQL 
			    class Term < DummyBase
			      set_sequence_name "term_pk_seq"
			      belongs_to :ontology
			      has_many :seqfeature_qualifier_values, :class_name => "SeqfeatureQualifierValue"
			      has_many :dbxref_qualifier_values, :class_name => "DbxrefQualifierValue"
            has_many :bioentry_qualifer_values, :class_name => "BioentryQualifierValue"
            has_many :bioentries, :through=>:bioentry_qualifier_values
			      has_many :locations, :class_name => "Location"
			      has_many :seqfeature_relationships, :class_name => "SeqfeatureRelationship"
			      has_many :term_dbxrefs, :class_name => "TermDbxref"
			      has_many :term_relationship_terms, :class_name => "TermRelationshipTerm"
			      has_many :term_synonyms, :class_name => "TermSynonym"
			      has_many :location_qualifier_values, :class_name => "LocationQualifierValue"
			      has_many :seqfeature_types, :class_name => "Seqfeature", :foreign_key => "type_term_id"			      
			      has_many :seqfeature_sources, :class_name => "Seqfeature", :foreign_key => "source_term_id"			      
			      has_many :term_path_subjects, :class_name => "TermPath", :foreign_key => "subject_term_id"
			      has_many :term_path_predicates, :class_name => "TermPath", :foreign_key => "predicate_term_id"
			      has_many :term_path_objects, :class_name => "TermPath", :foreign_key => "object_term_id"			      
			      has_many :term_relationship_subjects, :class_name => "TermRelationship", :foreign_key =>"subject_term_id"
			      has_many :term_relationship_predicates, :class_name => "TermRelationship", :foreign_key =>"predicate_term_id"
			      has_many :term_relationship_objects, :class_name => "TermRelationship", :foreign_key =>"object_term_id"
			      
			    end		
		end #SQL
end #Bio
