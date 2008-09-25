
 module Bio
    class SQL 
		    class SeqfeatureDbxref < DummyBase
		      set_primary_keys :seqfeature_id, :dbxref_id
#delete		      set_sequence_name nil
		      belongs_to :seqfeature, :class_name => "Seqfeature", :foreign_key => "seqfeature_id"
		      belongs_to :dbxref, :class_name => "Dbxref", :foreign_key => "dbxref_id"
		    end		
		end #SQL
end #Bio
