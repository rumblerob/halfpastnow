# Load the rails application
require File.expand_path('../application', __FILE__)

config.gem 'flying-sphinx',
  :version => '0.6.1'

# Initialize the rails application
Myapp::Application.initialize!
