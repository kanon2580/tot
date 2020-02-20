class IssuesController < ApplicationController
  def new
    @issue = Issue.new
  end

  def create
    @issue = Issue.new(issue_params)
    issue.team_id = params[:team_id]
    issue.user_id = current_user.id
    if issue.save
      redirect_to team_issue_path(@issue)
    else
      flash[:error] = "we couldn't save your issue :("
      redirect_back(fallback_location: root_path)
    end
  end

  def index
  end

  def show
  end

  def edit
  end

  def update
  end

  def destroy
  end

  def choice
  end

  def confirm
  end

  def update_status
  end

  private
  def issue_params
    params.require(:issue).permit(:user_id, :team_id, :body, :has_settled, :settled_at)
  end
end
