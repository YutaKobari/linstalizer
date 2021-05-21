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

ActiveRecord::Schema.define(version: 0) do
  create_table "access_logs", id: :integer, charset: "utf8mb4", force: :cascade do |t|
    t.integer  "user_id"
    t.string   "env"
    t.text     "url", limit: 65535
    t.string   "controller"
    t.string   "action"
    t.text     "headers", limit: 65535
    t.datetime "created_at", default: -> { "current_timestamp()" }
    t.datetime "updated_at", default: -> { "current_timestamp()" }
    t.index ["user_id"], name: "user_id", using: :btree
    t.index ["created_at"], name: "created_at", using: :btree
  end

  create_table "accounts", id: :integer, charset: "utf8mb4", force: :cascade do |t|
    t.integer "brand_id", null: false
    t.string "media"
    t.string "name"
    t.string "screen_name"
    t.string "icon_s3"
    t.date "max_posted_at"
    t.datetime "created_at", default: -> { "current_timestamp()" }
    t.datetime "updated_at", default: -> { "current_timestamp()" }
  end

  create_table "brand_lift_values", id: :integer, charset: "utf8", force: :cascade do |t|
    t.integer "brand_id", null: false
    t.integer "type_id"
    t.integer "keyword_id"
    t.date "date"
    t.float "value", limit: 53
    t.datetime "created_at", default: -> { "current_timestamp()" }
    t.datetime "updated_at", default: -> { "current_timestamp()" }
  end

  create_table "brand_lifts", id: :integer, charset: "utf8mb4", force: :cascade do |t|
    t.integer "brand_id", null: false
    t.date "date"
    t.integer "familiarity"
    t.datetime "created_at", default: -> { "current_timestamp()" }
    t.datetime "updated_at", default: -> { "current_timestamp()" }
  end

  create_table "brands", id: :integer, charset: "utf8mb4", force: :cascade do |t|
    t.integer "company_id", null: false
    t.integer "market_id"
    t.string "name"
    t.datetime "created_at", default: -> { "current_timestamp()" }
    t.datetime "updated_at", default: -> { "current_timestamp()" }
  end

  create_table "companies", id: :integer, charset: "utf8mb4", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", default: -> { "current_timestamp()" }
    t.datetime "updated_at", default: -> { "current_timestamp()" }
  end

  create_table "daily_account_engagements", id: :integer, charset: "utf8mb4", force: :cascade do |t|
    t.integer "account_id", null: false
    t.date "date"
    t.integer "follower"
    t.integer "line_follower"
    t.integer "post_count"
    t.integer "total_reaction"
    t.datetime "created_at", default: -> { "current_timestamp()" }
    t.datetime "updated_at", default: -> { "current_timestamp()" }
  end

  create_table "daily_account_informations", id: :integer, charset: "utf8mb4", force: :cascade do |t|
    t.integer "account_id", null: false
    t.date "date"
    t.string "key", comment: "valueカラムに入る値の種類(screen_name or introduction or icon_s3)"
    t.string "value"
    t.datetime "created_at", default: -> { "current_timestamp()" }
    t.datetime "updated_at", default: -> { "current_timestamp()" }
  end

  create_table "daily_hash_tag_post_counts", id: :integer, charset: "utf8mb4", force: :cascade do |t|
    t.integer "hash_tag_id", null: false
    t.date "date"
    t.integer "post_count"
    t.datetime "created_at", default: -> { "current_timestamp()" }
    t.datetime "updated_at", default: -> { "current_timestamp()" }
  end

  create_table "hash_tags", id: :integer, charset: "utf8mb4", force: :cascade do |t|
    t.string "name"
    t.string "media"
    t.datetime "created_at", default: -> { "current_timestamp()" }
    t.datetime "updated_at", default: -> { "current_timestamp()" }
  end

  create_table "landing_pages", id: :integer, charset: "utf8mb4", force: :cascade do |t|
    t.integer "crawl_status", default: 0
    t.integer "fix_status", default: 0
    t.integer "brand_id", null: false
    t.string "brand_name"
    t.text "redirect_url"
    t.string "url_hash", null: false
    t.string "landing_page_url"
    t.text "title"
    t.text "description", size: :medium
    t.text "keywords"
    t.string "thumbnail_s3"
    t.date "max_published_at"
    t.integer "retry_count", default: 0
    t.integer "lock_version", default: 0
    t.datetime "created_at", default: -> { "current_timestamp()" }
    t.datetime "updated_at", default: -> { "current_timestamp()" }
    t.index ["url_hash"], name: "url_hash_UNIQUE", unique: true
  end

  create_table "lp_combined_urls", id: :integer, charset: "utf8mb4", force: :cascade, options: "ENGINE=Mroonga" do |t|
    t.string "url_hash"
    t.text "combined_url"
    t.integer "brand_id", null: false
    t.datetime "created_at", default: -> { "current_timestamp()" }
    t.datetime "updated_at", default: -> { "current_timestamp()" }
    t.index ["combined_url"], name: "combined_url", type: :fulltext
  end

  create_table "lp_search_ngrams", id: :integer, charset: "utf8mb4", force: :cascade, options: "ENGINE=Mroonga" do |t|
    t.string "url_hash"
    t.text "search_ngram", size: :medium, collation: "utf8mb4_general_ci"
    t.integer "brand_id", null: false
    t.datetime "created_at", default: -> { "current_timestamp()" }
    t.datetime "updated_at", default: -> { "current_timestamp()" }
    t.index ["search_ngram"], name: "search_ngram", type: :fulltext
  end

  create_table "markets", id: :integer, charset: "utf8mb4", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", default: -> { "current_timestamp()" }
    t.datetime "updated_at", default: -> { "current_timestamp()" }
  end

  create_table "post_contents", id: :integer, charset: "utf8mb4", force: :cascade do |t|
    t.integer "post_id", null: false
    t.string "raw_post_id", null: false
    t.string "content_url"
    t.string "video_url"
    t.datetime "created_at", default: -> { "current_timestamp()" }
    t.datetime "updated_at", default: -> { "current_timestamp()" }
  end

  create_table "post_hash_tags", id: :integer, charset: "utf8mb4", force: :cascade do |t|
    t.integer "post_id", null: false
    t.integer "hash_tag_id", null: false
    t.datetime "created_at", default: -> { "current_timestamp()" }
    t.datetime "updated_at", default: -> { "current_timestamp()" }
  end

  create_table "post_like_counts", id: :integer, charset: "utf8mb4", force: :cascade do |t|
    t.integer "post_id", null: false
    t.string "raw_post_id", null: false
    t.integer "account_id", null: false
    t.datetime "datetime"
    t.integer "like_count"
    t.datetime "created_at", default: -> { "current_timestamp()" }
    t.datetime "updated_at", default: -> { "current_timestamp()" }
  end

  create_table "post_retweet_counts", id: :integer, charset: "utf8mb4", force: :cascade do |t|
    t.integer "post_id", null: false
    t.string "raw_post_id", null: false
    t.integer "account_id", null: false
    t.datetime "datetime"
    t.integer "retweet_count"
    t.datetime "created_at", default: -> { "current_timestamp()" }
    t.datetime "updated_at", default: -> { "current_timestamp()" }
  end

  create_table "posts", id: :integer, charset: "utf8mb4", force: :cascade,  options: "ENGINE=Mroonga" do |t|
    t.integer "account_id", null: false
    t.integer "brand_id"
    t.string "media"
    t.string "post_type"
    t.boolean "is_img", default: 1
    t.string "content_url"
    t.string "video_url"
    t.text "text"
    t.string "url_hash", null: false
    t.text "redirect_url"
    t.text "landing_page_url"
    t.string "purpose"
    t.datetime "posted_at"
    t.date "posted_on"
    t.integer "day", comment: "何曜日の投稿か（0:月〜6:日）。ヒートマップグラフで使う。"
    t.integer "hour", comment: "何時台に投稿されたか。ヒートマップグラフで使う。"
    t.integer "like_count", comment: "今日時点でのいいね数。"
    t.integer "retweet_count", comment: "今日時点でのリツイート数。"
    t.string "raw_post_id", comment: "掲載元SNSで定義されているID。バッチでpost_like_countsなどを作るときに使う。"
    t.datetime "created_at", default: -> { "current_timestamp()" }
    t.datetime "updated_at", default: -> { "current_timestamp()" }
    t.index ["text"], name: "text", type: :fulltext
  end

  create_table "rich_menu_contents", id: :integer, charset: "utf8mb4", force: :cascade do |t|
    t.integer "account_id", null: false
    t.string "raw_post_id", null: false
    t.integer "linepostback_status", default: 0, comment: "0:未着手,1:リクエスト作成,2:クロール完了"
    t.string "group_hash", null: false
    t.string "action"
    t.string "destination_menu_raw_id", comment: "actionがrichmenuの場合に遷移先のリッチメニューのraw_post_idを記録する"
    t.string "content_url"
    t.string "url_hash"
    t.text "redirect_url"
    t.text "position"
    t.datetime "created_at", default: -> { "current_timestamp()" }
    t.datetime "updated_at", default: -> { "current_timestamp()" }
  end

  create_table "rich_menus", id: :integer, charset: "utf8mb4", force: :cascade do |t|
    t.integer "account_id", null: false
    t.string "raw_post_id", null: false
    t.integer "layer", default: 0
    t.date "date_from"
    t.date "date_to"
    t.string "content_url", limit: 45
    t.string "group_hash", null: false
    t.datetime "created_at", default: -> { "current_timestamp()" }
    t.datetime "updated_at", default: -> { "current_timestamp()" }
  end

  create_table "talk_post_contents", id: :integer, charset: "utf8mb4", force: :cascade, options: "ENGINE=Mroonga" do |t|
    t.integer "account_id", null: false
    t.integer "brand_id"
    t.boolean "is_img", default: 1
    t.string "post_type"
    t.string "content_url"
    t.string "video_url"
    t.text "text"
    t.string "url_hash", null: false
    t.string "redirect_url"
    t.string "purpose"
    t.datetime "posted_at"
    t.string "raw_post_id"
    t.string "talk_group_hash"
    t.string "group_hash"
    t.datetime "created_at", default: -> { "current_timestamp()" }
    t.datetime "updated_at", default: -> { "current_timestamp()" }
    t.index ["text"], name: "text", type: :fulltext
  end

  create_table "talk_posts", id: :integer, charset: "utf8mb4", force: :cascade do |t|
    t.integer "account_id", null: false
    t.integer "brand_id"
    t.datetime "posted_at"
    t.date "posted_on"
    t.integer "day"
    t.integer "hour"
    t.string "raw_post_id"
    t.string "talk_group_hash"
    t.datetime "created_at", default: -> { "current_timestamp()" }
    t.datetime "updated_at", default: -> { "current_timestamp()" }
  end

  create_table "favorites", charset: "utf8mb4", force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "account_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "users", charset: "utf8mb4", force: :cascade do |t|
    t.integer "contractor_id", null: false
    t.string "name", default: "", null: false
    t.string "email", default: "", null: false
    t.boolean "is_admin", default: false, null: false
    t.boolean "is_available", default: true, null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  create_table "notifications", id: :integer, charset: "utf8mb4", force: :cascade do |t|
    t.string "title", limit: 500, null: false
    t.boolean "is_active", default: false, null: false
    t.datetime "posted_at"
    t.datetime "created_at", default: -> { "current_timestamp()" }, null: false
    t.datetime "update_at", default: -> { "current_timestamp()" }
  end

  create_table "contractors", id: :integer, charset: "utf8mb4", force: :cascade do |t|
    t.string   "name"
    t.date     "contract_started_on"
    t.date     "contract_finished_on"
    t.boolean  "is_available", default: true
    t.datetime "created_at", default: -> { "current_timestamp()" }, null: false
    t.datetime "update_at", default: -> { "current_timestamp()" }
  end
end
