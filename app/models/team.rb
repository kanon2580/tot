class Team < ApplicationRecord
  validates	:name, presence: true

  has_many :team_members
	has_many :issues
	has_many :tags
end
