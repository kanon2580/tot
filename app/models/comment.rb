class Comment < ApplicationRecord
  validates	:comment, presence: true

  belongs_to :user	
  belongs_to :issue
  belongs_to :response_evaluation, optional: true, dependent: :destroy
end
