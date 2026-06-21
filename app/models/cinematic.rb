class Cinematic < ApplicationRecord
  belongs_to :opponent, foreign_key: :opponent_slug, primary_key: :slug
  has_many :conversations, -> { order(:position) }, as: :conversable, dependent: :destroy

  validates :opponent_slug, presence: true
  validates :level, presence: true, numericality: { greater_than: 0 },
                    uniqueness: { scope: :opponent_slug }
end
