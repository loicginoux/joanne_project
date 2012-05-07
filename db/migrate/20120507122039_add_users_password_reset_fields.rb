class AddUsersPasswordResetFields < ActiveRecord::Migration
  def up
    add_column :users, :perishable_token, :string, :default => "", :null => false  
    add_index :users, :perishable_token      
  end

  def down
    remove_column :users, :perishable_token  
    
  end
end
