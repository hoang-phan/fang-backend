module Api
  module V1
    class OpponentsController < ApplicationController
      before_action :set_opponent, only: %i[show update destroy]

      def index
        @opponents = Opponent.includes(:moves).all.order(:name)
        render json: @opponents.map { |o| serialize_opponent(o) }
      end

      def show
        render json: serialize_opponent(@opponent)
      end

      def create
        @opponent = Opponent.new(opponent_params)
        @opponent.unlock_after_list = params.dig(:opponent, :unlock_after) || []
        assign_moves(@opponent) if params.dig(:opponent, :move_slugs)

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
        @opponent = Opponent.includes(:moves).find(params[:id])
      end

      def opponent_params
        params.expect(opponent: [ :slug, :name, :element_type, :max_hp,
                                   :base_damage, :damage_variance, :gold_reward_min,
                                   :gold_reward_max, :flavour_text, :level,
                                   :xp_reward_victory, :xp_reward_defeat,
                                   :avatar_1, :avatar_2, :avatar_3, :avatar_4, :avatar_5,
                                   :cinematic_1, :cinematic_2, :cinematic_3, :cinematic_4, :cinematic_5 ])
      end

      def assign_moves(opponent)
        move_slugs = Array(params.dig(:opponent, :move_slugs)).first(4)
        opponent.opponent_moves.destroy_all if opponent.persisted?
        move_slugs.each_with_index do |slug, i|
          opponent.opponent_moves.build(move_slug: slug, position: i)
        end
      end

      def serialize_opponent(opponent)
        moves_by_pos = opponent.opponent_moves.sort_by(&:position).map { |om|
          serialize_move(om.move)
        }

        {
          id: opponent.slug,
          name: opponent.name,
          type: opponent.element_type,
          maxHp: opponent.max_hp,
          baseDamage: opponent.base_damage,
          damageVariance: opponent.damage_variance,
          goldReward: [ opponent.gold_reward_min, opponent.gold_reward_max ],
          flavourText: opponent.flavour_text,
          level: opponent.level,
          xpReward: [ opponent.xp_reward_victory, opponent.xp_reward_defeat ],
          unlockAfter: opponent.unlock_after_list,
          moves: moves_by_pos,
          avatars: (1..5).map { |n| opponent.public_send(:"avatar_#{n}") }.compact,
          cinematics: (1..5).map { |n| opponent.public_send(:"cinematic_#{n}") }.compact
        }
      end

      def serialize_move(move)
        return nil unless move
        {
          id: move.slug,
          name: move.name,
          description: move.description,
          type: move.element_type,
          mpCost: move.mp_cost,
          baseDamage: move.base_damage,
          damageVariance: move.damage_variance,
          level: move.level,
          maxLevel: move.max_level,
          effectTurns: move.effect_turns,
          effectDamage: move.effect_damage,
          effectProb: move.effect_prob,
          leech: move.leech,
          baseDefense: move.base_defense,
          effectStun: move.effect_stun
        }
      end
    end
  end
end
