require 'rails_helper'

RSpec.describe Post, type: :model do
  describe "validations" do
    it "Validate presense of required fields" do
      should validate_presence_of(:title)
      should validate_presence_of(:user_id)
      should validate_presence_of(:content)
      should validate_inclusion_of(:published).in_array([true, false])
    end

  end
end
