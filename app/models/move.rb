class Move < ApplicationRecord
  self.primary_key = "slug"

  ELEMENT_TYPES = %w[normal fire water electric grass ice poison earth dark psychic].freeze

  has_many :opponent_moves, foreign_key: :move_slug, primary_key: :slug, dependent: :destroy
  has_many :opponents, through: :opponent_moves

  validates :slug, presence: true, uniqueness: true,
                   format: { with: /\A[a-zA-Z0-9_]+\z/, message: "only letters, numbers, underscores" }
  validates :name, presence: true
  validates :element_type, inclusion: { in: ELEMENT_TYPES }
  validates :mp_cost, numericality: { greater_than_or_equal_to: 0 }
  validates :base_damage, numericality: true, allow_nil: true
  validates :base_defense, numericality: { greater_than_or_equal_to: 0, only_integer: true }, allow_nil: true
  validates :damage_variance, numericality: { greater_than_or_equal_to: 0.0, less_than_or_equal_to: 1.0 }, allow_nil: true
  validates :level, numericality: { greater_than: 0 }
  validates :max_level, numericality: { greater_than: 0 }
  validates :effect_turns, numericality: { greater_than: 0, only_integer: true }, allow_nil: true
  validates :effect_damage, numericality: { greater_than_or_equal_to: 0, only_integer: true }, allow_nil: true
  validates :effect_prob, numericality: { greater_than: 0, less_than_or_equal_to: 100 }, allow_nil: true
  validates :leech, numericality: { greater_than: 0, less_than_or_equal_to: 100 }, allow_nil: true
end
