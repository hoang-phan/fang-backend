class Opponent < ApplicationRecord
  self.primary_key = "slug"

  ELEMENT_TYPES = Move::ELEMENT_TYPES

  has_many :opponent_moves, -> { order(:position) },
           foreign_key: :opponent_slug, primary_key: :slug, dependent: :destroy
  has_many :moves, through: :opponent_moves

  validates :slug, presence: true, uniqueness: true,
                   format: { with: /\A[a-zA-Z0-9_]+\z/, message: "only letters, numbers, underscores" }
  validates :name, presence: true
  validates :element_type, inclusion: { in: ELEMENT_TYPES }
  validates :max_hp, numericality: { greater_than: 0 }
  validates :base_damage, numericality: { greater_than: 0 }
  validates :damage_variance, numericality: { greater_than_or_equal_to: 0.0, less_than_or_equal_to: 1.0 }
  validates :gold_reward_min, numericality: { greater_than_or_equal_to: 0 }
  validates :gold_reward_max, numericality: { greater_than: 0 }
  validates :level, numericality: { greater_than: 0 }
  validates :xp_reward_victory, numericality: { greater_than_or_equal_to: 0 }
  validates :xp_reward_defeat, numericality: { greater_than_or_equal_to: 0 }

  def unlock_after_list
    return [] if unlock_after.blank?
    JSON.parse(unlock_after)
  rescue JSON::ParserError
    []
  end

  def unlock_after_list=(arr)
    self.unlock_after = arr.present? ? arr.to_json : nil
  end
end
