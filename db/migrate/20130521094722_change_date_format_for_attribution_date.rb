class ChangeDateFormatForAttributionDate < ActiveRecord::Migration
	def self.up
		change_column :points, :attribution_date, :datetime
	end

	def self.down
		change_column :points, :attribution_date, :date
	end
end
