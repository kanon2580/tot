class LikesController < ApplicationController
  def create
    like = current_user.likes.new(issue_id: @issue.id)
    like.save
    redirect_back(fallback_location: root_path)
  end

  def destroy
    like = @issue.likes.find_by(user_id: current_user)
    like.destroy
    redirect_back(fallback_location: root_path)
  end
end
