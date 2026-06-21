module Api
  module V1
    class GiftsController < ApplicationController
      before_action :set_opponent
      before_action :set_gift, only: %i[show update destroy]

      def index
        @gifts = @opponent.gifts.order(:name)
        render json: @gifts.map { |g| serialize_gift(g) }
      end

      def show
        render json: serialize_gift(@gift)
      end

      def create
        @gift = @opponent.gifts.build(gift_params)

        if @gift.save
          render json: serialize_gift(@gift), status: :created
        else
          render json: { errors: @gift.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def update
        @gift.assign_attributes(gift_params)

        if @gift.save
          render json: serialize_gift(@gift)
        else
          render json: { errors: @gift.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def destroy
        @gift.destroy
        head :no_content
      end

      private

      def set_opponent
        @opponent = Opponent.find(params[:opponent_id])
      end

      def set_gift
        @gift = @opponent.gifts.find(params[:id])
      end

      def gift_params
        params.expect(gift: [ :name, :gold, :exp ])
      end

      def serialize_gift(gift)
        {
          id:           gift.id,
          opponentId:   gift.opponent_slug,
          name:         gift.name,
          gold:         gift.gold,
          exp:          gift.exp
        }
      end
    end
  end
end
