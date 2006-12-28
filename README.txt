                                                                        ..,,,..
                                            ,,;;|;;.,               .:;||||||||
  Schlitz BBS                       ,.;:;::;.         ;,           ;|''
                                   '`;....,.,.;:||:.   ||;.       ;|
  Version 1.1                   '';|||'`  ,|||;` ,...   ''`': ,. .|
                             ,.;:||||;:;;|||||||||''  .,.    . `|||
                            ''''`;|;'        ,;|;'.;;||' .;||  ./|| |
                             .;:;''`||||;'.,;||;';||;'.;;|||| ,'||| |.
                                  .;|||||||;''  .;|||;'  ,;||.;||||.`;;.
  INSTALLATION NOTES              '''''   ..   ;|||||.;;|||||';'`||;.
                                        ''' .;'  ;;|;||||;''|' , ;|;  ;||;. .:|
                                                ''  `;''      '   `;. `;|' .;`|
                                                                    `;.   ;:;.
   ,                                                                 `;,. ``''
  (k) 2006-2007   snarly   all rights reversed                         ;| | | |
                                                                        `:;;;;:


1. REQUIREMENTS

  Schlitz BBS requires the following programs and modules to run:

  *  Unix
  *  Perl (5.8 or greater), with modules:
     * DBI
     * DBD::mysql
     * CGI::Minimal
     * CGI::Cookie
  *  MySQL 5 Server
  *  Apache 2 with mod_rewrite
  *  lynx (required for transfer of old database, via slurp-scul.pl)


2. INSTALLATION

  a. First, unzip this directory into your Apache DocumentRoot directory (or
     somewhere else, if you know what you're doing).

  b. Edit schema.sql and conf.pl to reflect your desired MySQL setup.
     Be sure to adjust the username and password for the DB connection to
     suit your preference, and change $urlroot to reflect the root URL of
     the BBS.
     
  c. Create the Schlitz BBS database by using the following command:

     mysql -u root -p < schema.sql

  d. OPTIONAL: Transfer the contents of the old SCUL BBS into the new database
     by using the following command:

     perl slurp-scul.pl

  e. Copy the contents of schlitz-httpd.conf into your Apache httpd.conf file
     (or, again, another Apache config file, if you know what you're doing).
     You will need to update the location of the Schlitz BBS directory.

  f. Restart the Apache web server.

  g. View the BBS through a web browser.  Depending on whether you transferred
     the old SCUL BBS threads, there will be zero or many threads on the front
     page.


3. FEATURES

  Schlitz BBS offers the following features.  Improvements over the old BBS
  are marked with a plus.

  *  Anonymous, IP-logged posting of threads and replies.
  *  Shameless Web 0.9 aesthetics.
  +  Robust database-backed design.
  +  Basic and advanced searching of threads and replies.
  +  File upload and hosting services.
  +  Automatic linking of bare URLs.
  +  "Last Post" feature on thread index page.
  +  Automatic text wrapping when composing posts.


4. CODE AND AUTHORSHIP

  Schlitz BBS was written by Snarly <vms.snarly!@#$!@$gmail.com>.  It is
  released under the Lesser Schlitz BBS Public License (LSBBSPL), whose
  text is available nowhere.

  Schlitz BBS is written in Perl using the DBI database interface and the
  CGI::Minimal and CGI::Cookie modules.  HTML was largely ganked from the old
  board, and looks it.


5. I LOVE YOU

  Thanks to Threespeed and MegaSeth and the rest of Project Mayhem, without
  whose bit-diddling the new site wouldn't run.

  Special thanks to Hapto, beta-tester extraordinaire on the first versions
  of Schlitz BBS.

  
