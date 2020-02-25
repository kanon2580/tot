class TeamsController < ApplicationController
  def show
    @tags = @team.tags
    @team_members = TeamMember.where(team_id: @team.id)
    @issues = @team.issues
  end
end
