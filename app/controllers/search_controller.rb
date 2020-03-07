class SearchController < ApplicationController

  def issue
    if params[:target] == "title"
      issues = @team.issues.where('title LIKE ?', "%#{params[:q]}%").order(created_at: :desc)
      issues = issues.where(has_settled: true) if params[:status] == "settled"
      issues = issues.where(has_settled: false) if params[:status] == "unsettled"
    elsif params[:target] == "body"
      issues = @team.issues.where('body LIKE ?', "%#{params[:q]}%").order(created_at: :desc)
      issues = issues.where(has_settled: true) if params[:status] == "settled"
      issues = issues.where(has_settled: false) if params[:status] == "unsettled"
    elsif params[:target] == "tag"
      issues = @team.issues.joins(:tags).where('tags.name LIKE ?', "%#{params[:q]}%").order(created_at: :desc)
      issues = issues.where(has_settled: true) if params[:status] == "settled"
      issues = issues.where(has_settled: false) if params[:status] == "unsettled"
    elsif params[:target] == "user"
      issues = @team.issues.joins(:user).where('users.name LIKE ?', "%#{params[:q]}%").order(created_at: :desc)
      issues = issues.where(has_settled: true) if params[:status] == "settled"
      issues = issues.where(has_settled: false) if params[:status] == "unsettled"
    end
    @pagenated_issues = issues.page(params[:page]).per(10)
    render template: "issues/index"
  end
end
