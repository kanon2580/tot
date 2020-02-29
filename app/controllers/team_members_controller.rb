class TeamMembersController < ApplicationController
  def new
  end

  def create
    team = Team.find_by(name: params[:team_member][:team_name])
    team_member = TeamMember.new(team_member_params)
    team_member.user = current_user
    if team.present?
      team_member.team = team
      team_member.save
      redirect_to team_path(team)
      # todo => unique引っかかった時のerror message
    else
      @join_team = TeamMember.new
      flash[:error] = "The team not found ..."
      redirect_back(fallback_location: root_path)
    end
  end

  private
  def team_member_params
    params.require(:team_member).permit(:user_id, :team_id)
  end
end
