class ApplicationController < ActionController::Base
  before_action :configure_permitted_parameters, if: :devise_controller?

  # before_action :set_team, if: :request.fullpath.include?(params[:team_id])
  # before_action :set_issue, if: :request.fullpath.include?(params[:issue_id])
  # before_action :set_user, if: :request.fullpath.include?(params[:user_id])
  # before_action :set_comment, if: :request.fullpath.include?(params[:comment_id])

  private
  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:name])
  end

  def after_sign_in_path_for(resource)
    mypage_path(current_user)
  end

  def set_team
    @team = Team.find(params[:team_id])
  end

  def set_issue
    @issue = Issue.find(params[:issue_id])
  end

  def set_user
    @user = User.find(params[:user_id])
  end

  def set_comment
    @comment = Comment.find(params[:comment_id])
  end
end
