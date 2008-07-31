module Bio
		class SQL
			class Biodatabase < DummyBase
#delete				set_primary_key "biodatabase_id"
 				set_sequence_name "biodatabase_pk_seq"
				has_many :bioentries, :class_name =>"Bioentry", :foreign_key => "biodatabase_id"
				validates_uniqueness_of :name
			end
		end #SQL
end #Bio	


