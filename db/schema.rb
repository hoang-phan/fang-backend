# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2026_06_18_110343) do
  create_table "active_storage_attachments", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.bigint "record_id", null: false
    t.string "record_type", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.string "content_type"
    t.datetime "created_at", null: false
    t.string "filename", null: false
    t.string "key", null: false
    t.text "metadata"
    t.string "service_name", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "moves", primary_key: "slug", id: :string, force: :cascade do |t|
    t.integer "base_damage", default: 0, null: false
    t.integer "base_defense"
    t.datetime "created_at", null: false
    t.float "damage_variance", default: 0.2, null: false
    t.text "description"
    t.integer "effect_damage"
    t.float "effect_prob"
    t.boolean "effect_stun"
    t.integer "effect_turns"
    t.string "element_type", default: "normal", null: false
    t.string "icon"
    t.float "leech"
    t.integer "level", default: 1, null: false
    t.integer "max_level", default: 5, null: false
    t.integer "mp_cost", default: 0, null: false
    t.string "name", null: false
    t.datetime "updated_at", null: false
  end

  create_table "opponent_moves", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "move_slug", null: false
    t.string "opponent_slug", null: false
    t.integer "position", default: 0, null: false
    t.datetime "updated_at", null: false
    t.index ["opponent_slug", "move_slug"], name: "index_opponent_moves_on_opponent_slug_and_move_slug", unique: true
    t.index ["opponent_slug", "position"], name: "index_opponent_moves_on_opponent_slug_and_position"
  end

  create_table "opponents", primary_key: "slug", id: :string, force: :cascade do |t|
    t.string "avatar_1"
    t.string "avatar_2"
    t.string "avatar_3"
    t.string "avatar_4"
    t.string "avatar_5"
    t.integer "base_damage", default: 10, null: false
    t.string "cinematic_1"
    t.string "cinematic_2"
    t.string "cinematic_3"
    t.string "cinematic_4"
    t.string "cinematic_5"
    t.datetime "created_at", null: false
    t.float "damage_variance", default: 0.2, null: false
    t.string "element_type", default: "normal", null: false
    t.text "flavour_text"
    t.integer "gold_reward_max", default: 15, null: false
    t.integer "gold_reward_min", default: 5, null: false
    t.integer "level", default: 1, null: false
    t.integer "max_hp", default: 100, null: false
    t.string "name", null: false
    t.text "unlock_after"
    t.datetime "updated_at", null: false
    t.integer "xp_reward_defeat", default: 10, null: false
    t.integer "xp_reward_victory", default: 50, null: false
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
end
