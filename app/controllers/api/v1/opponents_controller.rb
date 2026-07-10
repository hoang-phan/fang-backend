module Api
  module V1
    class OpponentsController < ApplicationController
      include OpponentSerialization

      before_action :set_opponent, only: %i[show update destroy]

      def index
        timestamp = params[:timestamp]
        encrypted_keys = Array(params[:keys])

        gacha_keys = encrypted_keys.filter_map do |encrypted_key|
          GachaCipher.decrypt(encrypted_key, timestamp)
        rescue GachaCipher::ExpiredError, GachaCipher::InvalidError
          nil
        end

        @opponents = Opponent.where(gacha_key: gacha_keys)
                              .includes(:moves, { cinematics: { conversations: { chats: :sprites } } }, { gifts: { conversations: { chats: :sprites } } }, { conversations: { chats: :sprites } })
                              .order(:name)
        render json: @opponents.map { |o| serialize_opponent(o, timestamp: timestamp) }
      end

      def show
        render json: serialize_opponent(@opponent)
      end

      def create
        @opponent = Opponent.new(opponent_params)
        @opponent.unlock_after_list = params.dig(:opponent, :unlock_after) || []
        assign_moves(@opponent) if params.dig(:opponent, :move_slugs)
        assign_cinematics(@opponent) if params.dig(:opponent, :cinematics)

        if @opponent.save
          render json: serialize_opponent(@opponent), status: :created
        else
          render json: { errors: @opponent.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def update
        @opponent.assign_attributes(opponent_params)
        @opponent.unlock_after_list = params.dig(:opponent, :unlock_after) if params.dig(:opponent, :unlock_after)
        assign_moves(@opponent) if params.dig(:opponent, :move_slugs)
        assign_cinematics(@opponent) if params.dig(:opponent, :cinematics)

        if @opponent.save
          render json: serialize_opponent(@opponent)
        else
          render json: { errors: @opponent.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def destroy
        @opponent.destroy
        head :no_content
      end

      private

      def set_opponent
        @opponent = Opponent.includes(:moves, { cinematics: { conversations: { chats: :sprites } } }, { gifts: { conversations: { chats: :sprites } } }, { conversations: { chats: :sprites } }).find(params[:id])
      end

      def opponent_params
        params.expect(opponent: [ :slug, :name, :element_type, :rarity, :max_hp,
                                   :base_damage, :damage_variance, :gold_reward,
                                   :xp_reward, :flavour_text, :avatar ])
      end

      def assign_moves(opponent)
        move_slugs = Array(params.dig(:opponent, :move_slugs)).first(4)
        opponent.opponent_moves.destroy_all if opponent.persisted?
        move_slugs.each_with_index do |slug, i|
          opponent.opponent_moves.build(move_slug: slug, position: i)
        end
      end

      def assign_cinematics(opponent)
        cinematic_data = Array(params.dig(:opponent, :cinematics))
        opponent.cinematics.destroy_all if opponent.persisted?
        cinematic_data.each do |c|
          cinematic = opponent.cinematics.build(
            level:             c[:level].to_i,
            description:       c[:description],
            relationship_gain: c[:relationship_gain].presence&.to_i
          )
          if c[:background_url].present?
            cinematic.conversations.build(background_url: c[:background_url], position: 0)
          end
        end
      end
    end
  end
end
