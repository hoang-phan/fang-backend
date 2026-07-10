class Opponent < ApplicationRecord
  self.primary_key = "slug"

  ELEMENT_TYPES = Move::ELEMENT_TYPES

  # rarity => gacha pull weight (must sum to 100)
  RARITY_WEIGHTS = {
    "normal" => 60,
    "rare"   => 20,
    "sr"     => 12,
    "ssr"    => 6,
    "lr"     => 2
  }.freeze

  has_many :opponent_moves, -> { order(:position) },
           foreign_key: :opponent_slug, primary_key: :slug, dependent: :destroy
  has_many :moves, through: :opponent_moves
  has_many :cinematics, -> { order(:level) },
           foreign_key: :opponent_slug, primary_key: :slug, dependent: :destroy
  has_many :gifts, foreign_key: :opponent_slug, primary_key: :slug, dependent: :destroy
  has_many :conversations, as: :conversable, dependent: :destroy

  before_validation :ensure_gacha_key, on: :create

  validates :slug, presence: true, uniqueness: true,
                   format: { with: /\A[a-zA-Z0-9_]+\z/, message: "only letters, numbers, underscores" }
  validates :name, presence: true
  validates :element_type, inclusion: { in: ELEMENT_TYPES }
  validates :max_hp, numericality: { greater_than: 0 }
  validates :base_damage, numericality: { greater_than: 0 }
  validates :damage_variance, numericality: { greater_than_or_equal_to: 0.0, less_than_or_equal_to: 1.0 }
  validates :gold_reward, numericality: { greater_than_or_equal_to: 0 }
  validates :xp_reward, numericality: { greater_than_or_equal_to: 0 }
  validates :gacha_key, presence: true, uniqueness: true

  enum :rarity, {
    normal: 0,
    rare: 1,
    sr: 2,
    ssr: 3,
    lr: 4
  }, default: :normal

  class << self
    # Weighted-random rarity (re-rolled among rarities that have at least one
    # opponent), then a random opponent within that rarity. Returns nil only
    # if there are no opponents at all.
    def gacha_pull
      counts = group(:rarity).count
      weights = RARITY_WEIGHTS.slice(*counts.select { |_, c| c.positive? }.keys)
      return nil if weights.empty?

      where(rarity: pick_weighted_rarity(weights)).order(Arel.sql("RANDOM()")).first
    end

    private

    def pick_weighted_rarity(weights)
      total = weights.values.sum
      roll = rand(total)
      cumulative = 0
      weights.each do |rarity, weight|
        cumulative += weight
        return rarity if roll < cumulative
      end
      weights.keys.last
    end
  end

  def unlock_after_list
    return [] if unlock_after.blank?
    JSON.parse(unlock_after)
  rescue JSON::ParserError
    []
  end

  def unlock_after_list=(arr)
    self.unlock_after = arr.present? ? arr.to_json : nil
  end

  private

  def ensure_gacha_key
    self.gacha_key = SecureRandom.urlsafe_base64(16) if gacha_key.blank?
  end
end
