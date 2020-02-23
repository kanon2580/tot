class IssuesController < ApplicationController
  def new
    @issue = Issue.new
  end

  def create
    issue = Issue.new(issue_params)
    issue.team_id = params[:team_id]
    issue.user_id = current_user.id
    unless issue.save
      flash[:error] = "we couldn't save your issue :("
    end
      redirect_to team_issue_path(params[:team_id], issue.id)
  end

  def index
    @issues = team.issues
    # teamに関連するissuesだけ設定
  end

  def show
    @new_comment = Comment.new
    @comments = @issue.comments
  end

  def edit
  end

  def update
    if @issue.update(issue_params)
      redirect_to @issue
    else
      flash[:error] = "sorry... it was not saved successfully :( please try again."
      redirect_back(fallback_location: root_path)
    end
  end

  def destroy
    @issue.destroy 
    redirect_to team_path(team_id: params[:team_id])
  end

  def choice
  end

  def confirm
  end

  def update_status
  end

  private
  def issue_params
    params.require(:issue).permit(:user_id, :team_id, :title, :body, :has_settled, :settled_at)
  end
end
