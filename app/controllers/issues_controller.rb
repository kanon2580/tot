class IssuesController < ApplicationController
  before_action :only_team_user
  before_action :only_current_user, except: [:new, :create, :index, :show]

  helper_method :display_true

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
      flash.now[:error] = "タイトルか本文が空欄のようです。もう一度お試しください。"
      render :new
      # 表示されない何で
    end
      redirect_to team_issue_path(@team, issue)
  end

  def index
    if @team.present? && @user.present?
      issues = @team.issues.where(user_id: @user).order(created_at: :desc)
      @tags = @team.tags
    elsif @team.present?
      issues = @team.issues.order(created_at: :desc)
      @tags = @team.tags
    else
      issues = @user.issues.order(created_at: :desc)
    end

    @pagenated_issues = issues.page(params[:page]).per(10)
  end

  def show
    @new_comment = Comment.new
    @comments = @issue.comments
  end

  def edit
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
    if @issue.comments == []
      flash[:error] = "迅速に問題を解決する姿勢がステキ！ですがこの問題にはコメントがされていません。もう少し待ちましょう。"
      redirect_back(fallback_location: root_path)
    end
    @comments = @issue.comments
  end

  def confirm
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

  def display_true
    @issue.has_settled == false && @issue.user == current_user && action_name == 'show'
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
