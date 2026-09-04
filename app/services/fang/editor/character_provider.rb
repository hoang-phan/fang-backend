# frozen_string_literal: true

module Fang
  module Editor
    class CharacterProvider < ConversationEditor::CharacterProvider
      CINEMATIC_LEVELS = (1..5).to_a.freeze

      def characters
        Opponent.includes(:gifts, :cinematics).order(:name).map { |o| serialize_character(o) }
      end

      private

      def serialize_character(opponent)
        {
          id: opponent.slug,
          name: opponent.name,
          slots: build_slots(opponent)
        }
      end

      def build_slots(opponent)
        slots = [
          {
            kind: "chat",
            key: "chat",
            label: "Chat",
            filename: "#{opponent.slug}-conversations.yml"
          }
        ]

        opponent.gifts.sort_by(&:name).each do |gift|
          key = parameterize(gift.name)
          slots << {
            kind: "gift",
            key: key,
            label: gift.name,
            filename: "#{opponent.slug}-gift-#{key}.yml"
          }
        end

        levels = (CINEMATIC_LEVELS + opponent.cinematics.map(&:level)).uniq.sort
        levels.each do |level|
          slots << {
            kind: "cinematic",
            key: level.to_s,
            label: "Cinematic #{level}",
            filename: "#{opponent.slug}-cinematic-#{level}.yml"
          }
        end

        slots
      end

      def parameterize(str)
        str.downcase.gsub(/[^a-z0-9]+/, "-").gsub(/^-|-$/, "")
      end
    end
  end
end
