module Api
  module V1
    class GachaController < ApplicationController
      include OpponentSerialization

      def pull
        picked = Opponent.gacha_pull
        return render json: { errors: [ "No opponents available" ] }, status: :unprocessable_entity unless picked

        opponent = Opponent.includes(:moves, { cinematics: { conversations: { chats: :sprites } } }, { gifts: { conversations: { chats: :sprites } } }, { conversations: { chats: :sprites } })
                            .find(picked.slug)
        timestamp = Time.now.to_i

        render json: serialize_opponent(opponent, timestamp: timestamp)
      end
    end
  end
end
