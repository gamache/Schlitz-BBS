class TransferOldData < ActiveRecord::Migration
  def self.up
    execute <<-EOSQL
      INSERT INTO threads (id, title, first_author_name, first_author_id, 
      first_post_at, last_author_name, last_author_id, last_post_at, nposts)
        SELECT tid, title, author, uid, firstpost, lastauthor, lastuid, 
        lastpost, nposts FROM old_threads;
    EOSQL

    execute <<-EOSQL  
      INSERT INTO posts (id, thread_id, author_id, author_name, ip_address, 
      email, subject, body, created_at)
        SELECT pid, tid, uid, author, ipaddr, email, subject, body, date 
        FROM old_posts;
    EOSQL
    
  end

  def self.down
    execute "TRUNCATE TABLE posts; TRUNCATE TABLE threads;"
  end
end

# t.string :title
# 
# t.integer :nposts
# 
# t.string :first_author_name
# t.integer :first_author_id
# t.datetime :first_post_at
# 
# t.string :last_author_name
# t.integer :last_author_id
# t.datetime :last_post_at

# old schema:
# create table threads (
#     tid         int not null primary key auto_increment,
#     uid         int,
#     firstpost   datetime,
#     lastpost    datetime,
#     lastauthor  varchar(32),
#     lastuid     int,
#     title       varchar(64) not null,
#     author      varchar(32),
#     nposts      int,
#     posts       text    
# );
# 


# new posts:
# t.integer :thread_id
# t.integer :author_id
# t.string :author_name
# t.string :ip_address
# t.string :email
# t.string :subject
# t.text :body
# t.text :edit_history
# 
# create table posts (
#     pid         int not null primary key auto_increment,
#     tid         int,
#     uid         int,
#     seq         int,            # placement in thread
#     ipaddr      varchar(16),
#     date        datetime,
#     author      varchar(32),
#     email       varchar(64),
#     showemail   boolean,
#     subject     varchar(64),
#     body        text,
#     nedits      int,
#     lastedit    datetime,
#     fulltext    (subject, body)
# );