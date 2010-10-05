class BBSThread < ActiveRecord::Base
  set_table_name :threads
  has_many :posts, :foreign_key => :thread_id
  cattr_reader :per_page
  @@per_page = 50
end
