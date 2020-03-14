class TeamMembersController < ApplicationController
  def new
    @teams = current_user.teams.reverse
    @new_team_mamber = TeamMember.new
  end

  def create
    team_name = params[:team_member][:team_name]
    team_id = params[:team_member][:team_id]
    team = Team.find_by(id: team_id, name: team_name)
    if team.present?
      team_member = TeamMember.new(team_member_params)
      team_member.user = current_user
      team_member.team = team
      team_member.save
      redirect_to team_path(team)
    else
      @join_team = TeamMember.new
      flash[:error] = "The team not found."
      redirect_back(fallback_location: root_path)
    end
  end

  private
  def team_member_params
    params.require(:team_member).permit(:user_id, :team_id)
  end
end
