
 module Bio
    class SQL 
			    class TaxonName < DummyBase
			      set_primary_keys :taxon_id, :name, :name_class
			      belongs_to :taxon, :class_name => "Taxon"      
			    end		
		end #SQL
end #Bio
