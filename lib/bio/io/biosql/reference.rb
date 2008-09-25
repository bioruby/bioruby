
 module Bio
    class SQL 
		    class Reference < DummyBase  
		      belongs_to :dbxref, :class_name => "Dbxref"
		      has_many :bioentry_references, :class_name=>"BioentryRefernce"
		    end		
		end #SQL
end #Bio
