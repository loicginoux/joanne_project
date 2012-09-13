class AddTimezoneToUsers < ActiveRecord::Migration
  def change
    add_column :users, :timezone, :string, :default => "Central Time (US & Canada)"   
  end
end
