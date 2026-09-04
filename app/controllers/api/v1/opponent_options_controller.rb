# frozen_string_literal: true

module Api
  module V1
    # Legacy alias for GET /api/v1/editor/characters (giftNames shape for old editors).
    class OpponentOptionsController < ApplicationController
      def index
        provider = ConversationEditor.configuration.character_provider
        characters = provider ? provider.characters : []

        render json: characters.map { |c|
          {
            id: c[:id] || c["id"],
            name: c[:name] || c["name"],
            giftNames: (c[:slots] || c["slots"] || [])
              .select { |s| (s[:kind] || s["kind"]) == "gift" }
              .map { |s| s[:key] || s["key"] }
          }
        }
      end
    end
  end
end
