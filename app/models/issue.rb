class Issue < ApplicationRecord
	validates	:title, presence: true
	validates	:body, presence: true

	has_many :likes, dependent: :destroy
	has_many :comments, dependent: :destroy
	has_many :taggings
	has_many :tags, through: :taggings

  belongs_to :user	
	belongs_to :team

	def likes_by?(user)
		likes.find_by(user_id: user.id).present?
	end
end
