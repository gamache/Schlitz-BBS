class CreateUsers < ActiveRecord::Migration
  def self.up
    create_table :users do |t|
      t.string :name
      t.string :email
      t.text :preferences
      t.timestamps
    end
  end

  def self.down
    drop_table :users
  end
end

# old schema:
# create table users (
#     uid         int not null primary key auto_increment,
#     name        varchar(32),
#     password    varchar(32),
#     email       varchar(64),
#     showemail   varchar(4),
#     picurl      varchar(128),
#     phone       varchar(32),
#     address     varchar(128),
#     im          varchar(64),
#     profile     varchar(1024),
#     other1      varchar(64),
#     other2      varchar(64),
#     dob         date,
#     lastlogin   datetime,
#     npics       int,
#     pics        text,
#     userpicid   int,
#     theme       varchar(32),
#     postmode    varchar(32),
#     sig         varchar(256)
# );