class User < ApplicationRecord
  has_many :posts

  validates :name, presence: true
  validates :email, presence: true, uniqueness: true
  validates :auth_token, presence: true,uniqueness: true
end
