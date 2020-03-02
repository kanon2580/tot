class UsersController < ApplicationController
  def my_page
    @team_members = TeamMember.where(user_id: current_user)

# chart.jsに渡す値
    gon.user_name = current_user.name
    gon.response_evaluation_datas = time_related_evaluation(ResponseEvaluation)
    gon.required_time_evaluation_datas = time_related_evaluation(RequiredTimeEvaluation)
    gon.like_evaluation_datas = like_evaluation_datas
    gon.best_answer_evaluation_datas = best_answer_evaluation_datas
    gon.issue_tags_labels = issue_tags_labels
    gon.issue_tags_evaluation_datas = issue_tags_evaluation_datas
    gon.comment_tags_labels = comment_tags_labels
    gon.comment_tags_evaluation_datas = comment_tags_evaluation_datas
  end

  def edit
    @user = current_user
  end

  def update
    if @user.update(user_params)
      redirect_to mypage_path
    else
      flash[:error] = "ユーザー情報が正常に保存されませんでした"
      render 'edit'
    end
  end

  def index
    users = @team.users
    @pagenated_users = users.page(params[:page]).per(12)
  end

  def show
    @team_members = TeamMember.where(team_id: params[:team_id])
    @issues = @team.issues
  end

  private
  def user_params
    params.require(:user).permit(:name, :introduction, :profile_image)
  end

  def time_related_evaluation(evaluation_type)
    evaluation_base = evaluation_type.group(:user_id).average(:difference).map{|k,v| v.to_i}
    evaluation_datas_sort_by_max(evaluation_base)
  end

  def like_evaluation_datas
    # 標本不足により、いいね総数で算出
    user_issues_array = User.joins(:issues).group("users.id").map{|user| [user.id, user.issue_ids]}.to_h
    like_count_array = user_issues_array.map{|user,issues| issues.map{|o| Issue.find(o).likes.count}.sum}
    evaluation_datas_sort_by_min(like_count_array)
  end

  def best_answer_evaluation_datas
    best_answer_count_array = User.joins(:comments).group("users.id").map{|o| User.find(o.id).comments.where(has_best_answer: true).count}
    evaluation_datas_sort_by_min(best_answer_count_array)
  end

  def evaluation_datas_sort_by_min(evaluation_base)
    # 平均値が高いと高得点
    if evaluation_base.all? {|v| v == 0}
      evaluation_base = [0]
    else
      # 階級幅の計算
      min = evaluation_base.min
      max = evaluation_base.max
      evaluation_class = (max - min)/10

      # 階級が切り替わる値を計算、配列に渡す
      evaluation_classes = []
      i = min

      9.times{|n|
        i += evaluation_class
        evaluation_classes << i
      }

      # 度数計算、配列に渡す
      evaluation_datas = []
      n = 0
      i = evaluation_classes[n]

      count_evaluations = evaluation_base.select{|o| (min...i) === o}.count
      evaluation_datas << count_evaluations

      8.times{|m|
      n += 1
      count_evaluations = evaluation_base.select{|o| (evaluation_classes[n]...i) === o}.count
      evaluation_datas << count_evaluations
      i = evaluation_classes[n]
      }

      count_evaluations = evaluation_base.select{|o| (i..max) === o}.count
      evaluation_datas << count_evaluations
    end
  end

  def evaluation_datas_sort_by_max(evaluation_base)
    # 平均値が低いと高得点
    if evaluation_base.all? {|v| v == 0}
      evaluation_base = [0]
    else
      # 階級幅の計算
      min = evaluation_base.min
      max = evaluation_base.max
      evaluation_class = (max - min)/10

      # 階級が切り替わる値を計算、配列に渡す
      evaluation_classes = []
      i = max

      9.times{|n|
        i -= evaluation_class
        evaluation_classes << i
      }

      # 度数計算、配列に渡す
      evaluation_datas = []
      n = 0
      i = evaluation_classes[n]

      count_evaluations = evaluation_base.select{|o| (i..max) === o}.count
      evaluation_datas << count_evaluations

      8.times{|m|
      n += 1
      count_evaluations = evaluation_base.select{|o| (evaluation_classes[n]...i) === o}.count
      evaluation_datas << count_evaluations
      i = evaluation_classes[n]
      }

      count_evaluations = evaluation_base.select{|o| (min...i) === o}.count
      evaluation_datas << count_evaluations
    end
  end

  def issue_tags_labels
    user_issue_tags_array = current_user.issues.map{|issue| issue.tags.map{|tag| tag.name}}.flatten
    tags_count_array = user_issue_tags_array.group_by(&:itself).keys
  end

  def issue_tags_evaluation_datas
    user_issue_tags_array = current_user.issues.map{|issue| issue.tags.map{|tag| tag.id}}.flatten
    tags_count_array = user_issue_tags_array.group_by(&:itself).map{|k,v| [k, v.count]}.to_h
    base = tags_count_array.values.sum.to_f
    evaluation_datas = tags_count_array.map{|k,v| ((v / base)*100).to_i}
  end

  def comment_tags_labels
    user_comment_tags_array = current_user.comments.map{|comment| comment.issue.tags.map{|tag| tag.name}}.flatten
    tags_count_array = user_comment_tags_array.group_by(&:itself).keys
  end

  def comment_tags_evaluation_datas
    user_comment_tags_array = current_user.comments.map{|comment| comment.issue.tags.map{|tag| tag.id}}.flatten
    tags_count_array = user_comment_tags_array.group_by(&:itself).map{|k,v| [k, v.count]}.to_h
    base = tags_count_array.values.sum.to_f
    evaluation_datas = tags_count_array.map{|k,v| ((v / base)*100).to_i}
  end

end

