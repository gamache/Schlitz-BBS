drop database sculbbs;

create database sculbbs;

grant all privileges on sculbbs.* to 'sculbbs'@'localhost'
  identified by 'tri-flow and girl-grease';

use sculbbs;



create table threads (
    tid         int not null primary key auto_increment,
    uid         int,
    firstpost   datetime,
    lastpost    datetime,
    lastauthor  varchar(32),
    lastuid     int,
    title       varchar(64) not null,
    author      varchar(32),
    nposts      int,
    posts       text    
);


create table posts (
    pid         int not null primary key auto_increment,
    tid         int,
    uid         int,
    seq         int,            # placement in thread
    ipaddr      varchar(16),
    date        datetime,
    author      varchar(32),
    email       varchar(64),
    showemail   boolean,
    subject     varchar(64),
    body        text,
    nedits      int,
    lastedit    datetime,
    fulltext    (subject, body)
);


create table users (
    uid         int not null primary key auto_increment,
    name        varchar(32),
    password    varchar(32),
    email       varchar(64),
    showemail   varchar(4),
    picurl      varchar(128),
    phone       varchar(32),
    address     varchar(128),
    im          varchar(64),
    profile     varchar(1024),
    other1      varchar(64),
    other2      varchar(64),
    dob         date,
    lastlogin   datetime,
    npics       int,
    pics        text,
    userpicid   int,
    theme       varchar(32),
    postmode    varchar(32),
    sig         varchar(256)
);


create table files (
    fid         int not null primary key auto_increment,
    uid         int,
    uploader    varchar(32),
    date        datetime,
    expires     datetime,
    contenttype varchar(32),
    name        varchar(32),
    descr       varchar(128),
    keywords    varchar(128),
    file        mediumblob,
    fulltext    (name, descr, keywords)
);

