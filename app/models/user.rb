class User < ActiveRecord::Base
  
  validates_presence_of :firstname, :lastname, :email
  validates_uniqueness_of :email, :case_sensitive => false
  
  
	rolify
  # Include default devise modules. Others available are:
  # :token_authenticatable, :encryptable, :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :firstname, :lastname, :email, :password, :password_confirmation, :remember_me
end
