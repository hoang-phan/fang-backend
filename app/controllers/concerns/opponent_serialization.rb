module OpponentSerialization
  extend ActiveSupport::Concern

  def serialize_opponent(opponent, timestamp: nil)
    moves_by_pos = opponent.opponent_moves.sort_by(&:position).map { |om| serialize_move(om.move) }

    h = {
      id:            opponent.slug,
      name:          opponent.name,
      type:          opponent.element_type,
      rarity:        opponent.rarity,
      maxHp:         opponent.max_hp,
      baseDamage:    opponent.base_damage,
      damageVariance: opponent.damage_variance,
      goldReward:    opponent.gold_reward,
      flavourText:   opponent.flavour_text,
      xpReward:      opponent.xp_reward,
      unlockAfter:   opponent.unlock_after_list,
      moves:         moves_by_pos,
      avatar:        opponent.avatar,
      cinematics:    opponent.cinematics.sort_by(&:level).map { |c| serialize_cinematic(c) },
      gifts:         opponent.gifts.sort_by(&:name).map { |g| serialize_gift(g) },
      conversations: opponent.conversations.map { |c| serialize_conversation(c) }
    }

    if timestamp.present?
      h[:timestamp] = timestamp.to_i
      h[:encryptedKey] = GachaCipher.obfuscate(opponent.gacha_key, timestamp)
    end

    h
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
