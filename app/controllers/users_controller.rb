class UsersController < ApplicationController
  before_action :only_team_user, only: [:index]
  before_action :only_current_user, only: [:edit, :update]

  def show
    if @team.present? && @user.present?
      only_team_user
    else
      only_current_user
    end

    # chart.jsに渡す変数
    @user_scores = []
    gon.user_name = @user.name
    # response
    calculation_evaluation_data = @user.time_related_evaluation(ResponseEvaluation)
    gon.response_evaluation_datas = calculation_evaluation_data[0]
    @user_scores << calculation_evaluation_data[1]
    # required time
    calculation_evaluation_data = @user.time_related_evaluation(RequiredTimeEvaluation)
    gon.required_time_evaluation_datas = calculation_evaluation_data[0]
    @user_scores << calculation_evaluation_data[1]
    # like
    calculation_evaluation_data = @user.like_evaluation_datas
    gon.like_evaluation_datas = calculation_evaluation_data[0]
    @user_scores << calculation_evaluation_data[1]
    # best answer
    calculation_evaluation_data = @user.best_answer_evaluation_datas
    gon.best_answer_evaluation_datas = calculation_evaluation_data[0]
    @user_scores << calculation_evaluation_data[1]
    # issue viewed count
    calculation_evaluation_data = @user.issue_viewed_evaluation_datas
    gon.issue_viewed_evaluation_datas = calculation_evaluation_data[0]
    @user_scores << calculation_evaluation_data[1]
    # total
    gon.user_scores = @user_scores
    # issue tags
    gon.issue_tags_labels = @user.issue_tags_labels
    gon.issue_tags_evaluation_datas = @user.issue_tags_evaluation_datas
    # comment tags
    gon.comment_tags_labels = @user.comment_tags_labels
    gon.comment_tags_evaluation_datas = @user.comment_tags_evaluation_datas
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
end
