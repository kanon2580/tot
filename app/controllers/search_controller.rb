class SearchController < ApplicationController

  def issues
    issues = Issue.search(@team, params[:target], params[:status], params[:q])
    @pagenated_issues = Kaminari.paginate_array(issues).page(params[:page]).per(10)
    render template: "issues/index"
  end

  def users
    users = User.search(@team, params[:q])
    @pagenated_users = Kaminari.paginate_array(users).page(params[:page]).per(12)
    render template: "users/index"
  end

  def tags
    tags = Tag.search(@team, params[:q])
    @pagenated_tags = Kaminari.paginate_array(tags).page(params[:page]).per(30)
    @new_tag = Tag.new
    render template: "tags/index"
  end

  def issue_form_tags
    tags = Tag.search(@team, params[:q])
    @tags = Kaminari.paginate_array(tags).page(params[:page]).per(30)
    @new_issue = Issue.new
  end
end
