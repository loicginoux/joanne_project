class Friendship < ActiveRecord::Base
  belongs_to :user
  belongs_to :followee, :class_name => 'User'
  
  
  def self.prepareGroups(friendships, groupSize)
    groups = Array.new
    friendshipGroup = Array.new
    $i = 1;
    friendships.each do|user|
      if $i<groupSize 
        friendshipGroup.push(user)
        $i +=1;
      else
        groups.push(friendshipGroup)
        friendshipGroup = Array.new
        $i = 1
      end
    end
    groups.push(friendshipGroup)
    groups
  end
end
