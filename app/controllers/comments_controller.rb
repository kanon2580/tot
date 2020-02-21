class CommentsController < ApplicationController
  def create
    issue = Issue.find(params[:issue_id])
    comment = Comment.new(comment_params)
    comment.user = current_user
    comment.issue_id = params[:issue_id]
    byebug

    if issue.comments.where(user_id: current_user).blank?
      evaluation = ResponseEvaluation.new
      evaluation.user = current_user
      evaluation.issue = comment.issue
      evaluation.created_issue_at = issue.created_at
      evaluation.first_comment_created_at = Time.current
      semi_difference = evaluation.first_comment_created_at - evaluation.created_issue_at
      evaluation.difference = semi_difference / 3600
      unless evaluation.save
        redirect_back(fallback_location: root_path)
      end
      # レスポンス評価の追加。ほんと汚い絶対メソッド化。
      # ストロングパラメータ効かないぽい。
    end
    unless comment.save(comment_params)
      flash[:error] = "your comment had not save :("
    end
    redirect_back(fallback_location: root_path)
  end

  def edit
    @comment =  Comment.find(params[:id])
  end

  def update
    comment = Comment.find(params[:id])
    if comment.update(comment_params)
      redirect_to team_issue_path(params[:team_id], params[:issue_id])
    else
      flash[:error] = "your comment had not save :("
      redirect_back(fallback_location: root_path)
    end
  end

  def destroy
    comment = Comment.find(params[:id])
    comment.destroy
    redirect_to team_issue_path(params[:team_id], params[:issue_id])
  end

  def indew
    @user = User.find(params[:user_id])
    @comments = @user.comments
  end

  private
  def comment_params
    params.require(:comment).permit(:user_id, :issue_id, :comment)
  end

  def response_evaluation_params
    params.require(:response_evaluation).permit(:user_id, :issue_id, :created_issue_at, :first_comment_created_at, :difference)
  end
end
