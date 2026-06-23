class Item < ApplicationRecord
  self.primary_key = "slug"

  CATEGORIES = %w[headgear bodyArmor weapon shield amulet ring charm gauntlets boots].freeze
  QUALITIES   = %w[rude normal rare legendary].freeze

  validates :slug,     presence: true, uniqueness: true,
                       format: { with: /\A[a-zA-Z0-9_]+\z/, message: "only letters, numbers, underscores" }
  validates :name,     presence: true
  validates :icon,     presence: true
  validates :category, inclusion: { in: CATEGORIES }
  validates :quality,  inclusion: { in: QUALITIES }
  validates :base_damage,  numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
  validates :base_defense, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
end
