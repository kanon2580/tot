class UsersController < ApplicationController
  before_action :only_team_user, only: [:index, :show]
  before_action :only_current_user, only: [:edit, :update, :mypage]
  before_action :barrier_trial_user, only: [:edit, :update]

  def mypage
    @page_title = "My page"
    @teams = current_user.teams.reverse
    @new_team_mamber = TeamMember.new
    chart_datas
  end

  def join_team
    team_name = params[:team_member][:team_name]
    team_id = params[:team_member][:team_id]
    team = Team.find_by(id: team_id, name: team_name)
    if team.present?
      team_member = TeamMember.new(team_member_params)
      team_member.user = current_user
      team_member.team = team
      team_member.save
      redirect_to team_path(team)
    else
      @join_team = TeamMember.new
      flash[:error] = "The team is not found."
      redirect_back(fallback_location: root_path)
    end
  end

  def show
    @page_title = "User information"
    chart_datas
  end

  def chart_datas
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
    @page_title = "Edit profile"
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
    @page_title = "Users"
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

  def barrier_trial_user
    if  @user.id == 31
      redirect_to mypage_path(current_user)
    end
  end

  def user_params
    params.require(:user).permit(:name, :introduction, :profile_image)
  end

  def team_member_params
    params.require(:team_member).permit(:user_id, :team_id)
  end
end
