class RenameOldTables < ActiveRecord::Migration
  def self.up
    begin
      rename_table :posts, :old_posts
      rename_table :threads, :old_threads
      rename_table :users, :old_users
    rescue
      nil
    end
  end

  def self.down
    begin 
      rename_table :old_posts, :posts
      rename_table :old_threads, :threads
      rename_table :old_users, :users
    rescue
      nil
    end
  end
end
