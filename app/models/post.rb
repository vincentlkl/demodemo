class Post < ApplicationRecord
  belongs_to :category

  enum provider: { says: 0, free_malaysia: 1, the_rakyat: 2 }
  scope :ordered, -> { order(:published_at) }
  validates :url, uniqueness: true

  scope :filtered, lambda { |filters|
    result = self
    if filters.present?
      if filters[:category].present?
        result = result.where(category_id: filters[:category]) if filters[:category].present?
      end
      result
    end
  }
end
