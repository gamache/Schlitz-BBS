class Post < ActiveRecord::Base
  belongs_to :thread, :class_name => 'BBSThread', :foreign_key => :thread_id
  cattr_reader :per_page
  @@per_page = 10
end
