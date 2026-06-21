class Chat < ApplicationRecord
  belongs_to :conversation

  validates :avatar,   presence: true
  validates :content,  presence: true
  validates :position, numericality: { greater_than_or_equal_to: 0 }
end
