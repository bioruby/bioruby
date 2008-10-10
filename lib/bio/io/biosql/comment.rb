 module Bio
    class SQL
			class Comment < DummyBase
			      belongs_to :bioentry, :class_name => "Bioentry"
			end
		end #SQL
end #Bio		   
