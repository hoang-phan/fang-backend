class Conversation < ApplicationRecord
  belongs_to :conversable, polymorphic: true

  has_many :chats, -> { order(:position) }, dependent: :destroy
end
