class CreateUserSessions < ActiveRecord::Migration
  def change
    create_table :user_sessions do |t|
      t.string :username
      t.string :password
      t.timestamps
    end
  end
end
