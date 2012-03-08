AdminData.config do |config|
  config.is_allowed_to_view = lambda {|controller| controller.send('logged_in?') }
end
