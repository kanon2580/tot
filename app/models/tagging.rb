class Tagging < ApplicationRecord
  belongs_to :issue
	belongs_to :tag
end
