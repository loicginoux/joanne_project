# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

require 'factory_girl'
Dir[Rails.root + "spec/factories/*.rb"].each {|file| require file }


u1 = FactoryGirl.create(:user_with_data_points)
u2 = FactoryGirl.create(:user)
u3 = FactoryGirl.create(:user_with_data_points)
dp  = u1.data_points.last
dp2 = u3.data_points.last
