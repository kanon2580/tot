require 'rails_helper'

RSpec.describe Team, type: :model do

  context "正しいデータのとき" do
    before do
      @team = Team.new
      @team.name = "test"
      @team.save
    end

    it "保存される" do
      expect(@team).to be_valid
    end
  end

  context "誤ったデータのとき" do
    before do
      @team = Team.new
      @team.name = ""
      @team.save
    end

    it "保存されない" do
      expect(@team).to be_invalid
      expect(@team.errors[:name]).to include("can't be blank")
    end
  end
end
