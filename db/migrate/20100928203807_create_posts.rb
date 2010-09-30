class CreatePosts < ActiveRecord::Migration
  def self.up
    create_table :posts do |t|
      t.integer :thread_id
      t.integer :author_id
      t.string :author_name
      t.string :ip_address
      t.string :email
      t.string :subject
      t.text :body
      t.text :edit_history

      t.timestamps
    end
    
    add_index :posts, :thread_id
    add_index :posts, :author_id
  end

  def self.down
    remove_index :posts, :thread_id
    remove_index :posts, :author_id
    drop_table :posts
  end
end

# old schema: 
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