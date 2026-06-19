module Api
  module V1
    class MovesController < ApplicationController
      before_action :set_move, only: %i[show update destroy]

      def index
        @moves = Move.all.order(:name)
        render json: @moves.map { |m| serialize_move(m) }
      end

      def show
        render json: serialize_move(@move)
      end

      def create
        @move = Move.new(move_params)
        if @move.save
          render json: serialize_move(@move), status: :created
        else
          render json: { errors: @move.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def update
        if @move.update(move_params)
          render json: serialize_move(@move)
        else
          render json: { errors: @move.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def destroy
        @move.destroy
        head :no_content
      end

      private

      def set_move
        @move = Move.find(params[:id])
      end

      def move_params
        params.expect(move: [ :slug, :name, :icon, :description, :element_type,
                               :mp_cost, :base_damage, :damage_variance, :level, :max_level,
                               :effect_turns, :effect_damage, :effect_prob, :leech ])
      end

      def serialize_move(move)
        hash = {
          id: move.slug,
          name: move.name,
          icon: move.icon,
          description: move.description,
          type: move.element_type,
          mpCost: move.mp_cost,
          baseDamage: move.base_damage,
          damageVariance: move.damage_variance,
          level: move.level,
          maxLevel: move.max_level
        }
        hash[:effectTurns]  = move.effect_turns  unless move.effect_turns.nil?
        hash[:effectDamage] = move.effect_damage unless move.effect_damage.nil?
        hash[:effectProb]   = move.effect_prob   unless move.effect_prob.nil?
        hash[:leech]        = move.leech         unless move.leech.nil?
        hash
      end
    end
  end
end
