class Comment < ApplicationRecord
  validates	:comment, presence: true

  belongs_to :user	
  belongs_to :issue	
  belongs_to :response_evaluations
end
