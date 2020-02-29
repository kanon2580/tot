class TagsController < ApplicationController
  def index
    @new_tag = Tag.new
  end

  def create
    new_tag = Tag.new(tag_params)
    new_tag.team_id = @team.id
    unless new_tag.save
      flash[:error] = "the tag had not save :("
    end
    redirect_back(fallback_location: root_path)
  end

  private
  def tag_params
    params.require(:tag).permit(:team_id, :name)
  end
end
