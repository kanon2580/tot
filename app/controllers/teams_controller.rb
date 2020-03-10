class TeamsController < ApplicationController
  before_action :only_team_user

  def show
    @tags = @team.tags
    @issues = @team.issues.last(5).reverse
    @users = @team.users.last(4).reverse
    @tags = @team.tags.last(20).reverse
  end

  private
  def only_team_user
    unless TeamMember.where(team_id: @team).any? {|team| team.user_id == current_user.id}
      redirect_to mypage_path(current_user)
    end
  end
end
