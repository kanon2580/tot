class SearchController < ApplicationController

  def issues
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

  def users
    users = @team.users.where('name LIKE ?', "%#{params[:q]}%")
    @pagenated_users = users.page(params[:page]).per(12)
    render template: "users/index"
  end

  def tags
    splited_q = params[:q].split(/[[:blank:]]+/)

    @tags = []
    splited_q.each do |q|
      next if q == ""
      @tags += @team.tags.where('LOWER(name) LIKE ?', "%#{q}%".downcase)
    end
    @tags.uniq!
    @new_tag = Tag.new
    render template: "tags/index"
  end
end
