
 module Bio
    class SQL 
		    class SeqfeatureDbxref < DummyBase
		      set_primary_key nil #seqfeature_id, dbxref_id
#delete		      set_sequence_name nil
		      belongs_to :seqfeature
		      belongs_to :dbxref
		    end		
		end #SQL
end #Bio
