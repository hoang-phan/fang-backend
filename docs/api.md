# Fang Backend — API Reference

Base URL: `http://localhost:3000`  
All endpoints return and accept `application/json`.  
CORS is open to `http://localhost:5173` and `http://localhost:3000`.

---

## Shared types

### ElementType
```
"normal" | "fire" | "water" | "electric" | "grass" | "ice" | "poison" | "earth" | "dark" | "psychic"
```

### Move object
Matches the frontend `Move` interface exactly.

```jsonc
{
  "id": "fireball",          // slug — primary key
  "name": "Fireball",
  "description": "Hurls a blazing sphere.",
  "type": "fire",            // ElementType — frontend uses this for icon display
  "mpCost": 20,              // 0 = free attack
  "baseDamage": 35,          // negative = heal
  "damageVariance": 0.15,    // 0.0–1.0
  "level": 1,
  "maxLevel": 5,
  // optional — only present when non-null:
  "effectTurns": 2,          // how many turns the status effect lasts
  "effectDamage": 5,         // damage dealt per effect turn
  "effectProb": 30,          // % chance the effect triggers (1–100)
  "leech": 30,               // % of damage converted to HP and returned to the caster (1–100)
  "effectBoostPercent": 10,  // % boost applied each effect turn (e.g. 10 = +10%)
  "effectBoostKind": "attack_all"  // what is boosted: "none" | "attack_all" | "attack_element" | "defense" | "evasion" | "hp" | "mp"
}
```

### Opponent object
Matches the frontend `OpponentDef` interface exactly.

```jsonc
{
  "id": "drake",
  "name": "Drake Hatchling",
  "type": "fire",
  "maxHp": 140,
  "baseDamage": 20,
  "damageVariance": 0.15,
  "goldReward": [35, 60],        // [min, max]
  "flavourText": "Young but fierce.",
  "level": 4,
  "xpReward": [300, 60],         // [victoryXp, defeatXp]
  "unlockAfter": ["goblin", "witch"],  // opponent slugs
  "moves": [ /* 0–4 Move objects, ordered by position */ ],
  "avatars": ["/images/opponents/drake/avatar_1.webp", "…"],  // up to 5 public-folder URLs, one per opponent level
  "cinematics": [                // ordered by level
    {
      "level": 1,
      "description": "Drake awakens.",
      // optional — only present when non-null:
      "relationshipGain": 25,    // relationship XP awarded when this cinematic is viewed
      // always present — array of conversations ordered by position:
      "conversations": [
        { "id": 2, "chats": [ /* Chat[] */ ], "backgroundUrl": "/images/opponents/drake/cinematic_1.webp", "backgroundColor": "#ccc", "position": 0 }
      ]
    }
  ],
  "gifts": [                     // ordered by name — all gifts for this opponent
    {
      "id": 1, "name": "Gold Pendant", "gold": 100, "exp": 50,
      // always present — array of conversations ordered by position:
      "conversations": [
        { "id": 3, "chats": [ /* Chat[] */ ], "position": 0 }
      ]
    }
  ],
  "conversations": [             // opponent-level chat conversations (ordered by id)
    { "id": 4, "chats": [ /* Chat[] */ ] }
  ]
}
```

### Item object

```jsonc
{
  "id": "ironSword",
  "name": "Iron Sword",
  "icon": "🗡️",
  "category": "weapon",          // one of ItemCategory
  "quality": "normal",           // "rude" | "normal" | "rare" | "legendary"
  "baseDamage": 12,              // optional — weapon only; omitted when null
  "baseDefense": null            // optional — omitted when null
  // enhancements are generated dynamically by the frontend from quality + affixes system
}
```

### Gift object

```jsonc
{
  "id": 1,                   // integer auto-PK
  "opponentId": "goblin",    // opponent slug
  "name": "Gold Pendant",
  "gold": 100,
  "exp": 50,
  // always present — array of conversations ordered by position:
  "conversations": [ { "id": 1, "chats": [ /* Chat[] */ ], "position": 0 } ]
}
```

### Sprite object

```jsonc
{
  "url":    "/images/sprites/hero_idle.webp", // public-folder path
  "x":      100,                              // nullable — pixel x offset
  "y":      200,                              // nullable — pixel y offset
  "width":  64,                               // nullable — display width in pixels
  "height": 64                                // nullable — display height in pixels
}
```

Sprites are displayed as characters inside a scene (e.g. a character standing in a room). They are not avatars — there is no avatar field on Chat.

### Conversation object

```jsonc
{
  "id": 1,
  "chats": [
    { "role": "hero",     "position": 0, "content": "Thank you for the gift!", "sprites": [] },
    { "role": "opponent", "position": 1, "content": "It's nothing, really.",   "sprites": [] }
  ],
  // optional — only present when set:
  "backgroundUrl": "/illyasviel/cinematic1.webp", // background image for the scene
  "backgroundColor": "#ccc", // background color for the scene
  "position": 0                                   // display order (cinematics/gifts only; sequential)
}
```

### Chat object

```jsonc
{
  "role":    "hero",                    // "hero" | "opponent" | "other"
  "position": 0,                        // ordering index within the conversation
  "content":  "Thank you for the gift!", // dialogue text
  "sprites":  [ /* Sprite[] */ ]        // characters displayed in the scene for this line
}
```

### Error response
```jsonc
{ "errors": ["Name can't be blank", "Element type is not included in the list"] }
```

---

## Moves

### GET /api/v1/moves
Returns all moves ordered by name.

**Response** `200`
```json
[ /* Move[] */ ]
```

---

### GET /api/v1/moves/:id
`:id` is the move's slug (e.g. `fireball`).

**Response** `200` — Move object  
**Response** `404` — record not found

---

### POST /api/v1/moves
**Request body** (JSON)
```jsonc
{
  "move": {
    "slug": "iceShard",       // required, unique, letters/numbers/underscores
    "name": "Ice Shard",      // required
    "icon": "❄️",              // required
    "description": "…",
    "element_type": "ice",    // required, one of ElementType
    "mp_cost": 22,            // >= 0, default 0
    "base_damage": 38,        // any integer (negative = heal)
    "damage_variance": 0.12,  // 0.0–1.0, default 0.2
    "level": 1,               // default 1
    "max_level": 5,           // default 5
    "effect_turns": 2,        // optional; > 0 integer — turns the status effect lasts
    "effect_damage": 5,       // optional; >= 0 integer — damage per effect turn
    "effect_prob": 30,        // optional; 1–100 float — % chance effect triggers
    "leech": 30,              // optional; 1–100 float — % of damage leeched as HP
    "effect_boost_percent": 10,   // optional; integer — % boost applied per effect turn
    "effect_boost_kind": "attack_all"  // optional; one of: none attack_all attack_element defense evasion hp mp
  }
}
```

**Response** `201` — created Move object  
**Response** `422` — validation errors

---

### PATCH /PUT /api/v1/moves/:id
Same body shape as POST (all fields optional). Only provided fields are updated.

**Response** `200` — updated Move object  
**Response** `422` — validation errors

---

### DELETE /api/v1/moves/:id
**Response** `204` — no content

---

## Opponents

### GET /api/v1/opponents
Returns all opponents ordered by name, with embedded moves and image URLs.

**Response** `200`
```json
[ /* Opponent[] */ ]
```

---

### GET /api/v1/opponents/:id
`:id` is the opponent's slug (e.g. `drake`).

**Response** `200` — Opponent object  
**Response** `404` — record not found

---

### POST /api/v1/opponents
Accepts `multipart/form-data` when uploading images; JSON otherwise.

**Fields**
```
opponent[slug]              string   required, unique
opponent[name]              string   required
opponent[element_type]      string   required, one of ElementType
opponent[max_hp]            integer  required, > 0
opponent[base_damage]       integer  required, > 0
opponent[damage_variance]   float    0.0–1.0
opponent[gold_reward_min]   integer  >= 0
opponent[gold_reward_max]   integer  > 0
opponent[flavour_text]      string
opponent[level]             integer  > 0, default 1
opponent[xp_reward_victory] integer  >= 0
opponent[xp_reward_defeat]  integer  >= 0
opponent[unlock_after][]    string[] slugs of opponents that must be defeated first
opponent[move_slugs][]      string[] up to 4 move slugs; order = battle position 0–3
opponent[avatar_1]          string   public-folder path, e.g. /images/opponents/slug/avatar_1.webp
opponent[avatar_2]          string
opponent[avatar_3]          string
opponent[avatar_4]          string
opponent[avatar_5]          string
opponent[cinematics][][level]             integer  cinematic level (1-based)
opponent[cinematics][][background_url]  string   public-folder path for the background image (stored on the conversation)
opponent[cinematics][][description]     string   optional flavour text
opponent[cinematics][][relationship_gain] integer optional relationship XP awarded when this cinematic is viewed
```

Passing `opponent[cinematics][]` **replaces all** cinematic records for the opponent.

**Response** `201` — created Opponent object  
**Response** `422` — validation errors

**Example (curl, JSON)**
```bash
curl -X POST http://localhost:3000/api/v1/opponents \
  -H "Content-Type: application/json" \
  -d '{
    "opponent": {
      "slug": "goblin",
      "name": "Goblin Raider",
      "element_type": "normal",
      "max_hp": 90,
      "base_damage": 14,
      "damage_variance": 0.25,
      "gold_reward_min": 15,
      "gold_reward_max": 30,
      "level": 1,
      "xp_reward_victory": 150,
      "xp_reward_defeat": 30,
      "flavour_text": "Sneaky, volatile, and surprisingly crafty.",
      "unlock_after": ["slime"],
      "move_slugs": ["bodySlam", "tackle", "slash", "headbutt"],
      "avatar_1": "/images/opponents/goblin/avatar_1.webp",
      "cinematic_1": "/images/opponents/goblin/cinematic_1.webp"
    }
  }'
```

---

### PATCH /PUT /api/v1/opponents/:id
Same fields as POST. All optional.

Passing `opponent[move_slugs][]` **replaces** all 4 move slots — send all 4 slugs even when only changing one.

Passing `opponent[avatar_N]` / `opponent[cinematic_N]` **replaces** that specific attachment. Other slots are untouched.

**Response** `200` — updated Opponent object  
**Response** `422` — validation errors

---

### DELETE /api/v1/opponents/:id
Destroys the opponent and all its `opponent_moves` records. Active Storage attachments are purged asynchronously by Rails.

**Response** `204` — no content

---

## Items

### GET /api/v1/items
Returns all items ordered by name.

**Response** `200`
```json
[ /* Item[] */ ]
```

---

### GET /api/v1/items/:id
`:id` is the item's slug.

**Response** `200` — Item object  
**Response** `404` — record not found

---

### POST /api/v1/items
**Request body** (JSON)
```jsonc
{
  "item": {
    "slug": "ironSword",        // required, unique, letters/numbers/underscores
    "name": "Iron Sword",       // required
    "icon": "🗡️",               // required
    "category": "weapon",       // required, one of ItemCategory
    "quality": "normal",        // "rude" | "normal" | "rare" | "legendary"
    "base_damage": 12,          // optional, >= 0
    "base_defense": null,       // optional, >= 0
    // enhancements are not stored — generated dynamically by the frontend
  }
}
```

**Response** `201` — created Item object  
**Response** `422` — validation errors

---

### PATCH /PUT /api/v1/items/:id
Same body shape as POST. All fields optional.

**Response** `200` — updated Item object  
**Response** `422` — validation errors

---

### DELETE /api/v1/items/:id
**Response** `204` — no content

---

## Gifts

Gifts are scoped to an opponent. All gift routes are nested under `/api/v1/opponents/:opponent_id/`.

### GET /api/v1/opponents/:opponent_id/gifts
Returns all gifts for the given opponent ordered by name.

**Response** `200`
```json
[ /* Gift[] */ ]
```

---

### GET /api/v1/opponents/:opponent_id/gifts/:id
**Response** `200` — Gift object  
**Response** `404` — record not found

---

### POST /api/v1/opponents/:opponent_id/gifts
**Request body** (JSON)
```jsonc
{
  "gift": {
    "name": "Gold Pendant",  // required
    "gold": 100,             // >= 0, default 0
    "exp": 50                // >= 0, default 0
  }
}
```

**Response** `201` — created Gift object  
**Response** `422` — validation errors

---

### PATCH /PUT /api/v1/opponents/:opponent_id/gifts/:id
Same body shape as POST. All fields optional.

**Response** `200` — updated Gift object  
**Response** `422` — validation errors

---

### DELETE /api/v1/opponents/:opponent_id/gifts/:id
**Response** `204` — no content

---

## Image serving

`avatars` and `cinematics` contain paths relative to the Rails public folder (e.g. `/images/opponents/slime/avatar_1.webp`). Files are served as static assets — no Active Storage involved. Prefix with the server origin to build full URLs:

```ts
const fullUrl = `http://localhost:3000${opponent.avatars[0]}`
```

Place files under `public/images/opponents/<slug>/`. Accepted formats: `.webp`, `.gif`, `.png`.

---

## Health check

### GET /up
Returns `200` if the app is running, `500` on boot error. Used by load balancers.
