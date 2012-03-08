# Load the rails application
require File.expand_path('../application', __FILE__)

config.gem 'thinking-sphinx',
  :lib     => 'thinking_sphinx',
  :version => '2.0.10'

config.gem 'flying-sphinx',
  :version => '0.6.1'

# Initialize the rails application
Myapp::Application.initialize!
