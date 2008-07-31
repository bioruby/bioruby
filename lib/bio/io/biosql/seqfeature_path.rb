 module Bio
    class SQL 
			   class SeqfeaturePath < DummyBase
			      set_primary_key nil 
			      set_sequence_name nil
			      belongs_to :object_seqfeature, :class_name => "Seqfeature"
			      belongs_to :subject_seqfeature, :class_name => "Seqfeature"
			    end		
		end #SQL
end #Bio
