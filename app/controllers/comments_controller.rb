class CommentsController < ApplicationController
  before_action :only_team_user
  before_action :only_current_user, only: [:edit, :update, :destroy]

  def create
    issue = Issue.find(params[:issue_id])
    comment = Comment.new(comment_params)
    comment.user = current_user
    comment.issue_id = params[:issue_id]
    comment.is_first = true if issue.comments.where(user_id: current_user).blank?
    if comment.save(comment_params)
      if comment.is_first == true
        response = ResponseEvaluation.new
        create_response_evaluation(response, comment)
      end
    else
      flash[:error] = "コメントが空欄のようです。もう一度お試しください。"
    end
    redirect_back(fallback_location: root_path)
  end

  def edit
  end

  def update
    if @comment.update(comment_params)
      redirect_to team_issue_path(params[:team_id], params[:issue_id])
    else
      flash[:error] = "コメントが空欄のようです。もう一度お試しください。"
      redirect_back(fallback_location: root_path)
    end
  end

  def destroy
    if @comment.destroy
      if @issue.comments.where(user_id: current_user).present?
        oldest_comment = @issue.comments.where(user_id: current_user).order("created_at").min
        oldest_comment.update(is_first: true)
        response = ResponseEvaluation.new
        create_response_evaluation(response, oldest_comment)
      end
    else
      flash[:error] = "コメントが削除できませんでした。もう一度お試しください。"
    end
    redirect_to team_issue_path(params[:team_id], params[:issue_id])
  end

  def index
    # リンク貼ってない
    comments = @team.comments.order(created_at: :desc)
    @pagenated_comments = comments.page(params[:page]).per(10)
  end

  private
  def only_team_user
    unless TeamMember.where(team_id: @team).any? {|team| team.user_id == current_user.id}
      redirect_to mypage_path(current_user)
    end
  end

  def only_current_user
    unless @comment.user == current_user
      redirect_to team_path(@team)
    end
  end

  def comment_params
    params.require(:comment).permit(:user_id, :issue_id, :comment)
  end

  def create_response_evaluation(response, comment)
    response.user = current_user
    response.comment = comment
    response.created_issue_at = comment.issue.created_at
    response.first_comment_created_at = Time.current
    semi_difference = response.first_comment_created_at - response.created_issue_at
    response.difference = (semi_difference / 60).ceil
    response.save
  end

end

