class Gift < ApplicationRecord
  belongs_to :opponent, foreign_key: :opponent_slug, primary_key: :slug
  has_many :conversations, -> { order(:position) }, as: :conversable, dependent: :destroy

  validates :opponent_slug, presence: true
  validates :name, presence: true
  validates :gold, numericality: { greater_than_or_equal_to: 0 }
  validates :exp,  numericality: { greater_than_or_equal_to: 0 }
end
