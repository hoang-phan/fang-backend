module Api
  module V1
    class OpponentsController < ApplicationController
      before_action :set_opponent, only: %i[show update destroy]

      def index
        @opponents = Opponent.includes(:moves, { cinematics: { conversations: { chats: :sprites } } }, { gifts: { conversations: { chats: :sprites } } }, { conversations: { chats: :sprites } }).all.order(:name)
        render json: @opponents.map { |o| serialize_opponent(o) }
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
        params.expect(opponent: [ :slug, :name, :element_type, :max_hp,
                                   :base_damage, :damage_variance, :gold_reward_min,
                                   :gold_reward_max, :flavour_text, :level,
                                   :xp_reward_victory, :xp_reward_defeat,
                                   :avatar_1, :avatar_2, :avatar_3, :avatar_4, :avatar_5 ])
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

      def serialize_opponent(opponent)
        moves_by_pos = opponent.opponent_moves.sort_by(&:position).map { |om|
          serialize_move(om.move)
        }

        {
          id:            opponent.slug,
          name:          opponent.name,
          type:          opponent.element_type,
          maxHp:         opponent.max_hp,
          baseDamage:    opponent.base_damage,
          damageVariance: opponent.damage_variance,
          goldReward:    [ opponent.gold_reward_min, opponent.gold_reward_max ],
          flavourText:   opponent.flavour_text,
          level:         opponent.level,
          xpReward:      [ opponent.xp_reward_victory, opponent.xp_reward_defeat ],
          unlockAfter:   opponent.unlock_after_list,
          moves:         moves_by_pos,
          avatars:       (1..5).map { |n| opponent.public_send(:"avatar_#{n}") }.compact,
          cinematics:    opponent.cinematics.sort_by(&:level).map { |c| serialize_cinematic(c) },
          gifts:         opponent.gifts.sort_by(&:name).map { |g| serialize_gift(g) },
          conversations: opponent.conversations.map { |c| serialize_conversation(c) }
        }
      end

      def serialize_cinematic(cinematic)
        h = { level: cinematic.level }
        h[:description] = cinematic.description if cinematic.description.present?
        h[:relationshipGain] = cinematic.relationship_gain unless cinematic.relationship_gain.nil?
        if cinematic.association(:conversations).loaded?
          h[:conversations] = cinematic.conversations.map { |c| serialize_conversation(c) }
        end
        h
      end

      def serialize_gift(gift)
        h = { id: gift.id, name: gift.name, gold: gift.gold, exp: gift.exp }
        if gift.association(:conversations).loaded?
          h[:conversations] = gift.conversations.map { |c| serialize_conversation(c) }
        end
        h
      end

      def serialize_conversation(conversation)
        return nil unless conversation
        h = { id: conversation.id, chats: conversation.chats.map { |c| serialize_chat(c) } }
        h[:backgroundUrl] = conversation.background_url if conversation.background_url.present?
        h[:backgroundColor] = conversation.background_color if conversation.background_color.present?
        h[:position] = conversation.position unless conversation.position.nil?
        h
      end

      def serialize_chat(chat)
        {
          role:     chat.role,
          position: chat.position,
          content:  chat.content,
          sprites:  chat.sprites.map { |s| serialize_sprite(s) }
        }
      end

      def serialize_sprite(sprite)
        h = { url: sprite.url }
        h[:x]      = sprite.x      unless sprite.x.nil?
        h[:y]      = sprite.y      unless sprite.y.nil?
        h[:width]  = sprite.width  unless sprite.width.nil?
        h[:height] = sprite.height unless sprite.height.nil?
        h
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
          effectStun: move.effect_stun,
          effectBoostPercent: move.effect_boost_percent,
          effectBoostKind: move.effect_boost_kind
        }
      end
    end
  end
end
