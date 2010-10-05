class BBSThread < ActiveRecord::Base
  set_table_name :threads
  cattr_reader :per_page
  @@per_page = 50
end
