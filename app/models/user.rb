class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  validates :name, presence: true

  has_many :team_members, dependent: :destroy
  has_many :teams, through: :team_members
  has_many :issues, dependent: :destroy
  has_many :likes, dependent: :destroy
  has_many :comments, dependent: :destroy
  has_many :response_evaluations, dependent: :destroy
  has_many :required_time_evaluations, dependent: :destroy

  attachment :profile_image

  def self.search(team, q)
    splited_q = q.split(/[[:blank:]]+/)

    users = []
    splited_q.each do |q|
      next if q == ""
      users += team.users.where('LOWER(name) LIKE ?', "%#{q}%".downcase).order(created_at: :desc)
    end
    users.uniq!
    return users
  end

  def time_related_evaluation(evaluation_type)
    user_averages = evaluation_type.group(:user_id).average(:difference).map{|k,v| [k, v.to_i]}.to_h
    criteria = calculation_evaluation_criteria(user_averages)
    if criteria == [[0], [0]]
      return criteria
    end
    calculation_evaluation_datas_sort_by_max(criteria, user_averages)
  end

  def like_evaluation_datas
    # 標本不足により、総数で算出
    user_issues_array = User.joins(:issues).group("users.id").map{|user| [user.id, user.issue_ids]}.to_h
    like_count_array = user_issues_array.map{|user,issues| [user, issues.map{|issue| Issue.find(issue).likes.count}.sum]}.to_h
    criteria = calculation_evaluation_criteria(like_count_array)
    if criteria == [[0], [0]]
      return criteria
    end
    calculation_evaluation_datas_sort_by_min(criteria, like_count_array)
  end

  def best_answer_evaluation_datas
    # 標本不足により、総数で算出
    best_answer_count_array = Comment.group(:user_id).where(has_best_answer: true).count
    criteria = calculation_evaluation_criteria(best_answer_count_array)
    if criteria == [[0], [0]]
      return criteria
    end
    calculation_evaluation_datas_sort_by_min(criteria, best_answer_count_array)
  end

  def issue_viewed_evaluation_datas
    # 標本不足により、総数で算出
    user_issue_viewed_count = User.joins(issues: :impressions).group("users.id").count
    criteria = calculation_evaluation_criteria(user_issue_viewed_count)
    if criteria == [[0], [0]]
      return criteria
    end
    calculation_evaluation_datas_sort_by_min(criteria, user_issue_viewed_count)
  end

  def calculation_evaluation_criteria(evaluation_base)
    if evaluation_base.all? {|k,v| v == 0}
      user_evaluations = [[0], [0]]
      return user_evaluations
    end
    # 階級幅の計算
    min = evaluation_base.values.min
    max = evaluation_base.values.max
    diff = max - min
    interval = (diff / 10.0).round
    return min, max, interval
  end

  def calculation_evaluation_datas_sort_by_max(criteria, user_evaluations)
    # 個体値が低いと高得点
    min = criteria[0]
    max = criteria[1]
    interval = criteria[2]
    evaluation_classes = []
    i = min

    10.times{|n|
      evaluation_classes << i
      i += interval
    }
    evaluation_classes << max

    validation_included_user = validation_included_user(evaluation_classes, user_evaluations)
    validation_included_user[0].reverse!
    validation_included_user[1].reverse!
    user_score = calculation_user_score(validation_included_user[1])

    return validation_included_user[0], user_score
  end

  def calculation_evaluation_datas_sort_by_min(criteria, user_evaluations)
    # 個体値が高いと高得点
    min = criteria[0]
    max = criteria[1]
    interval = criteria[2]
    evaluation_classes = []
    i = max

    10.times{|n|
      evaluation_classes << i
      i -= interval
    }
    evaluation_classes << min
    evaluation_classes.reverse!

    validation_included_user = validation_included_user(evaluation_classes, user_evaluations)
    user_score = calculation_user_score(validation_included_user[1])

    return validation_included_user[0], user_score
  end

  def validation_included_user(evaluation_classes, user_evaluations)
    evaluation_datas = []
    user_included_status = []
    i = 0
    n = 0
    m = 0

    10.times{|m|
      n = evaluation_classes[i]
      i += 1
      m = evaluation_classes[i]
      if i == 10
        validation_included_user = user_evaluations.select{|k,v| (n..m) === v}
      else
        validation_included_user = user_evaluations.select{|k,v| (n...m) === v}
      end
      count_included_user = validation_included_user.count
      if validation_included_user.any? {|k,v| k == self.id}
        user_included_status << 1
      else
        user_included_status << 0
      end
      evaluation_datas << count_included_user
    }
    return evaluation_datas, user_included_status
  end

  def calculation_user_score(score_base)
    score_base.each_with_index{|status, i|
      if status == 1
        user_score = i+1
        return user_score
      end
    }
  end

  def issue_tags_labels
    user_issue_tags_array = self.issues.map{|issue| issue.tags.map{|tag| tag.name}}.flatten
    if user_issue_tags_array == []
      tags_name = ["nothing issues tags"]
      return(tags_name)
    end
    tags_name = user_issue_tags_array.group_by(&:itself).keys
  end

  def issue_tags_evaluation_datas
    user_issue_tags_array = self.issues.map{|issue| issue.tags.map{|tag| tag.id}}.flatten
    if user_issue_tags_array == []
      evaluation_datas = [100]
      return(evaluation_datas)
    end
    tags_count_array = user_issue_tags_array.group_by(&:itself).map{|k,v| [k, v.count]}.to_h
    base = tags_count_array.values.sum.to_f
    evaluation_datas = tags_count_array.map{|k,v| ((v / base)*100).to_i}
  end

  def comment_tags_labels
    user_comment_tags_array = self.comments.map{|comment| comment.issue.tags.map{|tag| tag.name}}.flatten
    if user_comment_tags_array == []
      tags_name = ["nothing comments tags"]
      return(tags_name)
    end
    tags_name = user_comment_tags_array.group_by(&:itself).keys
  end

  def comment_tags_evaluation_datas
    user_comment_tags_array = self.comments.map{|comment| comment.issue.tags.map{|tag| tag.id}}.flatten
    if user_comment_tags_array == []
      evaluation_datas = [100]
      return(evaluation_datas)
    end
    tags_count_array = user_comment_tags_array.group_by(&:itself).map{|k,v| [k, v.count]}.to_h
    base = tags_count_array.values.sum.to_f
    evaluation_datas = tags_count_array.map{|k,v| ((v / base)*100).to_i}
  end
end
