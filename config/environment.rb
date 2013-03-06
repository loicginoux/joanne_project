# Load the rails application
require File.expand_path('../application', __FILE__)
require_relative 'initializers/cloudfront'

# Initialize the rails application
Foodrubix::Application.initialize!

# date formatting
# ex:   01-30-2013 09:34 pm
Time::DATE_FORMATS[:readable] = "%m-%d-%Y %I:%M %P"

