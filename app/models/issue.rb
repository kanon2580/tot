class Issue < ApplicationRecord
	validates	:title, presence: true
	validates	:body, presence: true

	has_many :likes, dependent: :destroy
	has_many :comments, dependent: :destroy
	has_many :taggings
	has_many :tags, through: :taggings

  belongs_to :user
	belongs_to :team

	# PV count
	is_impressionable

	def likes_by?(user)
		likes.find_by(user_id: user.id).present?
	end

	def self.search(team, target, status, q)
		if target == "title"
      splited_q = q.split(/[[:blank:]]+/)
      issues = []
      splited_q.each do |q|
        next if q == ""
        issues += team.issues.where('LOWER(title) LIKE ?', "%#{q}%".downcase)
      end
      # order、reveseで新しい順にしたいけどできなかったTT
      # orderかpageにnomethod error
      issues.uniq!
      issues = issues.select{|issue| issue.has_settled == true} if status == "settled"
      issues = issues.select{|issue| issue.has_settled == false} if status == "unsettled"
    elsif target == "body"
      splited_q = q.split(/[[:blank:]]+/)
      issues = []
      splited_q.each do |q|
        next if q == ""
        issues += team.issues.where('LOWER(body) LIKE ?', "%#{q}%".downcase)
      end
      issues.uniq!
      issues = issues.select{|issue| issue.has_settled == true} if status == "settled"
      issues = issues.select{|issue| issue.has_settled == false} if status == "unsettled"
    elsif target == "tag"
      splited_q = q.split(/[[:blank:]]+/)
      issues = []
      splited_q.each do |q|
        next if q == ""
        issues += team.issues.joins(:tags).where('LOWER(tags.name) LIKE ?', "%#{q}%".downcase)
      end
      issues.uniq!
      issues = issues.select{|issue| issue.has_settled == true} if status == "settled"
      issues = issues.select{|issue| issue.has_settled == false} if status == "unsettled"
    elsif target == "user"
      splited_q = q.split(/[[:blank:]]+/)
      issues = []
      splited_q.each do |q|
        next if q == ""
        issues += team.issues.joins(:user).where('LOWER(users.name) LIKE ?', "%#{q}%".downcase)
      end
      issues.uniq!
      issues = issues.select{|issue| issue.has_settled == true} if status == "settled"
      issues = issues.select{|issue| issue.has_settled == false} if status == "unsettled"
    else
      issues = team.issues
      issues = issues.where(has_settled: true) if status == "settled"
      issues = issues.where(has_settled: false) if status == "unsettled"
    end
      return issues
	end
end
