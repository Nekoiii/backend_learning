class User < ApplicationRecord
  has_many :records

  validates :name, presence: true 
end
