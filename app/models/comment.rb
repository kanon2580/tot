class Comment < ApplicationRecord
  validates	:comment, presence: true

  belongs_to :user	
  belongs_to :issue

  has_one :response_evaluation, dependent: :destroy
end
