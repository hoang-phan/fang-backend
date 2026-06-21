require "yaml"

SEEDS_DIR = Rails.root.join("db", "seeds")

# ─── Moves ───────────────────────────────────────────────────────────────────

moves_data = YAML.load_file(SEEDS_DIR.join("moves.yml"), symbolize_names: true)

moves_data.each do |attrs|
  Move.find_or_initialize_by(slug: attrs[:slug]).tap do |m|
    m.assign_attributes(attrs)
    m.save!
    print "."
  end
end
puts "\nSeeded #{moves_data.size} moves"

# ─── Opponents ───────────────────────────────────────────────────────────────

opponents_data = YAML.load_file(SEEDS_DIR.join("opponents.yml"), symbolize_names: true)

opponents_data.each do |data|
  # Map API-shaped camelCase keys back to column names
  opponent = Opponent.find_or_initialize_by(slug: data[:id])
  opponent.assign_attributes(
    name:               data[:name],
    element_type:       data[:type],
    max_hp:             data[:maxHp],
    base_damage:        data[:baseDamage],
    damage_variance:    data[:damageVariance],
    gold_reward_min:    data[:goldReward][0],
    gold_reward_max:    data[:goldReward][1],
    flavour_text:       data[:flavourText],
    level:              data[:level],
    xp_reward_victory:  data[:xpReward][0],
    xp_reward_defeat:   data[:xpReward][1],
    avatar_1:           data.dig(:avatars, 0),
    avatar_2:           data.dig(:avatars, 1),
    avatar_3:           data.dig(:avatars, 2),
    avatar_4:           data.dig(:avatars, 3),
    avatar_5:           data.dig(:avatars, 4)
  )
  opponent.unlock_after_list = data[:unlockAfter] || []
  opponent.save!

  opponent.opponent_moves.destroy_all
  (data[:moves] || []).each_with_index do |move_slug, i|
    opponent.opponent_moves.create!(move_slug: move_slug.to_s, position: i)
  end

  opponent.cinematics.destroy_all
  (data[:cinematics] || []).each do |c|
    cinematic = opponent.cinematics.create!(level: c[:level], description: c[:description])
    (c[:conversations] || []).each_with_index do |conv_data, pos|
      conv = cinematic.conversations.create!(background_url: conv_data[:backgroundUrl].presence, position: pos)
      (conv_data[:chats] || []).each do |chat|
        conv.chats.create!(avatar: chat[:avatar].to_s, position: chat[:position], content: chat[:content])
      end
    end
  end

  opponent.gifts.destroy_all
  (data[:gifts] || []).each do |g|
    gift = opponent.gifts.create!(name: g[:name], gold: g[:gold], exp: g[:exp])
    (g[:conversations] || []).each_with_index do |conv_data, pos|
      conv = gift.conversations.create!(position: pos)
      (conv_data[:chats] || []).each do |chat|
        conv.chats.create!(avatar: chat[:avatar].to_s, position: chat[:position], content: chat[:content])
      end
    end
  end

  opponent.conversations.destroy_all
  (data[:conversations] || []).each do |convo|
    conv = opponent.conversations.create!
    (convo[:chats] || []).each do |chat|
      conv.chats.create!(avatar: chat[:avatar].to_s, position: chat[:position], content: chat[:content])
    end
  end

  print "."
end
puts "\nSeeded #{opponents_data.size} opponents"

# ─── Items ───────────────────────────────────────────────────────────────────

items_data = YAML.load_file(SEEDS_DIR.join("items.yml"), symbolize_names: true)

items_data.each do |data|
  Item.find_or_initialize_by(slug: data[:id]).tap do |item|
    item.assign_attributes(
      name:         data[:name],
      icon:         data[:icon],
      category:     data[:category],
      quality:      data[:quality],
      base_damage:  data[:baseDamage],
      base_defense: data[:baseDefense]
    )
    item.enhancements_list = (data[:enhancements] || []).map do |e|
      e.transform_keys(&:to_s)
    end
    item.save!
    print "."
  end
end
puts "\nSeeded #{items_data.size} items"
