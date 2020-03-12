class LikesController < ApplicationController
  before_action :only_team_user

  def create
    like = current_user.likes.new(issue_id: @issue.id)
    like.save
  end

  def destroy
    like = @issue.likes.find_by(user_id: current_user)
    like.destroy
  end

  private
  def only_team_user
    unless TeamMember.where(team_id: @team).any? {|team| team.user_id == current_user.id}
      redirect_to mypage_path(current_user)
    end
  end
end
