require "yaml"

SEEDS_DIR = Rails.root.join("db", "seeds")

def create_chat(conversation, chat_params)
  chat = conversation.chats.create!(chat_params.except(:sprites))
  chat_params[:sprites].to_a.each do |sprite_params|
    chat.sprites.create!(sprite_params)
  end
  chat
end

def create_conversation(conversable, conversation_params)
  conversation = conversable.conversations.create!(conversation_params.except(:chats))
  conversation_params[:chats].to_a.each_with_index do |chat_params, pos|
    create_chat(conversation, chat_params.merge(position: pos))
  end
  conversation
end

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
    data.slice(:name, :element_type, :max_hp, :base_damage, :damage_variance, :gold_reward, :xp_reward, :avatar)
  )
  opponent.unlock_after_list = data[:unlock_after] || []
  opponent.save!

  opponent.opponent_moves.destroy_all
  (data[:moves] || []).each_with_index do |move_slug, i|
    opponent.opponent_moves.create!(move_slug: move_slug.to_s, position: i)
  end

  opponent.cinematics.destroy_all
  (data[:cinematics] || []).each do |c|
    cinematic = opponent.cinematics.create!(c.except(:conversations))
    (c[:conversations] || []).each_with_index do |conv_data, pos|
      create_conversation(cinematic, conv_data.merge(position: pos))
    end
  end

  opponent.gifts.destroy_all
  (data[:gifts] || []).each do |g|
    gift = opponent.gifts.create!(name: g[:name], gold: g[:gold], exp: g[:exp])
    (g[:conversations] || []).each do |conv_data|
      create_conversation(gift, conv_data)
    end
  end

  opponent.conversations.destroy_all
  (data[:conversations] || []).each do |conv_data|
    create_conversation(opponent, conv_data)
  end

  print "."
end
puts "\nSeeded #{opponents_data.size} opponents"

# ─── Items ───────────────────────────────────────────────────────────────────

items_data = YAML.load_file(SEEDS_DIR.join("items.yml"), symbolize_names: true)

items_data.each do |data|
  Item.find_or_initialize_by(slug: data[:id]).tap do |item|
    item.assign_attributes(data.slice(:name, :icon, :category, :quality, :base_damage, :base_defense))
    item.save!
    print "."
  end
end
puts "\nSeeded #{items_data.size} items"
