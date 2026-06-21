class Sprite < ApplicationRecord
  belongs_to :spriteable, polymorphic: true

  validates :url, presence: true
end
