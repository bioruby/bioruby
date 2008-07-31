
 module Bio
    class SQL 
		    class Reference < DummyBase  
		      belongs_to :dbxref
		      has_many :bioentry_references, :class_name=>"BioentryRefernce"
		    end		
		end #SQL
end #Bio
