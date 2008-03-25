 module Bio
    class SQL
			class Dbxref < DummyBase
#delete				set_primary_key "dbxref_id"
			      set_sequence_name "dbxref_pk_seq"
			      has_many :dbxref_qualifier_values, :class_name => "DbxrefQualifierValue"
			      has_many :locations, :class_name => "Location"
			      has_many :references, :class_name=>"Reference"
			      has_many :term_dbxrefs, :class_name => "TermDbxref"
			      has_many :bioentry_dbxrefs, :class_name => "BioentryDbxref"
            #TODO: check is with bioentry there is an has_and_belongs_to_many relationship has specified in schema overview.
			    end
    		end #SQL
end #Bio		
