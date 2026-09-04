# Fang Backend — Developer Guide

Rails 8.1 API-only app. SQLite in dev, Active Storage for media files.  
Frontend lives at `../fang` (React + TypeScript, Vite).

---

## Quick start

```bash
bundle install
bin/rails db:migrate
bin/rails db:seed        # loads 28 moves + 6 opponents from frontend data
bin/rails server         # http://localhost:3000
```

Verify it's running:
```bash
curl http://localhost:3000/up                       # → 200
curl http://localhost:3000/api/v1/moves | jq length # → 28
```

---

## Project layout

```
app/
  controllers/
    api/v1/
      moves_controller.rb           # CRUD for Move
      opponents_controller.rb       # CRUD for Opponent + file uploads; index is gacha-key-gated (not a full list)
      opponent_options_controller.rb # Legacy alias — prefer /api/v1/editor/characters
      assets_controller.rb           # Legacy alias — prefer /api/v1/editor/assets*
      scripts_controller.rb          # Legacy alias — prefer /api/v1/editor/scripts/convert
      gacha_controller.rb           # POST /gacha — random opponent pull
    concerns/
      opponent_serialization.rb     # shared serialize_opponent/_move/_gift/... used by opponents + gacha controllers
  models/
    move.rb
    opponent.rb                 # has gacha_key — random, unguessable, distinct from slug
    opponent_move.rb            # join table: position-ordered moves per opponent
  services/
    gacha_cipher.rb              # encrypt/decrypt gacha_key using timestamp-salted AES-256-GCM, 60s expiry

config/
  routes.rb                     # /api/v1/moves, /api/v1/opponents
  initializers/cors.rb          # CORS for localhost:5173 + localhost:3000

db/
  migrate/
    …_create_active_storage_tables.rb
    …_create_moves.rb
    …_create_opponents.rb       # also creates opponent_moves table
  seeds.rb                      # idempotent seed from frontend data
```

---

## Data model

### Move
Primary key is `slug` (string, e.g. `"fireball"`). All other fields mirror the frontend `Move` interface.

| column           | type    | notes                                         |
|------------------|---------|-----------------------------------------------|
| slug             | string  | PK, camelCase matches frontend                |
| name             | string  |                                               |
| icon             | string  | emoji                                         |
| description      | text    |                                               |
| element_type     | string  | one of `Move::ELEMENT_TYPES`                  |
| mp_cost          | integer | 0 = free                                      |
| base_damage      | integer | negative = healing                            |
| damage_variance  | float   | 0.0–1.0                                       |
| level            | integer | starts at 1                                   |
| max_level        | integer | usually 5                                     |
| effect_turns         | integer | nullable; turns the status effect lasts (> 0)                    |
| effect_damage        | integer | nullable; damage dealt per effect turn (>= 0)                    |
| effect_prob          | float   | nullable; % chance effect triggers (1–100)                       |
| leech                | float   | nullable; % of damage leeched as HP (1–100)                      |
| effect_boost_percent | integer | nullable; % boost applied each effect turn                       |
| effect_boost_kind    | integer | enum (default 0); none attack_all attack_element defense evasion hp mp |

Valid `element_type` values: `normal fire water electric grass ice poison earth dark psychic`

### Opponent
Primary key is `slug` (string). Avatar and cinematic URLs are stored directly as strings pointing to files in the `public/` folder (no Active Storage).

| column             | type    | notes                                          |
|--------------------|---------|------------------------------------------------|
| slug               | string  | PK                                             |
| name               | string  |                                                |
| element_type       | string  | defensive type for damage effectiveness        |
| rarity             | integer | enum (default 0); normal rare sr ssr lr — used to weight gacha pulls |
| max_hp             | integer |                                                |
| base_damage        | integer |                                                |
| damage_variance    | float   | 0.0–1.0                                        |
| gold_reward_min    | integer |                                                |
| gold_reward_max    | integer |                                                |
| flavour_text       | text    |                                                |
| level              | integer | base level; XP rewards scale from this         |
| xp_reward_victory  | integer | XP player gets on win                          |
| xp_reward_defeat   | integer | XP player gets on loss                         |
| unlock_after       | text    | JSON array of opponent slugs                   |
| avatar             | string  | public-folder paths    |
| gacha_key          | string  | unique, random (`SecureRandom.urlsafe_base64(16)`), auto-generated on create; never exposed in plaintext — see [Gacha](#gacha) |

`cinematic_1`–`cinematic_5` columns have been replaced by the `Cinematic` association (see below).

`unlock_after` is stored as a JSON string. Use the model helpers:
```ruby
opponent.unlock_after_list         # → ["slime", "goblin"]
opponent.unlock_after_list = [...] # sets and serialises
```

Place image files under `public/images/opponents/<slug>/avatar_N.webp` etc. The URLs are returned as-is in the API response — prefix with the server origin on the frontend.

### Cinematic
Belongs to an Opponent via `opponent_slug`. Replaces the old `cinematic_1`–`cinematic_5` string columns.

| column            | type    | notes                                              |
|-------------------|---------|----------------------------------------------------|
| id                | integer | auto PK                                            |
| opponent_slug     | string  | FK → opponents.slug                                |
| level             | integer | 1-based, unique per opponent                       |
| description       | text    | nullable flavour text shown with cinematic         |
| relationship_gain | integer | nullable; relationship XP awarded on cinematic view |

Unique index on `(opponent_slug, level)`.

The background image URL previously stored on Cinematic is now stored as `background_url` on the associated Conversation.

### Item
Primary key is `slug`. Mirrors the frontend `EquipmentItem` interface.

| column       | type    | notes                                              |
|--------------|---------|----------------------------------------------------|
| slug         | string  | PK                                                 |
| name         | string  |                                                    |
| icon         | string  | emoji                                              |
| category     | string  | one of `Item::CATEGORIES`                          |
| quality      | string  | one of `Item::QUALITIES`                           |
| base_damage  | integer | nullable; weapon only                              |
| base_defense | integer | nullable; armour/shield/etc.                       |
Valid `category` values: `headgear bodyArmor weapon shield amulet ring charm gauntlets boots`  
Valid `quality` values: `rude normal rare legendary`

Enhancements are not stored on the backend — the frontend generates them dynamically based on quality and the affixes system.

### Gift
Belongs to an Opponent via `opponent_slug`. Auto integer PK.

| column        | type    | notes                   |
|---------------|---------|-------------------------|
| id            | integer | auto PK                 |
| opponent_slug | string  | FK → opponents.slug     |
| name          | string  |                         |
| gold          | integer | >= 0, default 0         |
| exp           | integer | >= 0, default 0         |

### Conversation
Polymorphic — belongs to Opponent (`has_many`), Gift (`has_many`), or Cinematic (`has_many`). Auto integer PK.

| column           | type    | notes                                                        |
|------------------|---------|--------------------------------------------------------------|
| id               | integer | auto PK                                                      |
| conversable_type | string  | "Opponent", "Gift", or "Cinematic"                           |
| conversable_id   | string  | FK to the conversable record                                 |
| background_url   | string  | nullable; public-folder path for the scene background image  |
| position         | integer | nullable; display order for cinematic/gift conversations     |

Cinematic and Gift conversations are displayed sequentially ordered by `position`. Opponent conversations are picked randomly.

### Chat
Belongs to Conversation. Ordered by `position`. Has many Sprites (polymorphic).

| column          | type    | notes                                                  |
|-----------------|---------|--------------------------------------------------------|
| id              | integer | auto PK                                                |
| conversation_id | integer | FK → conversations.id                                  |
| speaker         | string  | display name — `"Mitsu"`, commander name, or `""` (narrative) |
| position        | integer | ordering index within the conversation                 |
| content         | text    | dialogue text                                          |

`role` enum (`hero` / `opponent` / `other`) has been removed — use `speaker` instead. Seed YAML chats use the same field.

### Sprite
Polymorphic — currently belongs to Chat (`spriteable_type: "Chat"`). Represents a character displayed inside a scene (e.g. a hero standing in a room). There is no avatar rendered for a chat line; sprites replace that concept.

| column           | type    | notes                                         |
|------------------|---------|-----------------------------------------------|
| id               | integer | auto PK                                       |
| spriteable_type  | string  | polymorphic owner type (e.g. "Chat")          |
| spriteable_id    | integer | polymorphic owner id                          |
| url              | string  | public-folder path, required                  |
| x                | integer | nullable — pixel x offset in the scene        |
| y                | integer | nullable — pixel y offset in the scene        |
| width            | integer | nullable — display width in pixels            |
| height           | integer | nullable — display height in pixels           |
| flip             | boolean | default false — horizontal mirror when true   |

### OpponentMove (join table)
Links an opponent to its moves with an explicit position (0–3).

| column        | type    | notes                    |
|---------------|---------|--------------------------|
| id            | integer | auto PK                  |
| opponent_slug | string  | FK → opponents.slug      |
| move_slug     | string  | FK → moves.slug          |
| position      | integer | 0–3, battle slot order   |

Unique index on `(opponent_slug, move_slug)` and `(opponent_slug, position)`.  
The `Opponent` association loads them ordered by position automatically.

---

## JSON serialisation

Controllers serialise to camelCase to match the frontend interfaces. The mapping is:

| DB column / Ruby attr      | JSON key          | Notes                                          |
|----------------------------|-------------------|------------------------------------------------|
| `slug`                     | `id`              |                                                |
| `element_type`             | `type`            |                                                |
| `rarity`                   | `rarity`          | opponent only; enum string (`normal` `rare` `sr` `ssr` `lr`) |
| `mp_cost`                  | `mpCost`          |                                                |
| `base_damage`              | `baseDamage`      |                                                |
| `damage_variance`          | `damageVariance`  |                                                |
| `max_hp`                   | `maxHp`           |                                                |
| `max_level`                | `maxLevel`        |                                                |
| `effect_turns`             | `effectTurns`     | omitted from response when null                |
| `effect_damage`            | `effectDamage`    | omitted from response when null                |
| `effect_prob`              | `effectProb`      | omitted from response when null                |
| `leech`                    | `leech`           | omitted from response when null                |
| `effect_boost_percent`     | `effectBoostPercent` | omitted from response when null             |
| `effect_boost_kind`        | `effectBoostKind` | omitted from response when null (enum string)  |
| `gold_reward`              | `goldReward`      |                      |
| `flavour_text`             | `flavourText`     |                                                |
| `xp_reward_victory/defeat` | `xpReward`        |   |
| `unlock_after_list`        | `unlockAfter`     |                                                |
| `avatar`                   | `avatar`          |                |
| `cinematic association`    | `cinematics`      | array of `{ level, description?, relationshipGain? }` objects — background URL is on the conversation |
| `item.slug`                | `id`              | items resource                                 |
| `item.base_damage`         | `baseDamage`      | omitted when null                              |
| `item.base_defense`        | `baseDefense`     | omitted when null                              |
| `gift.slug`                | `id`              | gifts resource                                 |
| `conversation.id`          | `id`              | conversations resource                         |
| `conversation.background_url` | `backgroundUrl` | omitted when null                             |
| `conversation.position`    | `position`        | omitted when null; ordering for cinematic/gift |
| `chat.speaker`             | `speaker`         | string: `"Mitsu"`, commander name, or `""` (narrative) |
| `chat.position`            | `position`        |                                                |
| `chat.content`             | `content`         |                                                |
| `chat.sprites`             | `sprites`         | array of Sprite objects (url, x, y, width, height, flip) |

`move.icon` is **not** serialised — the frontend uses the `type` field to derive the icon.

`goldReward` and `xpReward` are serialised as `[min, max]` arrays — exactly the tuple shape the frontend expects.

`opponent.gacha_key` is **never** serialised as-is. `GET /api/v1/opponents` and `POST /api/v1/gacha` instead include `encryptedKey` (ciphertext) + `timestamp` — see [Gacha](#gacha).

---

## Gacha

`GET /api/v1/opponents` no longer returns every opponent. It requires `timestamp` + `keys[]` (encrypted `gacha_key` values) and returns only the matching opponents. `POST /api/v1/gacha` picks one random opponent and hands back its encrypted key so the frontend can "collect" it without ever seeing the bare key.

- `Opponent#gacha_key` — random string set via `before_validation :ensure_gacha_key, on: :create` in `app/models/opponent.rb`. Unique, required.
- `Opponent.gacha_pull` — weighted-random rarity roll (`Opponent::RARITY_WEIGHTS`: normal 60 / rare 20 / sr 12 / ssr 6 / lr 2), then a uniformly random opponent `where(rarity: picked_rarity)`. Returns `nil` if no opponent exists in the rolled tier.
- `GachaCipher` (`app/services/gacha_cipher.rb`) — `.encrypt(raw_key, timestamp)` / `.decrypt(encrypted_key, timestamp)`. AES-256-GCM, key derived from `secret_key_base` salted with the timestamp, 60s expiry window enforced on decrypt. Raises `GachaCipher::ExpiredError` / `GachaCipher::InvalidError` — both are treated as "this key doesn't resolve to an opponent" (filtered out silently, not a 4xx).
- `OpponentSerialization` concern (`app/controllers/concerns/opponent_serialization.rb`) — shared `serialize_opponent`/`serialize_move`/etc. used by both `OpponentsController` and `GachaController` so the two endpoints can't drift out of sync on the Opponent JSON shape. `serialize_opponent(opponent, timestamp:)` only adds `encryptedKey`/`timestamp` to the payload when a timestamp is passed.

Full CRUD (`show`, `create`, `update`, `destroy`) on `/api/v1/opponents/:id` is unaffected — those are admin/editor operations keyed by `slug`, unrelated to the gacha flow.

---

## Adding a new endpoint

1. Add the route in `config/routes.rb` under `namespace :api > namespace :v1`.
2. Create `app/controllers/api/v1/your_controller.rb` inside `module Api; module V1`.
3. Use `params.expect(model: [...])` for strong parameters (Rails 8 syntax).
4. Serialise to camelCase manually in a `serialize_*` private method — no serialiser gems.

---

## Adding a new model

1. Generate a migration: `bin/rails generate migration CreateThings`
2. Use string primary keys (`id: false` + `t.string :slug, primary_key: true`) when the record has a stable human-readable ID that the frontend uses directly.
3. Declare `self.primary_key = "slug"` in the model class.
4. Add to `db/seeds.rb` using `find_or_initialize_by(slug:)` so seeds are idempotent.

---

## Images (public folder)

Avatar URL are plain string stored in columns `avatar`. Files are placed under `public/images/opponents/<slug>/` and served as static assets by Rails.

Naming convention:
```
public/images/opponents/slime/avatar_1.webp   # level-1 avatar for slime
public/images/opponents/slime/cinematic_3.webp
```

To update a URL via console:
```ruby
Opponent.find("slime").update!(avatar: "/images/opponents/slime/avatar_1.webp")
```

No Active Storage is used for opponent images. The `active_storage_*` tables remain in the schema but are unused by opponents.

---

## CORS

Configured in `config/initializers/cors.rb`. Currently allows all methods from:
- `http://localhost:5173` (Vite dev server)
- `http://localhost:3000` (Rails itself)

To add a production origin:
```ruby
origins "https://your-app.example.com", "http://localhost:5173"
```

---

## Seeding

`db/seeds.rb` is **idempotent** — safe to re-run. It uses `find_or_initialize_by(slug:)` so existing records are updated rather than duplicated.

```bash
bin/rails db:seed          # run seeds
bin/rails db:schema:load   # reset schema from schema.rb (dev only)
bin/rails db:reset         # drop + create + migrate + seed
```

Seed data mirrors the frontend's `src/data/moves.ts` and `src/data/opponents.ts`. When the frontend adds new opponents or moves to those files, update `db/seeds.rb` to match.

---

## Common tasks

**Add a move via console:**
```ruby
Move.create!(
  slug: "waterBlast", name: "Water Blast", icon: "💧",
  description: "Blasts with water.", element_type: "water",
  mp_cost: 20, base_damage: 30, damage_variance: 0.2,
  level: 1, max_level: 5
)
```

**Assign moves to an opponent:**
```ruby
o = Opponent.find("slime")
o.opponent_moves.destroy_all
%w[venomStrike acidSpit toxicCloud poisonFang].each_with_index do |slug, i|
  o.opponent_moves.create!(move_slug: slug, position: i)
end
```

**Check what's seeded:**
```bash
bin/rails runner "puts Move.count; puts Opponent.includes(:moves).map { |o| [o.slug, o.moves.map(&:slug)] }.inspect"
```

---

## Environment variables

None required in development. The app runs on SQLite with no external dependencies.

For production, set:
- `RAILS_MASTER_KEY` — required to decrypt `config/credentials.yml.enc`
- `DATABASE_URL` — if switching away from SQLite
- Active Storage env vars if using cloud storage (see `config/storage.yml`)
