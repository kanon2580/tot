class ApplicationController < ActionController::Base
  before_action :configure_permitted_parameters, if: :devise_controller?

  before_action :set_team
  before_action :set_issue
  before_action :set_user
  before_action :set_comment
  # 条件分岐、path拾わなくてもパラメータ送られてるか否かで分岐すれば良くない？って結論に至る

  private
  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:name])
  end

  def after_sign_in_path_for(resource)
    mypage_path(current_user)
  end

  def set_team
    if params[:team_id].present?
      @team = Team.find(params[:team_id])
    end
  end

  def set_issue
    if params[:issue_id].present?
      @issue = Issue.find(params[:issue_id])
    end
  end

  def set_user
    if params[:user_id].present?
      @user = User.find(params[:user_id])
    end
  end

  def set_comment
    if params[:comment_id].present?
      @comment = Comment.find(params[:comment_id])
    end
  end
 
end
