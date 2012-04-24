class ApplicationController < ActionController::Base
  protect_from_forgery
  
  #rescue_from CanCan::AccessDenied do |exception|
  #    redirect_to root_path, :alert => exception.message
  #  end
  
    rescue_from CanCan::AccessDenied do |exception|
      flash[:error] = "Access denied!"
      redirect_to root_url
    end
  
   def logged_in?
     true
   end

   def admin_logged_in?
     true
   end  
  
end
