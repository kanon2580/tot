class UsersController < ApplicationController
  def my_page
    @team_members = TeamMember.where(user_id: current_user)
  end

  def edit
    @user = current_user
  end

  def update
    user = User.find(params[:id])
    if user.update(user_params)
      redirect_to user
    else
      flash[:error] = "ユーザー情報が正常に保存されませんでした"
      render 'edit'
    end
  end

  def index
    @team_members = TeamMember.where(team_id: params[:team_id])
  end

  def show
    @user = User.find(params[:id])
    @team_members = TeamMember.where(team_id: params[:team_id])
    team = Team.find(params[:team_id])
    @issues = team.issues
  end

  private
  def user_params
    params.require(:user).permit(:name, :introduction, :profile_image)
  end
end
