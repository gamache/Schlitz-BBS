#!/opt/local/bin/perl

#use warnings;
use strict;

use DBI;

my ($dbh, $sth, $cmd);
$dbh = DBI->connect('dbi:mysql:sculbbs:127.0.0.1:3306', 'sculbbs', 'tri-flow and girl-grease') or die $dbh->errstr;




for (my $i=29; $i>1; $i--) {
	my $page = `lynx -source http://70.96.188.36/~sculorg/classified/posts/$i.html`;
	next if ($page =~ /404 Not Found/);
	
	print "eating $i...";
	my $nposts = eat_posts ($page, $i, 0);
	print "done, $nposts posts recorded.\n";
}



sub eat_posts {
	my ($page, $tid, $nposts) = @_;
	

	if ($nposts == 0) {
		create_thread ($page, $tid);
	}
	
	
	
	while ($page =~ m{
	([^<>]+)							# pilot
	<br>Pilot<br>
	(.*?)								# email string
	<br><br>
	(\d+/\d+/\d+)						# date m/d/yyyy
	<br>
	(\d+:\d+:\d+)						# time hh:mm:ss
	<br> .+? \s*
	<u> \s* 
	(.+?) 								# subject
	\s* </u> .+? \s*
	(?:begin \s* transmission|Message):(?:<br>){1,2} \s*
	(.+?) \s*							# body
	</font></td></tr>
	}xsg)	{

		my ($author, $email, $date, $time, $subject, $body) = 
			($1, $2, $3, $4, $5, $6);
			
#		print "\n\n$author, $email, $date, $time, $subject, $body\n\n";
			
		$body =~ s/"/\\"/g;
		$subject =~ s/"/\\"/g;
		
		$subject =~ s/^\s*Subject:\s*//;
		
		$body =~ s/:end transmission.*$//;
		$body =~ s/(<br>)+$//;
		
		$date =~ m|(\d+)/(\d+)/(\d+)|;
		$date = sprintf "%.4d-%.2d-%.2d", $3, $1, $2;
		
		if ($email =~ /mailto:(.+?)"/) { $email = $1 }
		else { $email = '' }
		
		$cmd = <<EOT
insert into posts (tid, seq, author, email, date, subject, body) values 
  ($tid, $nposts, "$author", "$email", "$date $time", "$subject", "$body")
EOT
	;
		$sth = $dbh->prepare ($cmd) or die $sth->errstr;
		$sth->execute;
		$sth->finish;
	
		$sth = $dbh->prepare ('select last_insert_id()') or die $sth->errstr;
		$sth->execute;
		my @a = $sth->fetchrow_array;
		$sth->finish;
		
		my $pid = $a[0];
		
		
		$cmd = qq|select nposts,posts from threads where tid="$tid"|;
		$sth = $dbh->prepare ($cmd) or die 
			"Couldn't prepare statement: $dbh->errstr";
		$sth->execute or die
			"Couldn't execute statement: $cmd";
		
		@a = $sth->fetchrow_array;
		$sth->finish;
	
		my $tnposts = $a[0] + 1;	
		my $posts = $a[1];
		if ($posts ne '') { $posts .= ",$pid" }
		else { $posts = "$pid" }
	
		$cmd = <<EOT
update threads set 
  nposts=$tnposts, posts="$posts", lastpost="$date $time", 
  lastauthor="$author"
  where tid=$tid
EOT
;
	
		$sth = $dbh->prepare ($cmd) or die $sth->errstr;
		$sth->execute;
		$sth->finish;
		
		$nposts++;			
	}
	
	

	if ($page =~ m|Next Page<a href="(.+?)">|) {
		my $nextpage = `lynx -source $1`;
		$nposts = eat_posts ($nextpage, $tid, $nposts);
	}
	
	return $nposts;
}




sub create_thread {
	my ($page, $tid) = @_;
	
	$page =~ m|<title>(.+?)</title>|;
	my $title = $1;
	
	$page =~ m|.*?<tr><td valign="top" bgcolor="#......"><font color="#......" face="Courier" size="4">(.+?)<br>Pilot<br>.*?<br><br>(\d+/\d+/\d+)<br>(\d+:\d+:\d+)<br>|s;

	my ($author, $date, $time) = ($1, $2, $3);
	
	$date =~ m|(\d+)/(\d+)/(\d+)|;
	$date = sprintf "%.4d-%.2d-%.2d", $3, $1, $2;
	
	$cmd = <<EOT
insert into threads (tid, title, author, firstpost) values 
  ($tid, "$title", "$author", "$date $time")
EOT
;
	
	$sth = $dbh->prepare ($cmd) or die $sth->errstr;
	$sth->execute;
	$sth->finish;
}




