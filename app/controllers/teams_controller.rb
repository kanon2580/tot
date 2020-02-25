class TeamsController < ApplicationController
  def show
    @tags = @team.tags
  end
end
