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
    evaluation_datas_sort_by_max(user_averages)
  end

  def like_evaluation_datas
    # 標本不足により、総数で算出
    user_issues_array = User.joins(:issues).group("users.id").map{|user| [user.id, user.issue_ids]}.to_h
    like_count_array = user_issues_array.map{|user,issues| [user, issues.map{|issue| Issue.find(issue).likes.count}.sum]}.to_h
    evaluation_datas_sort_by_min(like_count_array)
  end

  def best_answer_evaluation_datas
    # 標本不足により、総数で算出
    best_answer_count_array = Comment.group(:user_id).where(has_best_answer: true).count
    evaluation_datas_sort_by_min(best_answer_count_array)
  end

  def issue_viewed_evaluation_datas
    # 標本不足により、総数で算出
    user_issue_viewed_count = User.joins(issues: :impressions).group("users.id").count
    evaluation_datas_sort_by_min(user_issue_viewed_count)
  end

  def evaluation_datas_sort_by_max(user_evaluations)
    user_score = 0
    # 平均値が低いと高得点
    if user_evaluations.all? {|k,v| v == 0}
      evaluation_datas = [0]
      return
    end
    # 階級幅の計算
    min = user_evaluations.values.min
    max = user_evaluations.values.max
    diff = max - min
    interval = (diff / 10.0).round

    # 階級が切り替わる値を計算、配列に渡す
    evaluation_classes = []
    i = min

    9.times{|n|
      i += interval
      evaluation_classes << i
    }
    evaluation_classes.reverse!

    # 度数計算、配列に渡す
    evaluation_datas = []
    n = 0
    i = evaluation_classes[n]

    validation_included_user = user_evaluations.select{|k,v| (i..max) === v}
    count_included_user = validation_included_user.count
    evaluation_datas << count_included_user
    user_score = n+1 if validation_included_user.any? {|k,v| k == self.id}
    n += 1

    8.times{|m|
    validation_included_user = user_evaluations.select{|k,v| (evaluation_classes[n]...i) === v}
    count_included_user = validation_included_user.count
    evaluation_datas << count_included_user
    user_score = n+1 if validation_included_user.any? {|k,v| k == self.id}
    i = evaluation_classes[n]
    n += 1
    }

    validation_included_user = user_evaluations.select{|k,v| (min...i) === v}
    count_included_user = validation_included_user.count
    evaluation_datas << count_included_user
    user_score = n+1 if validation_included_user.any? {|k,v| k == self.id}

    return evaluation_datas, user_score
  end

  def evaluation_datas_sort_by_min(user_evaluations)
    user_score = 0
    # 平均値が高いと高得点
    if user_evaluations.all? {|k,v| v == 0}
      user_evaluations = [0]
      return
    end
    # 階級幅の計算
    min = user_evaluations.values.min
    max = user_evaluations.values.max
    diff = max - min
    interval = (diff / 10.0).round

    # 階級が切り替わる値を計算、配列に渡す
    evaluation_classes = []
    i = max

    9.times{|n|
      i -= interval
      evaluation_classes << i
    }
    evaluation_classes.reverse!

    # 度数計算、配列に渡す
    evaluation_datas = []
    n = 0
    i = evaluation_classes[n]

    validation_included_user = user_evaluations.select{|k,v| (min...i) === v}
    count_included_user = validation_included_user.count
    evaluation_datas << count_included_user
    user_score = n+1 if validation_included_user.any? {|k,v| k == self.id}
    n += 1

    8.times{|m|
      validation_included_user = user_evaluations.select{|k,v| (i...evaluation_classes[n]) === v}
      count_included_user = validation_included_user.count
      evaluation_datas << count_included_user
      user_score = n+1 if validation_included_user.any? {|k,v| k == self.id}
      i = evaluation_classes[n]
      n += 1
    }

    validation_included_user = user_evaluations.select{|k,v| (i..max) === v}
    count_included_user = validation_included_user.count
    evaluation_datas << count_included_user
    user_score = n+1 if validation_included_user.any? {|k,v| k == self.id}

    return evaluation_datas, user_score
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
