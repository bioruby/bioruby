
 module Bio
    class SQL 
			    class Taxon < DummyBase
			      set_sequence_name "taxon_pk_seq"
			      has_many :taxon_names, :class_name => "TaxonName"
            has_one :taxon_scientific_name, :class_name => "TaxonName", :conditions=>"name_class = 'scientific name'"
			      has_one :bioentry
			    end		
		end #SQL
end #Bio
