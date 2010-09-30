# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20100930094453) do

  create_table "chat", :force => true do |t|
    t.integer  "uid",  :default => 0, :null => false
    t.datetime "date"
    t.text     "body"
  end

  create_table "files", :primary_key => "fid", :force => true do |t|
    t.integer  "uid"
    t.string   "uploader",    :limit => 32
    t.datetime "date"
    t.datetime "expires"
    t.string   "contenttype", :limit => 32
    t.string   "name",        :limit => 32
    t.string   "descr",       :limit => 128
    t.string   "keywords",    :limit => 128
    t.binary   "file",        :limit => 16777215
  end

  add_index "files", ["name", "descr", "keywords"], :name => "name"

  create_table "old_posts", :primary_key => "pid", :force => true do |t|
    t.integer  "tid"
    t.integer  "uid"
    t.integer  "seq"
    t.string   "ipaddr",    :limit => 16
    t.datetime "date"
    t.string   "author",    :limit => 32
    t.string   "email",     :limit => 64
    t.boolean  "showemail"
    t.string   "subject",   :limit => 64
    t.text     "body"
    t.integer  "nedits"
    t.datetime "lastedit"
  end

  add_index "old_posts", ["subject", "body"], :name => "subject"

  create_table "old_threads", :primary_key => "tid", :force => true do |t|
    t.integer  "uid"
    t.datetime "firstpost"
    t.datetime "lastpost"
    t.string   "lastauthor", :limit => 32
    t.integer  "lastuid"
    t.string   "title",      :limit => 64, :default => "", :null => false
    t.string   "author",     :limit => 32
    t.integer  "nposts"
    t.text     "posts"
  end

  create_table "old_users", :primary_key => "uid", :force => true do |t|
    t.string   "name",      :limit => 32
    t.string   "password",  :limit => 32
    t.string   "email",     :limit => 64
    t.string   "showemail", :limit => 4
    t.string   "picurl",    :limit => 128
    t.string   "phone",     :limit => 32
    t.string   "address",   :limit => 128
    t.string   "im",        :limit => 64
    t.text     "profile"
    t.string   "other1",    :limit => 64
    t.string   "other2",    :limit => 64
    t.date     "dob"
    t.datetime "lastlogin"
    t.integer  "npics"
    t.text     "pics"
    t.integer  "userpicid"
    t.string   "theme",     :limit => 32
    t.string   "postmode",  :limit => 32
    t.text     "sig"
  end

  create_table "posts", :force => true do |t|
    t.integer  "thread_id"
    t.integer  "author_id"
    t.string   "author_name"
    t.string   "ip_address"
    t.string   "email"
    t.string   "subject"
    t.text     "body"
    t.text     "edit_history"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "posts", ["author_id"], :name => "index_posts_on_author_id"
  add_index "posts", ["thread_id"], :name => "index_posts_on_thread_id"

  create_table "prefs", :primary_key => "prefid", :force => true do |t|
    t.integer "uid"
    t.string  "name",  :limit => 32
    t.text    "value"
  end

  create_table "threads", :force => true do |t|
    t.string   "title"
    t.integer  "nposts"
    t.string   "first_author_name"
    t.integer  "first_author_id"
    t.datetime "first_post_at"
    t.string   "last_author_name"
    t.integer  "last_author_id"
    t.datetime "last_post_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", :force => true do |t|
    t.string   "name"
    t.string   "email"
    t.text     "preferences"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
