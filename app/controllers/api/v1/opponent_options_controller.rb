module Api
  module V1
    class OpponentOptionsController < ApplicationController
      def index
        opponents = Opponent.includes(:gifts).all.order(:name)
        render json: opponents.map { |o| serialize_opponent_option(o) }
      end

      private

      def serialize_opponent_option(opponent)
        {
          id:         opponent.slug,
          name:       opponent.name,
          giftNames:  opponent.gifts.sort_by(&:name).map { |g| parameterize(g.name) }
        }
      end

      def parameterize(str)
        str.downcase.gsub(/[^a-z0-9]+/, '-').gsub(/^-|-$/, '')
      end
    end
  end
end
