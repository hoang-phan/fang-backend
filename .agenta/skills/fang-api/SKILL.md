---
name: fang-api
description: Backend development assistant for fang-backend. Enforces reading docs/api.md and docs/dev.md before implementing or changing anything, to keep the API contract stable and conventions consistent.
argument-hint: '[feature, endpoint, or bug description]'
---

# Fang API Workflow

Before writing any code, read the docs to understand the existing contract and conventions.

## Step 1: Read the docs first

Always open both documents before doing anything else:

- `docs/api.md` — the canonical API reference: all endpoints, request shapes, response shapes, error format, image serving, curl examples
- `docs/dev.md` — the developer guide: project layout, data model, serialisation mapping, how to add models/endpoints, Active Storage, seeding, CORS

Do not guess field names, serialisation rules, or JSON shapes. Verify everything against these docs.

## Step 2: Understand the existing code

After reading the docs, read the relevant source file(s) before changing them:

- Endpoint work → `app/controllers/api/v1/`
- Model/validation work → `app/models/`
- Schema change → `db/migrate/` (latest), `db/seeds.rb`
- CORS or config → `config/initializers/cors.rb`, `config/routes.rb`

Match every convention you find: `params.expect`, camelCase serialisation in `serialize_*` private methods, string primary keys, `find_or_initialize_by` in seeds.

## Step 3: Check the serialisation mapping

The JSON keys sent to the frontend are **not** the column names. The mapping lives in `docs/dev.md` under "JSON serialisation". Before adding or renaming a field, confirm:

1. What is the column/attribute name in Ruby?
2. What camelCase key does the frontend expect?
3. Does that key exist in the frontend's `Move`, `OpponentDef`, or `Chat` TypeScript interface?

If adding a new field that the frontend doesn't have yet, flag it — the frontend type may need updating too (in `../fang/src/types/index.ts`).

## Step 4: Implement

Only after Steps 1–3, write or change code:

- New endpoint: route → controller action → `serialize_*` method
- New model: migration (`id: false` + string PK if it has a slug) → model validations → seed entry
- New image slot: `has_one_attached :name` in model → `attach_images` in controller → `serialize_opponent` URL array
- Chat `speaker` field: string display name — `"Mitsu"` (hero), the commander/opponent name, or `""` (narrative / stage direction). Replaces the old `role` enum (`hero` / `opponent` / `other`). Serialise as-is in `serialize_chat`. Seed YAML chats use `speaker` the same way (see conversation-editor gem contract).
- Sprites: polymorphic `has_many :sprites, as: :spriteable` on Chat. Serialise as `{ url, x, y, width, height }` array — omit nil position/size fields or include them as null depending on frontend contract. Sprites represent characters displayed inside a scene, not avatar icons.
- Schema change: generate a new migration, never edit existing ones

Always keep `db/seeds.rb` idempotent. Use `find_or_initialize_by(slug:).tap { |r| r.assign_attributes(...); r.save! }`.

## Step 5: Update docs

After any change to the API surface or data model, update both docs:

- `docs/api.md` — add/update the endpoint, request fields, response example
- `docs/dev.md` — update the data model table, serialisation mapping, or common tasks section as needed

The docs are the contract. An undocumented change is an incomplete change.

## Step 6: Verify

```bash
bin/rails db:migrate          # if schema changed
bin/rails db:seed             # if seeds changed (must be idempotent)
bin/rails routes | grep api   # confirm route exists
bin/rails runner "puts Model.count"  # confirm data looks right
curl http://localhost:3000/api/v1/<resource> | jq .  # smoke test the response shape
```

Check the JSON keys in the response match what the frontend's TypeScript interface expects.
