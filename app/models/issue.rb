class Issue < ApplicationRecord
  validates	:title, presence: true

  has_many :with_tags	
	has_many :likes	
	has_many :comments	
	has_many :response_evaluations	
	has_many :required_time_evaluations	

  belongs_to :user	
	belongs_to :team
end
