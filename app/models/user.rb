class User < ApplicationRecord
  has_many :posts

  validates :name, presence: true
  validates :email, presence: true, uniqueness: true
  validates :auth_token, presence: true,uniqueness: true

  after_initialize :generate_auth_token

  def generate_auth_token
    if !self.auth_token
      self.auth_token = SecureRandom.hex
    end
  end
end
