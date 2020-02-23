class Tag < ApplicationRecord
  validates	:name, presence: true

  has_many :tagging, dependent: :destroy
end
