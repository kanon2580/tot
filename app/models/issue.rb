class Issue < ApplicationRecord
	validates	:title, presence: true
  validates	:body, presence: true

	has_many :likes, dependent: :destroy
	has_many :comments, dependent: :destroy
	has_many :taggings
	has_many :tags, through: :taggings
	has_many :response_evaluations, dependent: :destroy
	has_many :required_time_evaluations, dependent: :destroy

  belongs_to :user	
	belongs_to :team
end
