class UsersController < ApplicationController
  before_action :only_team_user, only: [:index]
  before_action :only_current_user, only: [:edit, :update]

  def show
    if @team.present? && @user.present?
      only_team_user
    else
      only_current_user
    end
# chart.js
    @user_scores = []
    gon.user_name = @user.name

# response
    gon.response_evaluation_datas = time_related_evaluation(ResponseEvaluation)
    @user_scores << @user_score

# required time
    gon.required_time_evaluation_datas = time_related_evaluation(RequiredTimeEvaluation)
    @user_scores << @user_score

# like
    gon.like_evaluation_datas = like_evaluation_datas
    @user_scores << @user_score

# best answer
    gon.best_answer_evaluation_datas = best_answer_evaluation_datas
    @user_scores << @user_score

# issue viewed count
    gon.issue_viewed_count_evaluation = issue_viewed_count_evaluation
    @user_scores << @user_score

# total
    gon.user_scores = @user_scores 

# issue tags
    gon.issue_tags_labels = issue_tags_labels(@user)
    gon.issue_tags_evaluation_datas = issue_tags_evaluation_datas(@user)

# comment tags
    gon.comment_tags_labels = comment_tags_labels(@user)
    gon.comment_tags_evaluation_datas = comment_tags_evaluation_datas(@user)

  end

  def edit
  end

  def update
    if @user.update(user_params)
      redirect_to mypage_path
    else
      flash.now[:error] = "名前が空欄のようです。もう一度お試しください。"
      render 'edit'
    end
  end

  def index
    users = @team.users
    @pagenated_users = users.page(params[:page]).per(12)
  end

  private
  def only_team_user
    unless TeamMember.where(team_id: @team).any? {|team| team.user_id == current_user.id}
      redirect_to mypage_path(current_user)
    end
  end

  def only_current_user
    unless @user == current_user
      redirect_to mypage_path(current_user)
    end
  end

  def user_params
    params.require(:user).permit(:name, :introduction, :profile_image)
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

  def issue_viewed_count_evaluation
    # 標本不足により、総数で算出
    user_issue_viewed_count = Issue.group(:user_id).map{|issue| [issue.user_id, issue.impressionist_count]}.to_h
    evaluation_datas_sort_by_min(user_issue_viewed_count)
  end

  def evaluation_datas_sort_by_min(user_evaluations)
    @user_score = 0
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
    @user_score = n+1 if validation_included_user.any? {|k,v| k == @user.id}
    n += 1

    8.times{|m|
      validation_included_user = user_evaluations.select{|k,v| (i...evaluation_classes[n]) === v}
      count_included_user = validation_included_user.count
      evaluation_datas << count_included_user
      @user_score = n+1 if validation_included_user.any? {|k,v| k == @user.id}
      i = evaluation_classes[n]
      n += 1
    }

    validation_included_user = user_evaluations.select{|k,v| (i..max) === v}
    count_included_user = validation_included_user.count
    evaluation_datas << count_included_user
    @user_score = n+1 if validation_included_user.any? {|k,v| k == @user.id}

    return(evaluation_datas)
  end

  def evaluation_datas_sort_by_max(user_evaluations)
    @user_score = 0
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
    @user_score = n+1 if validation_included_user.any? {|k,v| k == @user.id}
    n += 1

    8.times{|m|
    validation_included_user = user_evaluations.select{|k,v| (evaluation_classes[n]...i) === v}
    count_included_user = validation_included_user.count
    evaluation_datas << count_included_user
    @user_score = n+1 if validation_included_user.any? {|k,v| k == @user.id}
    i = evaluation_classes[n]
    n += 1
    }

    validation_included_user = user_evaluations.select{|k,v| (min...i) === v}
    count_included_user = validation_included_user.count
    evaluation_datas << count_included_user
    @user_score = n+1 if validation_included_user.any? {|k,v| k == @user.id}

    return(evaluation_datas)
  end

  def issue_tags_labels(user)
    user_issue_tags_array = user.issues.map{|issue| issue.tags.map{|tag| tag.name}}.flatten
    if user_issue_tags_array == []
      tags_name = ["nothing issues tags"]
      return(tags_name)
    end
    tags_name = user_issue_tags_array.group_by(&:itself).keys
  end

  def issue_tags_evaluation_datas(user)
    user_issue_tags_array = user.issues.map{|issue| issue.tags.map{|tag| tag.id}}.flatten
    if user_issue_tags_array == []
      evaluation_datas = [100]
      return(evaluation_datas)
    end
    tags_count_array = user_issue_tags_array.group_by(&:itself).map{|k,v| [k, v.count]}.to_h
    base = tags_count_array.values.sum.to_f
    evaluation_datas = tags_count_array.map{|k,v| ((v / base)*100).to_i}
  end

  def comment_tags_labels(user)
    user_comment_tags_array = user.comments.map{|comment| comment.issue.tags.map{|tag| tag.name}}.flatten
    if user_comment_tags_array == []
      tags_name = ["nothing comments tags"]
      return(tags_name)
    end
    tags_name = user_comment_tags_array.group_by(&:itself).keys
  end

  def comment_tags_evaluation_datas(user)
    user_comment_tags_array = user.comments.map{|comment| comment.issue.tags.map{|tag| tag.id}}.flatten
    if user_comment_tags_array == []
      evaluation_datas = [100]
      return(evaluation_datas)
    end
    tags_count_array = user_comment_tags_array.group_by(&:itself).map{|k,v| [k, v.count]}.to_h
    base = tags_count_array.values.sum.to_f
    evaluation_datas = tags_count_array.map{|k,v| ((v / base)*100).to_i}
  end

end
