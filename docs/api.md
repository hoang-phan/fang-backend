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

### Rarity
```
"normal" | "rare" | "sr" | "ssr" | "lr"
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
  "rarity": "sr",             // Rarity
  "maxHp": 140,
  "baseDamage": 20,
  "damageVariance": 0.15,
  "goldReward": [35, 60],        // [min, max]
  "flavourText": "Young but fierce.",
  "level": 4,
  "xpReward": [300, 60],         // [victoryXp, defeatXp]
  "unlockAfter": ["goblin", "witch"],  // opponent slugs
  "moves": [ /* 0–4 Move objects, ordered by position */ ],
  "avatar": "/images/opponents/drake/avatar_1.webp",  // public-folder URL
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
  "height": 64,                               // nullable — display height in pixels
  "flip":   true                              // optional — only present when true; horizontal mirror
}
```

Sprites are displayed as characters inside a scene (e.g. a character standing in a room). They are not avatars — there is no avatar field on Chat.

### Conversation object

```jsonc
{
  "id": 1,
  "chats": [
    { "speaker": "Mitsu",      "position": 0, "content": "Thank you for the gift!", "sprites": [] },
    { "speaker": "Illyasviel", "position": 1, "content": "It's nothing, really.",   "sprites": [] }
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
  "speaker":  "Mitsu",                  // display name — "Mitsu" (hero), commander name (opponent), or "" (narrative)
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

Every opponent has a `gacha_key` — a random, unguessable string distinct from its `slug`/`id`. The frontend never sees the bare `gacha_key`. It is only ever transmitted **encrypted**, paired with the unix timestamp used as the encryption salt. See [Gacha encryption scheme](#gacha-encryption-scheme) below.

### GET /api/v1/opponents
Returns only the opponents whose encrypted key the caller can prove knowledge of. Does **not** return all opponents — there is no way to list every opponent through this endpoint.

**Query params**
```
timestamp   integer  required — unix timestamp (seconds) used as the encryption salt for every key below
keys[]      string[] required — encryptedKey values previously obtained from this endpoint or from POST /api/v1/gacha
```

Each key is decrypted using `timestamp` as salt. A key is silently dropped (not an error) if:
- `timestamp` is more than 60 seconds old or in the future
- the key fails to decrypt/verify against that timestamp
- the decrypted value doesn't match any opponent's `gacha_key`

**Response** `200` — matching opponents only, ordered by name. Each object additionally includes `timestamp` (echoed back) and a freshly-encrypted `encryptedKey` for the same opponent, so the frontend can keep re-proving it holds that opponent without ever seeing the bare key.
```json
[ /* Opponent[] & { timestamp: number, encryptedKey: string } */ ]
```

**Example**
```bash
curl -G http://localhost:3000/api/v1/opponents \
  --data-urlencode "timestamp=1783651354" \
  --data-urlencode "keys[]=qFvyBB5LujlEaAclyHgz7JZUaV+vo5s6--DuOroiL4tKa4DgDR--zSQWUyCH1wCiDEIJdHmBrg=="
```

---

### GET /api/v1/opponents/:id
`:id` is the opponent's slug (e.g. `drake`). Admin/editor use only — unrelated to the gacha flow, returns the opponent directly with no key required.

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
opponent[rarity]            string   one of Rarity, default "normal"
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
opponent[avatar]            string   public-folder path, e.g. /images/opponents/slug/avatar_1.webp
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
      "avatar": "/images/opponents/goblin/avatar_1.webp"
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

## Gacha

### POST /api/v1/gacha
Picks one random opponent and returns it along with an encrypted key the frontend can store and later exchange via `GET /api/v1/opponents`. The bare `gacha_key` is never returned — only the encrypted form.

The pull is two-stage: first a `rarity` tier is chosen by weighted random roll, then one opponent is picked uniformly at random from all opponents of that tier.

Rarity pull weights:
```
normal  60%
rare    20%
sr      12%
ssr      6%
lr       2%
```

**Request body**: none required.

**Response** `200`
```jsonc
{
  "timestamp": 1783651354,
  "encryptedKey": "qFvyBB5LujlEaAclyHgz7JZUaV+vo5s6--DuOroiL4tKa4DgDR--zSQWUyCH1wCiDEIJdHmBrg==",
  // Opponent object, same shape as GET /api/v1/opponents:
  "id": "virtuosa",
  "name": "Virtuosa",
  "rarity": "rare",
  // ...rest of Opponent fields
  "moves": [ /* Move[] */ ],
  "cinematics": [ /* … */ ],
  "gifts": [ /* … */ ],
  "conversations": [ /* … */ ]
}
```

**Example**
```bash
curl -X POST http://localhost:3000/api/v1/gacha
```

---

### Gacha encryption scheme

`gacha_key` is a random per-opponent string (distinct from `slug`), generated once when the opponent is created and never exposed in plaintext by any endpoint.

Encryption:
- Cipher: AES-256-GCM via `ActiveSupport::MessageEncryptor`.
- Key derivation: HKDF (`ActiveSupport::KeyGenerator`) over the Rails `secret_key_base`, salted with `"gacha_cipher/#{timestamp}"` — so the derived key (and therefore the ciphertext) is different every time the timestamp changes, even for the same `gacha_key`.
- Expiry: on decrypt, the server rejects the key if `abs(now - timestamp) > 60` seconds. This bounds how long an intercepted `(timestamp, encryptedKey)` pair remains replayable.

This is obfuscation at the API layer (to make casual eavesdropping/replay harder), not a security boundary — anyone who can call the API can still call `POST /api/v1/gacha` repeatedly to discover opponents.

Flow:
1. Frontend calls `POST /api/v1/gacha` → gets `{ timestamp, encryptedKey, ...opponent }`. It stores `encryptedKey` (and `timestamp`, or a fresh one from a later `GET /api/v1/opponents` response) to remember it "owns" this opponent.
2. Later, to fetch full data for its collected opponents, frontend calls `GET /api/v1/opponents?timestamp=<now>&keys[]=<encryptedKey>&keys[]=...`. Because ciphertext is timestamp-salted, the frontend must re-encrypt — which it cannot do itself (it never has the bare key). Instead, each `GET /api/v1/opponents` response returns a **freshly re-encrypted** `encryptedKey` (salted with the `timestamp` from that same request) for every opponent returned, which the frontend stores and sends next time with a new timestamp.

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

`avatar` and `cinematics` contain paths relative to the Rails public folder (e.g. `/images/opponents/slime/avatar_1.webp`). Files are served as static assets — no Active Storage involved. Prefix with the server origin to build full URLs:

```ts
const fullUrl = `http://localhost:3000${opponent.avatar}`
```

Place files under `public/images/opponents/<slug>/`. Accepted formats: `.webp`, `.gif`, `.png`.

---

## Conversation editor

Shared with empire-backend via the local `conversation_editor` gem (`../conversation-editor`). Prefer these routes from fang-conversation-editor:

### GET /api/v1/editor/meta

**Response** `200`
```jsonc
{
  "id": "fang",
  "characterLabel": "Opponent",
  "slotKinds": ["chat", "gift", "cinematic"]
}
```

### GET /api/v1/editor/characters

**Response** `200`
```jsonc
[
  {
    "id": "illyasviel",
    "name": "Illyasviel",
    "slots": [
      { "kind": "chat", "key": "chat", "label": "Chat", "filename": "illyasviel-conversations.yml" },
      { "kind": "gift", "key": "chocolate-box", "label": "Chocolate Box", "filename": "illyasviel-gift-chocolate-box.yml" },
      { "kind": "cinematic", "key": "1", "label": "Cinematic 1", "filename": "illyasviel-cinematic-1.yml" }
    ]
  }
]
```

### GET /api/v1/editor/assets
### GET /api/v1/editor/conversations
### GET /api/v1/editor/conversations/:filename
### POST /api/v1/editor/assets/upload_conversation_yml
### POST /api/v1/editor/scripts/convert

Same behaviour as the legacy endpoints below (assets list/upload + script→YAML). `GET /conversations` lists `.yml`/`.yaml` basenames in `db/seeds/conversations/`; `GET /conversations/:filename` returns that file as `text/yaml` (basename only; `404` if missing).

---

## Image downloader

Shared with empire-backend via the local `image_downloader` gem (`../image-downloader`). Used by fang-image-downloader — set extension `backendBaseUrl` to this server (`http://localhost:3000`). Requires ImageMagick (`convert`) on the host.

### POST /api/v1/downloads

Fetch an image URL, resize with ImageMagick, write into the given folder.

**Request**
```jsonc
{
  "url": "https://example.com/sprites/hero.png",
  "path": "/home/user/fang/sprites",
  "dimension": { "width": 256, "height": 256 }
}
```

**Response** `200` `{ "ok": true, "savedPath": "/home/user/fang/sprites/hero.png" }`  
**Response** `422` `{ "error": "..." }`

---

## Opponent Options (legacy alias)

### GET /api/v1/opponent_options
Legacy shape for older editor builds. Prefer `GET /api/v1/editor/characters`.

Returns each opponent's id, name, and gift names in parameterized form — suitable for constructing seed filenames like `{id}-gift-{giftName}.yml`.

**Response** `200`
```jsonc
[
  {
    "id": "illyasviel",
    "name": "Illyasviel",
    "giftNames": ["chocolate-box", "magic-mugs", "tulip-bouquet"]
  }
]
```

`giftNames` entries are the gift name lowercased and hyphenated (e.g. "Gold Pendant" → `"gold-pendant"`). Ordered by gift name.

---

## Assets (legacy aliases)

### GET /api/v1/assets
Returns all image and video file paths available in the `public/` folder (recursive).  
Useful for populating pickers in the conversation editor. Prefer `GET /api/v1/editor/assets`.

Included extensions: `.webp`, `.gif`, `.png`, `.jpg`, `.jpeg`, `.mp4`

**Response** `200`
```json
[
  "/illyasviel/avatar1.jpg",
  "/illyasviel/cinematic3.mp4",
  "/virtuosa/cinematic1.webp"
]
```

Each path is a public-folder-relative URL. Prefix with the server origin to build a full URL:
```ts
const fullUrl = `http://localhost:3000${path}`
```

---

### POST /api/v1/assets/upload_conversation_yml
Writes a YAML file into `db/seeds/conversations/` on the server. Intended for the conversation editor to persist its output when the browser cannot write to the filesystem directly. Prefer `POST /api/v1/editor/assets/upload_conversation_yml`.

Accepts `multipart/form-data`.

**Fields**
```
file      file    required — the .yml file contents
filename  string  required — target filename, must end with .yml (basename only; directory traversal is stripped)
```

**Response** `200`
```jsonc
{ "path": "/absolute/path/to/db/seeds/conversations/my-conversation.yml" }
```

**Response** `422` — validation errors

**Example (curl)**
```bash
curl -X POST http://localhost:3000/api/v1/assets/upload_conversation_yml \
  -F "filename=illyasviel-conversations.yml" \
  -F "file=@/path/to/illyasviel-conversations.yml"
```

---

## Scripts (legacy alias)

### POST /api/v1/scripts/convert
Converts a plain-text named-speaker script into YAML conversations. `Name: dialogue` lines become spoken chats with that `speaker`; bare paragraphs become narrative with blank `speaker` (wrapped in parentheses). Prefer `POST /api/v1/editor/scripts/convert`.

**Request body** (JSON)
```jsonc
{
  "text": "She smiled.\n\nMitsu: Hello there.\n\nYasuda Kunitsugu: Face me!"
}
```

**Response** `200` — YAML string (`text/yaml`)
```yaml
- chats:
  - speaker: ""
    content: (She smiled.)
  - speaker: Mitsu
    content: Hello there.
  - speaker: Yasuda Kunitsugu
    content: Face me!
```

**Response** `422` — validation errors

**Example (curl)**
```bash
curl -X POST http://localhost:3000/api/v1/scripts/convert \
  -H "Content-Type: application/json" \
  -d '{"text": "She smiled.\n\nMitsu: Hello."}'
```

---

## Health check

### GET /up
Returns `200` if the app is running, `500` on boot error. Used by load balancers.
