class UsersController < ApplicationController
  def my_page
    @team_members = TeamMember.where(user_id: current_user)



# chart.jsに渡す値
    gon.user_name = current_user.name
    gon.response_evaluation_datas = evaluation_datas(ResponseEvaluation)
    gon.required_time_evaluation_datas = evaluation_datas(RequiredTimeEvaluation)

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

  def evaluation_datas(evaluation_type)
    # 全ユーザーの平均値計算
    users_average = evaluation_type.group(:user_id).average(:difference).map{|k,v| v.to_i}

    # 階級幅の計算
    min = users_average.min
    max = users_average.max
    evaluation_class = (max - min)/10

    # 階級が切り替わる値を計算、配列に渡す
    evaluation_classes = []
    i = min

    9.times{|n|
      i += (evaluation_class + min)
      evaluation_classes << i
    }

    # 度数計算、配列に渡す
    evaluation_datas = []
    n = 8
    i = evaluation_classes[n]

    count_evaluations = users_average.select{|o| (i..max) === o}.count
    evaluation_datas << count_evaluations

    8.times{|m|
    count_evaluations = users_average.select{|o| (i...evaluation_classes[n]) === o}.count
    evaluation_datas << count_evaluations
    n -= 1
    i = evaluation_classes[n]
    }

    count_evaluations = users_average.select{|o| (min...evaluation_classes[n]) === o}.count
    evaluation_datas << count_evaluations
  end

end
