class ApplicationController < ActionController::Base
  before_action :authenticate_user!
  before_action :configure_permitted_parameters, if: :devise_controller?

  before_action :set_team
  before_action :set_issue
  before_action :set_user
  before_action :set_comment
  before_action :set_tag

  private
  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:name])
  end

  def after_sign_in_path_for(resource)
    mypage_path(current_user)
  end

  def set_team
    @team = Team.find(params[:team_id]) if params[:team_id].present?
  end

  def set_issue
    @issue = Issue.find(params[:issue_id]) if params[:issue_id].present?
  end

  def set_user
    @user = User.find(params[:user_id]) if params[:user_id].present?
  end

  def set_comment
    @comment = Comment.find(params[:comment_id]) if params[:comment_id].present?
  end

  def set_tag
    @tag = Tag.find(params[:tag_id])  if params[:tag_id].present?
  end
 
end
