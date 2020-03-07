class TagsController < ApplicationController
  before_action :only_team_user

  def index
    @tags = @team.tags
    @new_tag = Tag.new
  end

  def create
    new_tag = Tag.new(tag_params)
    new_tag.team_id = @team.id
    unless new_tag.save
      flash[:error] = "the tag had not save :("
    end
    redirect_to team_tags_path(@team)
  end

  private
  def only_team_user
    unless TeamMember.where(team_id: @team).any? {|team| team.user_id == current_user.id}
      redirect_to mypage_path(current_user)
    end
  end

  def tag_params
    params.require(:tag).permit(:team_id, :name)
  end
end
