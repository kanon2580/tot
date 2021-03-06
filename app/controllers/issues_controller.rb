class IssuesController < ApplicationController
  before_action :only_team_user
  before_action :only_current_user, except: [:new, :create, :index, :show]

  impressionist :actions => [:show]

  def new
    @page_title = "New issue"
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
      flash.now[:error] = "タイトルか本文が空欄のようです。もう一度お試しください。"
      render :new
    end
      redirect_to team_issue_path(@team, issue)
  end

  def index
    @page_title = "Issues"
    if @team.present? && @user.present?
      issues = @team.issues.where(user_id: @user).order(created_at: :desc)
    elsif @team.present? && @tag.present?
      issues = @tag.issues.order(created_at: :desc)
    elsif @team.present?
      issues = @team.issues.order(created_at: :desc)
    else
      issues = @user.issues.order(created_at: :desc)
    end
    @pagenated_issues = issues.page(params[:page]).per(10)
  end

  def show
    @page_title = "Issue"
    @new_comment = Comment.new
    @comments = @issue.comments
    impressionist(@issue, nil, unique: [:user_id])
  end

  def edit
    @page_title = "Edit issue"
  end

  def update
    if @issue.update(issue_params)
      redirect_to team_issue_path(@team, @issue)
    else
      flash[:error] = "タイトルか本文が空欄のようです。もう一度お試しください。"
      redirect_back(fallback_location: root_path)
    end
  end

  def destroy
    unless @issue.destroy
      flash[:error] = "イシューが削除されませんでした。もう一度お試しください。"
      redirect_back(fallback_location: root_path)
    end
    redirect_to team_issues_path(@team)
  end

  def choice
    @page_title = "Choose the best answer."
    if @issue.comments == []
      flash[:error] = "この問題にはまだコメントがされていません。もう少し待ちましょう。"
      redirect_back(fallback_location: root_path)
    end
    @comments = @issue.comments
  end

  def confirm
    @page_title = "Once you decide, you can't undo."
  end

  def settled
    @issue.update(has_settled: true)
    @comment.update(has_best_answer: true)
    evaluated_comments = @issue.comments.where(is_first: true)
    create_required_time_evaluation(evaluated_comments)
    redirect_to team_issue_path(@team)
  end

  private
  def only_team_user
    unless TeamMember.where(team_id: @team).any? {|team| team.user_id == current_user.id}
      redirect_to mypage_path(current_user)
    end
  end

  def only_current_user
    unless @issue.user == current_user
      redirect_to team_path(@team)
    end
  end

  def issue_params
    params.require(:issue).permit(:user_id, :team_id, :title, :body, :has_settled, :settled_at, {tag_ids: []} )
  end

  def create_required_time_evaluation(evaluated_comments)
    evaluated_comments.each do |comment|
      required_time = RequiredTimeEvaluation.new
      required_time.user = comment.user
      required_time.comment = comment
      required_time.first_comment_created_at = comment.created_at
      required_time.issue_settled_at = @issue.updated_at
      semi_difference = required_time.issue_settled_at - required_time.first_comment_created_at
      required_time.difference = (semi_difference / 60).ceil
      required_time.save
    end
  end

end
