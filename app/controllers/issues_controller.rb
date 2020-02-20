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
  end

  def show
    @issue = Issue.find(params[:id])
    @comment = Comment.new
    @comments = @issue.comments
  end

  def edit
    @issue = Issue.find(params[:id])
  end

  def update
    issue = Issue.find(params[:id])
    if issue.update(issue_params)
      redirect_to team_issue_path(issue)
    else
      flash[:error] = "sorry... it was not saved successfully :( please try again."
      redirect_back(fallback_location: root_path)
    end
  end

  def destroy
    issue = Issue.find(params[:id])
    issue.destroy 
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
