class Chat < ApplicationRecord
  belongs_to :conversation

  validates :content,  presence: true
  validates :position, numericality: { greater_than_or_equal_to: 0 }

  has_many :sprites, as: :spriteable, dependent: :destroy

  enum :role, {
    hero: 0,
    opponent: 1,
    other: 2
  }
end
