class ResponseEvaluation < ApplicationRecord
  belongs_to :user
	belongs_to :comment, optional: true
end
