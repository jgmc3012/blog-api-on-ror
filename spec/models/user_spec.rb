require 'rails_helper'

RSpec.describe User, type: :model do
  describe "validations" do
    it "validate presense of required fields" do
      should validate_presence_of(:email)
      should validate_presence_of(:name)
      should validate_presence_of(:auth_token)
    end

    it "validate uniqueness of auth_token" do
      should validate_uniqueness_of(:auth_token)
    end

    it "validate uniqueness of email" do
      should validate_uniqueness_of(:email)
    end

    it "validate relation" do
      should have_many(:posts)
    end

  end

end
