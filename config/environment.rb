# Load the rails application
require File.expand_path('../application', __FILE__)
require_relative 'initializers/cloudfront'

# Initialize the rails application
Foodrubix::Application.initialize!

