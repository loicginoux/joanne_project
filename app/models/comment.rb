class Comment < ActiveRecord::Base
	#########################
  # Virtual attributes
  #########################
  # alow access to current_user in model
  attr_accessor :current_user

	#########################
  # Validators
  #########################
  validates :text, :presence => true
	validate :editor_must_be_owner, :on => :update

  def editor_must_be_owner
    if current_user.id != user_id
      errors[:base] << "You are not the owner"
    end
  end

  #########################
  # Associations
  #########################
	belongs_to :user
	belongs_to :data_point, :touch => true


  #########################
  # Scopes
  #########################
	scope :onOthersPhoto, lambda{||
		# comment that is in a photo not belonging to the commenter
		Comment.joins(:data_point).where('data_points.user_id != comments.user_id')
	}

	scope :whereDataPointBelongsTo, lambda{|user|
		Comment.joins(:data_point).where('data_points.user_id = ?', user.id )
	}

  #########################
  # Methods
  #########################
	def onOwnPhoto?
		user = self.user_id
		usersDatapoint = self.data_point.user_id
		return user == usersDatapoint
	end

	def self.col_list
    	Comment.column_names.collect {|c| "comments.#{c}"}.join(",")
  	end
end
