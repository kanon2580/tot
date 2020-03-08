class SearchController < ApplicationController

  def issues
    if params[:target] == "title"
      splited_q = params[:q].split(/[[:blank:]]+/)
      issues = []
      splited_q.each do |q|
        next if q == ""
        issues += @team.issues.where('title LIKE ?', "%#{q}%")
      end
      # order、reveseで新しい順にしたいけどできなかったTT
      # orderかpageにnomethod error
      issues.uniq!
      issues = issues.select{|issue| issue.has_settled == true} if params[:status] == "settled"
      issues = issues.select{|issue| issue.has_settled == false} if params[:status] == "unsettled"
    elsif params[:target] == "body"
      splited_q = params[:q].split(/[[:blank:]]+/)
      issues = []
      splited_q.each do |q|
        next if q == ""
        issues += @team.issues.where('body LIKE ?', "%#{q}%")
      end
      issues.uniq!
      issues = issues.select{|issue| issue.has_settled == true} if params[:status] == "settled"
      issues = issues.select{|issue| issue.has_settled == false} if params[:status] == "unsettled"
    elsif params[:target] == "tag"
      splited_q = params[:q].split(/[[:blank:]]+/)
      issues = []
      splited_q.each do |q|
        next if q == ""
        issues += @team.issues.joins(:tags).where('tags.name LIKE ?', "%#{q}%")
      end
      issues.uniq!
      issues = issues.select{|issue| issue.has_settled == true} if params[:status] == "settled"
      issues = issues.select{|issue| issue.has_settled == false} if params[:status] == "unsettled"
    elsif params[:target] == "user"
      splited_q = params[:q].split(/[[:blank:]]+/)
      issues = []
      splited_q.each do |q|
        next if q == ""
        issues += @team.issues.joins(:user).where('users.name LIKE ?', "%#{q}%")
      end
      issues.uniq!
      issues = issues.select{|issue| issue.has_settled == true} if params[:status] == "settled"
      issues = issues.select{|issue| issue.has_settled == false} if params[:status] == "unsettled"
    else
      issues = @team.issues
      issues = issues.where(has_settled: true) if params[:status] == "settled"
      issues = issues.where(has_settled: false) if params[:status] == "unsettled"
    end
    @pagenated_issues = Kaminari.paginate_array(issues).page(params[:page]).per(10)
    render template: "issues/index"
  end

  def users
    splited_q = params[:q].split(/[[:blank:]]+/)
    users = []
    splited_q.each do |q|
      next if q == ""
      users += @team.users.where('name LIKE ?', "%#{q}%").order(created_at: :desc)
    end
    users.uniq!
    @pagenated_users = Kaminari.paginate_array(users).page(params[:page]).per(12)
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
