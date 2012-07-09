class AddSingleAccessTokenToUsers < ActiveRecord::Migration
  def change
    add_column :users, :single_access_token, :string
  end
end
