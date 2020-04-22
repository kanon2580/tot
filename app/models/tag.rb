class Tag < ApplicationRecord
  validates	:name, presence: true

  has_many :taggings
  has_many :issues, through: :taggings

  def self.search(team, q)
    return team.tags if q == ""

    splited_q = q.split(/[[:blank:]]+/)
    tags = []
    splited_q.each do |q|
      next if q == ""
      tags += team.tags.where('LOWER(name) LIKE ?', "%#{q}%".downcase)
    end
    tags.uniq!
    return tags
  end
end
