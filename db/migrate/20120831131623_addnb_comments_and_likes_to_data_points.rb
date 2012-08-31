class AddnbCommentsAndLikesToDataPoints < ActiveRecord::Migration
  def change
    add_column :data_points, :nb_comments, :integer, :default => 0
    add_column :data_points, :nb_likes, :integer, :default => 0
  end
end
