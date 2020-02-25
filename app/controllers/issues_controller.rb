class IssuesController < ApplicationController
  def new
  end

  def create
    issue = Issue.new(issue_params)
    issue.team = @team
    issue.user = current_user
    if issue.save
      if params[:tagging]
          params[:tagging][:tag_ids].each do |tag|
          tagging = Tagging.new
          tagging.tag_id = tag
          tagging.issue = issue
          tagging.save
        end
      end
    else
      flash[:error] = "we couldn't save your issue :("
    end
      redirect_to team_issue_path(params[:team_id], issue.id)
  end

  def index
    @issues = @team.issues
    # teamに関連するissuesだけ設定
    @tags = @team.tags
    @team_members = TeamMember.where(team_id: @team.id)
  end

  def show
    @new_comment = Comment.new
    @comments = @issue.comments
    @tagging = Tagging.where(issue_id: @issue)
  end

  def edit
  end

  def update
    if @issue.update(issue_params)
      redirect_to team_issue_path(@issue)
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
    @comments = @issue.comments
  end

  def confirm
  end

  def settled
    @issue.update(has_settled: true)
    @comment.update(has_best_answer: true)
    evaluated_comments = @issue.comments.where(is_first: true)
    binding.pry
    evaluated_comments.each do |comment|
      required_time = RequiredTimeEvaluation.new
      required_time.user = comment.user
      required_time.comment = comment
      required_time.first_comment_created_at = comment.created_at
      required_time.issue_settled_at = @issue.updated_at
      semi_difference = required_time.issue_settled_at - required_time.first_comment_created_at
      required_time.difference = semi_difference / 3600
      required_time.save
    end
    redirect_to team_issue_path(@issue)
  end

  private
  def issue_params
    params.require(:issue).permit(:user_id, :team_id, :title, :body, :has_settled, :settled_at, {tag_ids: []} )
  end

end
