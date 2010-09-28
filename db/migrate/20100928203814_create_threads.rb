class CreateThreads < ActiveRecord::Migration
  def self.up
    begin
      rename_table :threads, :old_threads
    rescue
      nil
    end
    
    create_table :threads do |t|
      t.string :title
      
      t.string :first_author_name
      t.integer :first_author_id
      t.datetime :first_post_at
      
      t.string :last_author_name
      t.integer :last_author_id
      t.datetime :last_post_at
      
      t.timestamps
    end
  end

  def self.down
    drop_table :threads
    begin
      rename_table :old_threads, :threads
    rescue
      nil
    end
  end
end

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