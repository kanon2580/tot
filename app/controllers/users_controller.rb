class UsersController < ApplicationController
  def my_page
    @team_members = TeamMember.where(user_id: current_user)

# chart.jsに渡す値
    gon.user_name = current_user.name
    gon.response_evaluation_datas = time_related_evaluation(ResponseEvaluation)
    gon.required_time_evaluation_datas = time_related_evaluation(RequiredTimeEvaluation)
    gon.like_evaluation_datas = like_evaluation_datas
    gon.best_answer_evaluation_datas = best_answer_evaluation_datas
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
    @team_members = TeamMember.where(team_id: params[:team_id])
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
    evaluation_datas(evaluation_base)
  end

  def like_evaluation_datas
    # 標本不足により、いいね総数で算出
    user_issues_array = User.joins(:issues).group("users.id").map{|o| [o.id, o.issue_ids]}.to_h
    like_count_array = user_issues_array.map{|k,v| v.map{|o| Issue.find(o).likes.count}.sum}
    evaluation_datas(like_count_array)
  end

  def best_answer_evaluation_datas
    best_answer_count_array = User.joins(:comments).group("users.id").map{|o| User.find(o.id).comments.where(has_best_answer: true).count}
    evaluation_datas(best_answer_count_array)
  end

  def evaluation_datas(evaluation_base)
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

end
