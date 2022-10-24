class Category < ApplicationRecord
  has_many :posts, dependent: :nullify
  validates :name, uniqueness: true

  scope :ordered, -> { order(:name) }
end
