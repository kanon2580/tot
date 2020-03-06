class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  validates	:name, presence: true

  has_many :team_members, dependent: :destroy
  has_many :teams, through: :team_members
  has_many :issues, dependent: :destroy
  has_many :likes, dependent: :destroy
  has_many :comments, dependent: :destroy
  has_many :response_evaluations, dependent: :destroy
  has_many :required_time_evaluations, dependent: :destroy

  attachment :profile_image
end

