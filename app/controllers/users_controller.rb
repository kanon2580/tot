class UsersController < ApplicationController
  def my_page
    @team_members = TeamMember.where(user_id: current_user)



# chart.jsに渡す値
    gon.user_name = current_user.name
    gon.response_evaluation_datas = response_evaluation_datas

  end

  def edit
    @user = current_user
  end

  def update
    user = User.find(params[:user_id])
    if user.update(user_params)
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
    @user = User.find(params[:user_id])
    @team_members = TeamMember.where(team_id: params[:team_id])
    @issues = @team.issues
  end

  private
  def user_params
    params.require(:user).permit(:name, :introduction, :profile_image)
  end

  def response_evaluation_datas
    # 全ユーザーの平均値計算
    all_users_average = []
    User.all.each do |user|
      users_evaluations = user.response_evaluations
      unless users_evaluations.count == 0
        sum_users_evaluation = users_evaluations.pluck(:difference).map{|n| n.ceil}.sum
        users_average = sum_users_evaluation / users_evaluations.count
        all_users_average << users_average
      end
    end

    # 階級まわりの計算で使う変数
    min_evaluation = all_users_average.min
    max_evaluation = all_users_average.max
    evaluation_diff = max_evaluation - min_evaluation
    evaluation_class = (evaluation_diff / 10) # 階級幅
    # 切り替わる値としてほしいのは8つだけど、階級幅を割り出す時は10段階なので10！

    # 階級が切り替わる値を計算、配列に渡す
    evaluation_classes = []
    i = min_evaluation

    9.times{|n|
      i += (evaluation_class + min_evaluation)
      evaluation_classes << i
    }

    responses = ResponseEvaluation.all
    evaluation_datas = []
    i = 0
    n = 0

    # 度数計算、配列に渡す
    count_evaluations = all_users_average.select{|o| (min_evaluation...evaluation_classes[n]) === o}.count
    evaluation_datas << count_evaluations
    i = evaluation_classes[n]
    n += 1

    8.times{|m|
      count_evaluations = all_users_average.select{|o| (i...evaluation_classes[n]) === o}.count
      evaluation_datas << count_evaluations
      i = evaluation_classes[n]
      n += 1
    }

    i = evaluation_classes[8]
    count_evaluations = all_users_average.select{|o| (i..max_evaluation) === o}.count
    evaluation_datas << count_evaluations
  end
end
