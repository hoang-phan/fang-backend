class OpponentMove < ApplicationRecord
  belongs_to :opponent, foreign_key: :opponent_slug, primary_key: :slug
  belongs_to :move, foreign_key: :move_slug, primary_key: :slug

  validates :position, numericality: { greater_than_or_equal_to: 0, less_than: 4 }
  validates :opponent_slug, uniqueness: { scope: :position }
end
