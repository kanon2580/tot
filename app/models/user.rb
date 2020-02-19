class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  validates	:name, presence: true

  has_many :team_members
	has_many :issues
	has_many :likes
	has_many :comments
	has_many :response_evaluations
	has_many :required_time_evaluations

  attachment :profile_image
end
