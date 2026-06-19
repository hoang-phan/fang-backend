moves_data = [
  # Normal
  { slug: "bodySlam",        name: "Body Slam", description: "Crashes full force into the foe.",            element_type: "normal",   mp_cost: 15, base_damage: 28,  damage_variance: 0.20, level: 1, max_level: 5 },
  { slug: "tackle",          name: "Tackle", description: "A straightforward physical charge.",          element_type: "normal",   mp_cost: 10, base_damage: 20,  damage_variance: 0.25, level: 1, max_level: 5 },
  { slug: "slash",           name: "Slash", description: "A precise cutting strike.",                  element_type: "normal",   mp_cost: 18, base_damage: 32,  damage_variance: 0.15, level: 1, max_level: 5 },
  { slug: "headbutt",        name: "Headbutt", description: "Smash your skull into the foe.",              element_type: "normal",   mp_cost: 12, base_damage: 24,  damage_variance: 0.20, level: 1, max_level: 5 },
  # Poison
  { slug: "venomStrike",     name: "Venom Strike", description: "A swift poisonous lunge.",                   element_type: "poison",   mp_cost: 18, base_damage: 22,  damage_variance: 0.25, level: 1, max_level: 5 },
  { slug: "acidSpit",        name: "Acid Spit", description: "Launches a glob of corrosive acid.",          element_type: "poison",   mp_cost: 15, base_damage: 26,  damage_variance: 0.20, level: 1, max_level: 5 },
  { slug: "toxicCloud",      name: "Toxic Cloud", description: "Engulfs the foe in a noxious mist.",          element_type: "poison",   mp_cost: 25, base_damage: 38,  damage_variance: 0.15, level: 1, max_level: 5 },
  { slug: "poisonFang",      name: "Poison Fang", description: "Sinks venomous fangs into the target.",       element_type: "poison",   mp_cost: 22, base_damage: 34,  damage_variance: 0.18, level: 1, max_level: 5 },
  # Fire
  { slug: "fireball",        name: "Fireball", description: "Hurls a blazing sphere.",                     element_type: "fire",     mp_cost: 20, base_damage: 35,  damage_variance: 0.15, level: 1, max_level: 5 },
  { slug: "emberBlast",      name: "Ember Blast", description: "A burst of scorching embers.",                element_type: "fire",     mp_cost: 15, base_damage: 26,  damage_variance: 0.20, level: 1, max_level: 5 },
  { slug: "flameSweep",      name: "Flame Sweep", description: "A sweeping wave of fire.",                    element_type: "fire",     mp_cost: 28, base_damage: 44,  damage_variance: 0.12, level: 1, max_level: 5 },
  { slug: "scorchingBreath", name: "Scorching Breath", description: "Exhales a cone of blistering flame.",         element_type: "fire",     mp_cost: 35, base_damage: 55,  damage_variance: 0.10, level: 1, max_level: 5 },
  # Electric
  { slug: "thunderbolt",     name: "Thunderbolt", description: "A crackling bolt of lightning.",              element_type: "electric", mp_cost: 25, base_damage: 45,  damage_variance: 0.10, level: 1, max_level: 5 },
  { slug: "staticShock",     name: "Static Shock", description: "Zaps the foe with built-up static.",          element_type: "electric", mp_cost: 15, base_damage: 24,  damage_variance: 0.25, level: 1, max_level: 5 },
  { slug: "voltStrike",      name: "Volt Strike", description: "Charges forward with electric force.",       element_type: "electric", mp_cost: 22, base_damage: 38,  damage_variance: 0.15, level: 1, max_level: 5 },
  { slug: "thunderRoar",     name: "Thunder Roar", description: "A deafening electric shockwave.",             element_type: "electric", mp_cost: 32, base_damage: 52,  damage_variance: 0.10, level: 1, max_level: 5 },
  # Dark
  { slug: "shadowClaw",      name: "Shadow Claw", description: "Slashes with a claw of pure darkness.",       element_type: "dark",     mp_cost: 28, base_damage: 42,  damage_variance: 0.18, level: 1, max_level: 5 },
  { slug: "nightShade",      name: "Night Shade", description: "Warps reality with deep shadow.",             element_type: "dark",     mp_cost: 20, base_damage: 33,  damage_variance: 0.20, level: 1, max_level: 5 },
  { slug: "voidPulse",       name: "Void Pulse", description: "Fires a pulse of annihilating energy.",       element_type: "dark",     mp_cost: 30, base_damage: 48,  damage_variance: 0.15, level: 1, max_level: 5 },
  { slug: "soulDrain",       name: "Soul Drain", description: "Drains the life force of the foe.",           element_type: "dark",     mp_cost: 25, base_damage: 40,  damage_variance: 0.10, level: 1, max_level: 5, leech: 30 },
  # Earth
  { slug: "earthQuake",      name: "Earthquake",   description: "Shakes the ground with tremendous force.",  element_type: "earth",    mp_cost: 35, base_damage: 55,  damage_variance: 0.10, level: 1, max_level: 5, effect_turns: 2, effect_stun: true,  effect_prob: 30 },
  { slug: "stoneShield",     name: "Stone Shield", description: "Creates a shield of stone.",                element_type: "earth",    mp_cost: 18, base_defense: 10,   damage_variance: 0.20, level: 1, max_level: 5, effect_turns: 3, effect_prob: 100 },
  { slug: "mudSlide",        name: "Mud Slide",    description: "Buries the foe under cascading mud.",       element_type: "earth",    mp_cost: 22, base_damage: 38,  damage_variance: 0.18, level: 1, max_level: 5, effect_turns: 2, effect_stun: true,  effect_prob: 25 },
  { slug: "stoneCrush",      name: "Stone Crush",  description: "Pulverizes with grinding stone force.",     element_type: "earth",    mp_cost: 28, base_damage: 46,  damage_variance: 0.12, level: 1, max_level: 5, effect_turns: 1, effect_stun: true,  effect_prob: 20 },
  # Ice
  { slug: "iceShard",        name: "Ice Shard", description: "A razor-sharp shard of ice.",                element_type: "ice",      mp_cost: 22, base_damage: 38,  damage_variance: 0.12, level: 1, max_level: 5 },
  # Psychic
  { slug: "mindBlast",       name: "Mind Blast", description: "Unleashes a devastating psychic wave.",       element_type: "psychic",  mp_cost: 28, base_damage: 44,  damage_variance: 0.12, level: 1, max_level: 5 },
  { slug: "psychicWave",     name: "Psychic Wave", description: "Unleashes a devastating psychic wave.",       element_type: "psychic",  mp_cost: 28, base_damage: 44,  damage_variance: 0.12, level: 1, max_level: 5, effect_turns: 2, effect_stun: true,  effect_prob: 30 },
  { slug: "psychicShield",   name: "Psychic Shield", description: "Creates a shield of psychic energy.",       element_type: "psychic",  mp_cost: 18, base_defense: 10,   damage_variance: 0.20, level: 1, max_level: 5, effect_turns: 3, effect_prob: 100 },
  { slug: "psychicBlade",    name: "Psychic Blade", description: "Slashes with a blade of psychic energy.",       element_type: "psychic",  mp_cost: 22, base_damage: 38,  damage_variance: 0.18, level: 1, max_level: 5, effect_turns: 2, effect_stun: true,  effect_prob: 25 },
  { slug: "insomnia",        name: "Insomnia", description: "Puts the foe to sleep.",     element_type: "psychic",  mp_cost: 28, base_damage: 46,  damage_variance: 0.12, level: 1, max_level: 5, effect_turns: 1, effect_stun: true,  effect_prob: 20 },
  # Healing
  { slug: "healingWind",     name: "Healing Wind", description: "Restores some HP with a gentle breeze.",      element_type: "normal",   mp_cost: 30, base_damage: -25, damage_variance: 0.05, level: 1, max_level: 5 },
  # Basic attack
  { slug: "attack",          name: "Attack", description: "A reliable physical strike.",                element_type: "normal",   mp_cost: 0,  base_damage: 12,  damage_variance: 0.25, level: 1, max_level: 1 },
]

moves_data.each do |attrs|
  Move.find_or_initialize_by(slug: attrs[:slug]).tap do |m|
    m.assign_attributes(attrs)
    m.save!
    print "."
  end
end
puts "\nSeeded #{moves_data.size} moves"

opponents_data = [
  # {
  #   slug: "slime", name: "Slime", element_type: "poison",
  #   max_hp: 60, base_damage: 8, damage_variance: 0.20,
  #   gold_reward_min: 5, gold_reward_max: 15, level: 1,
  #   xp_reward_victory: 50, xp_reward_defeat: 10, unlock_after: [],
  #   flavour_text: "A wobbly green blob. Good for beginners.",
  #   moves: %w[venomStrike acidSpit toxicCloud poisonFang],
  #   avatar_1: "/avatar_1.jpg",
  #   : "/avatar_2.jpg",
  #   vatar_3: "/avatar_3.jpg",
  #   vatar_4: "/avatar_4.jpg",
  #   vatar_5: "/avatar_5.jpg",
  #   cinemaic_1: "/cinematic_1.webp",
  #   cinemaic_2: "/cinematic_2.webp",
  #   cinemaic_3: "/cinematic_3.webp",
  #   cinemaic_4: "/cinematic_4.webp",
  #   cinemaic_5: "/cinematic_5.webp"
  # },
  # {
  #   slug: "goblin", name: "Goblin Raider", element_type: "normal",
  #   max_hp: 90, base_damage: 14, damage_variance: 0.25,
  #   gold_reward_min: 15, gold_reward_max: 30, level: 2,
  #   xp_reward_victory: 150, xp_reward_defeat: 30, unlock_after: [ "slime" ],
  #   flavour_text: "Sneaky, volatile, and surprisingly crafty.",
  #   moves: %w[bodySlam tackle slash headbutt],
  #   avatar_1: "/images/opponents/goblin/avatar_1.jpg",
  #   avatar_2: "/images/opponents/goblin/avatar_2.jpg",
  #   avatar_3: "/images/opponents/goblin/avatar_3.jpg",
  #   avatar_4: "/images/opponents/goblin/avatar_4.jpg",
  #   avatar_5: "/images/opponents/goblin/avatar_5.jpg",
  #   cinematic_1: "/images/opponents/goblin/cinematic_1.webp",
  #   cinematic_2: "/images/opponents/goblin/cinematic_2.webp",
  #   cinematic_3: "/images/opponents/goblin/cinematic_3.webp",
  #   cinematic_4: "/images/opponents/goblin/cinematic_4.webp",
  #   cinematic_5: "/images/opponents/goblin/cinematic_5.webp"
  # },
  # {
  #   slug: "witch", name: "Forest Witch", element_type: "psychic",
  #   max_hp: 110, base_damage: 12, damage_variance: 0.30,
  #   gold_reward_min: 20, gold_reward_max: 40, level: 3,
  #   xp_reward_victory: 200, xp_reward_defeat: 40, unlock_after: [ "slime" ],
  #   flavour_text: "Cackles as she conjures chilling spells.",
  #   moves: %w[mindBlast healingWind iceShard toxicCloud],
  #   avatar_1: "/images/opponents/witch/avatar_1.jpg",
  #   avatar_2: "/images/opponents/witch/avatar_2.jpg",
  #   avatar_3: "/images/opponents/witch/avatar_3.jpg",
  #   avatar_4: "/images/opponents/witch/avatar_4.jpg",
  #   avatar_5: "/images/opponents/witch/avatar_5.jpg",
  #   cinematic_1: "/images/opponents/witch/cinematic_1.webp",
  #   cinematic_2: "/images/opponents/witch/cinematic_2.webp",
  #   cinematic_3: "/images/opponents/witch/cinematic_3.webp",
  #   cinematic_4: "/images/opponents/witch/cinematic_4.webp",
  #   cinematic_5: "/images/opponents/witch/cinematic_5.webp"
  # },
  # {
  #   slug: "drake", name: "Drake Hatchling", element_type: "fire",
  #   max_hp: 140, base_damage: 20, damage_variance: 0.15,
  #   gold_reward_min: 35, gold_reward_max: 60, level: 4,
  #   xp_reward_victory: 300, xp_reward_defeat: 60, unlock_after: %w[goblin witch],
  #   flavour_text: "Young but fierce. Its breath singes the air.",
  #   moves: %w[fireball emberBlast flameSweep scorchingBreath],
  #   avatar_1: "/images/opponents/drake/avatar_1.jpg",
  #   avatar_2: "/images/opponents/drake/avatar_2.jpg",
  #   avatar_3: "/images/opponents/drake/avatar_3.jpg",
  #   avatar_4: "/images/opponents/drake/avatar_4.jpg",
  #   avatar_5: "/images/opponents/drake/avatar_5.jpg",
  #   cinematic_1: "/images/opponents/drake/cinematic_1.webp",
  #   cinematic_2: "/images/opponents/drake/cinematic_2.webp",
  #   cinematic_3: "/images/opponents/drake/cinematic_3.webp",
  #   cinematic_4: "/images/opponents/drake/cinematic_4.webp",
  #   cinematic_5: "/images/opponents/drake/cinematic_5.webp"
  # },
  # {
  #   slug: "shadow", name: "Shadow Fiend", element_type: "dark",
  #   max_hp: 180, base_damage: 25, damage_variance: 0.20,
  #   gold_reward_min: 50, gold_reward_max: 80, level: 5,
  #   xp_reward_victory: 400, xp_reward_defeat: 80, unlock_after: [ "drake" ],
  #   flavour_text: "Born from the void between worlds.",
  #   moves: %w[shadowClaw nightShade voidPulse soulDrain],
  #   avatar_1: "/images/opponents/shadow/avatar_1.jpg",
  #   avatar_2: "/images/opponents/shadow/avatar_2.jpg",
  #   avatar_3: "/images/opponents/shadow/avatar_3.jpg",
  #   avatar_4: "/images/opponents/shadow/avatar_4.jpg",
  #   avatar_5: "/images/opponents/shadow/avatar_5.jpg",
  #   cinematic_1: "/images/opponents/shadow/cinematic_1.webp",
  #   cinematic_2: "/images/opponents/shadow/cinematic_2.webp",
  #   cinematic_3: "/images/opponents/shadow/cinematic_3.webp",
  #   cinematic_4: "/images/opponents/shadow/cinematic_4.webp",
  #   cinematic_5: "/images/opponents/shadow/cinematic_5.webp"
  # },
  {
    slug: "illyasviel", name: "Illyasviel von Einzbern", element_type: "psychic",
    max_hp: 50, base_damage: 8, damage_variance: 0.20,
    gold_reward_min: 5, gold_reward_max: 15, level: 1,
    xp_reward_victory: 50, xp_reward_defeat: 10,
    flavour_text: "Master of Berserker",
    moves: %w[psychicWave psychicShield psychicBlade insomnia],
    avatar_1: "/illyasviel/avatar1.jpg",
    avatar_2: "/illyasviel/avatar2.jpg",
    avatar_3: "/illyasviel/avatar3.jpg",
    avatar_4: "/illyasviel/avatar4.jpg",
    avatar_5: "/illyasviel/avatar5.jpg",
    cinematic_1: "/illyasviel/cinematic1.webp",
    cinematic_2: "/illyasviel/cinematic2.webp",
    cinematic_3: "/illyasviel/cinematic3.webp",
    cinematic_4: "/illyasviel/cinematic4.webp",
    cinematic_5: "/illyasviel/cinematic3.webp,/illyasviel/cinematic4.webp,/illyasviel/cinematic5.webp,/illyasviel/cinematic5-1.webp"
  },
  {
    slug: "virtuosa", name: "Virtuosa", element_type: "dark",
    max_hp: 55, base_damage: 10, damage_variance: 0.15,
    gold_reward_min: 7, gold_reward_max: 20, level: 1,
    xp_reward_victory: 60, xp_reward_defeat: 20,
    flavour_text: "Agent of the Black Forest",
    moves: %w[shadowClaw nightShade voidPulse soulDrain],
    avatar_1: "/virtuosa/avatar1.jpg",
    avatar_2: "/virtuosa/avatar2.jpg",
    avatar_3: "/virtuosa/avatar3.jpg",
    avatar_4: "/virtuosa/avatar4.jpg",
    avatar_5: "/virtuosa/avatar5.jpg",
    cinematic_1: "/virtuosa/cinematic7.webp",
    cinematic_2: "/virtuosa/cinematic8.webp",
    cinematic_3: "/virtuosa/cinematic1.webp",
    cinematic_4: "/virtuosa/cinematic2.webp",
    cinematic_5: "/virtuosa/cinematic3.webp,/virtuosa/cinematic4.webp,/virtuosa/cinematic5.webp,/virtuosa/cinematic6.webp"
  },
]

opponents_data.each do |attrs|
  move_slugs = attrs.delete(:moves)
  unlock = attrs.delete(:unlock_after)

  opponent = Opponent.find_or_initialize_by(slug: attrs[:slug])
  opponent.assign_attributes(attrs)
  opponent.unlock_after_list = unlock
  opponent.save!

  opponent.opponent_moves.destroy_all
  move_slugs.each_with_index do |slug, i|
    opponent.opponent_moves.create!(move_slug: slug, position: i)
  end
  print "."
end
puts "\nSeeded #{opponents_data.size} opponents"
