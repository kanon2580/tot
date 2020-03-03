class CommentsController < ApplicationController
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
      flash[:error] = "your comment had not save :("
    end
    redirect_back(fallback_location: root_path)
  end

  def edit
    @comment =  Comment.find(params[:comment_id])
  end

  def update
    comment = Comment.find(params[:comment_id])
    if comment.update(comment_params)
      redirect_to team_issue_path(params[:team_id], params[:issue_id])
    else
      flash[:error] = "your comment had not save :("
      redirect_back(fallback_location: root_path)
    end
  end

  def destroy
    response = @comment.response_evaluation
    if @comment.destroy
      if @issue.comments.where(user_id: current_user).present?
        oldest_comment = @issue.comments.where(user_id: current_user).order("created_at").min
        oldest_comment.update(is_first: true)
        response = ResponseEvaluation.new
        create_response_evaluation(response, oldest_comment)
      end
    else
      flash[:error] = "your comment had not delete :("
    end
    redirect_to team_issue_path(params[:team_id], params[:issue_id])
  end

  def index
    # リンク貼ってない
    comments = @team.comments.order(created_at: :desc)
    @pagenated_comments = comments.page(params[:page]).per(10)
  end

  private
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

