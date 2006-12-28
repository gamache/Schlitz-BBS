#!/usr/bin/perl

use warnings;
use strict;

use CGI::Minimal;
use DBI;

my ($urlroot, $dsn, $user, $pass, $tpp, $ppp, $spp);
my $ipaddr = $ENV{REMOTE_ADDR};

# read config file

if (open CONF, 'conf.pl') {
	while (<CONF>) { eval }
	close CONF;
}

my $cgi = CGI::Minimal->new;
my $dbh = DBI->connect ($dsn, $user, $pass);
my $cmd;
my $sth;

print "Content-type:text/html\n\n";

## end boilerplate


my $author = $cgi->param('author');
my $email = $cgi->param('email');
my $subject = $cgi->param('subject');
my $body = $cgi->param('body');
my $tid = $cgi->param('tid');
my $sure = $cgi->param('sure');


## show preview page if necessary

if ($sure ne 'yes') {
	print_verify_page ();
	exit 0;
}



## un-armor the data coming from the preview page, and armor quotes

$author 	= CGI::Minimal->url_decode ($author);
$subject	= CGI::Minimal->url_decode ($subject);
$body		= CGI::Minimal->url_decode ($body);

## backslash quotes

$author  =~ s/"/\\"/g;
$subject =~ s/"/\\"/g;
$body    =~ s/"/\\"/g;


## do some basic sanity checks on post content

if ($author =~ /^\s*$/) {
	print_missing_author_page ();
	exit 0;
}

if ($subject =~ /^\s*$/) {
	print_missing_subject_page ();
	exit 0;
}

if ($author =~ /[<>]/) {
	print_html_author_page ();
	exit 0;
}

if ($subject =~ /[<>]/) {
	print_html_subject_page ();
	exit 0;
}

if ($email !~ /^[\w\.]+\@[\w\.]+$/ && $email ne '') {
	print_bad_email_page ();
	exit 0;
}

if ($body =~ /^\s*$/) {
	print_blank_body_page ();
	exit 0;
}





if ($tid eq 'new') {	# new topic
	$cmd = <<EOT
insert into threads (author, title, firstpost) values 
  ("$author", "$subject", now())
EOT
;
	$sth = $dbh->prepare ($cmd) or die 
		"Couldn't prepare statement: $dbh->errstr";
	$sth->execute or die
		"Couldn't execute statement: $cmd";
	$sth->finish;
	
	$sth = $dbh->prepare ('select last_insert_id()') or die 
		"Couldn't prepare statement: $dbh->errstr";
	$sth->execute or die
		"Couldn't execute statement: $cmd";
	
	my @a = $sth->fetchrow_array;
	$tid = $a[0];

	$sth->finish;
}





$cmd = <<EOT
insert into posts (
  tid, ipaddr, date, author, email, subject, body
) values (
  $tid, "$ipaddr", now(), "$author", "$email", "$subject", "$body"
)
EOT
;

$sth = $dbh->prepare ($cmd) or die 
	"Couldn't prepare statement: $dbh->errstr";
$sth->execute or die
	"Couldn't execute statement: $cmd";
$sth->finish;


$sth = $dbh->prepare ('select last_insert_id()') or die 
	"Couldn't prepare statement: $dbh->errstr";
$sth->execute or die
	"Couldn't execute statement: $cmd";
	
my @a = $sth->fetchrow_array;
my $pid = $a[0];

$sth->finish;


$cmd = qq|select nposts,posts from threads where tid="$tid"|;
$sth = $dbh->prepare ($cmd) or die 
	"Couldn't prepare statement: $dbh->errstr";
$sth->execute or die
	"Couldn't execute statement: $cmd";
	
@a = $sth->fetchrow_array;
$sth->finish;

my $seq = $a[0] + 0;
my $nposts = $a[0] + 1;	
my $posts = $a[1];
if ($posts ne '') { $posts .= ",$pid" }
else { $posts = "$pid" }


$cmd = <<EOT
update threads 
  set nposts=$nposts, posts="$posts", lastpost=now(), lastauthor="$author"
  where tid=$tid
EOT
;

$sth = $dbh->prepare ($cmd) or die 
	"Couldn't prepare statement: $dbh->errstr";
$sth->execute or die
	"Couldn't execute statement: $cmd";
$sth->finish;


$cmd = qq|update posts set seq=$seq where pid=$pid|;
$sth = $dbh->prepare ($cmd) or die 
	"Couldn't prepare statement: $dbh->errstr";
$sth->execute or die
	"Couldn't execute statement: $cmd";
$sth->finish;

$dbh->disconnect;
print_success_page ("$urlroot/t/$tid," . (int (($nposts-2)/$ppp)*$ppp) . "#$pid");







sub print_verify_page {

	# auto-convert line breaks
	
	$body =~ s/\n/\n<br>/g;
	
	# auto-link bare urls
	
	$body = " $body";
	$body =~ s|([^="])(http://\S+)|$1<a href="$2">$2</a>|gi;
	$body =~ s/^ //;
	
	my $safeauthor 	= CGI::Minimal->url_encode ($author);
	my $safebody 	= CGI::Minimal->url_encode ($body);
	my $safesubject	= CGI::Minimal->url_encode ($subject);
	
		
	$sth = $dbh->prepare('select now()');
	$sth->execute;
	my @n = $sth->fetchrow_array;
	my $date = $n[0];

	print <<EOT
<html>
<head>
<link rel="shortcut icon" href="../../favicon.gif">
<title>SCUL Forum</title>
</head>
<body bgcolor="black" text="silver" link="blue" alink="red" vlink="#333390">
<font color="#909090" face="Courier" size="2"><b>Preview Post:</b></font>

<table border="0" width="775"><tr bgcolor="#080808"><td bgcolor="#080808" width="15%"><font color="#0000FF" face="Courier" size="4">From</font></td><td bgcolor="#080808">
<font color="#0000FF" face="Courier" size="4">Message</font></td></tr>
<tr bgcolor="#050505"><td valign="top"><font color="#909090" face="Courier" size="4">$author<br>Pilot<br>
EOT
;

	if ($email ne '') {
		print <<EOT
&nbsp;
<a href="mailto:$email"><img src="$urlroot/images/email.gif" border="0" alt="Email"></a>
EOT
;
	}
	
	print <<EOT
<br><br>$date</font></td><td valign="top">

<font color="#909090" face="Courier" size="4">
<img src="$urlroot/images/document.gif" border="0"> <u>Subject: $subject</u><br><font size="-1">IP: Logged</font><br><br>

begin transmission:<br><br>$body<br><br>:end transmission</font><br></td></tr></table>
<form action="$urlroot/post.pl" method="post">

<input type="hidden" name="subject" value="$safesubject">
<input type="hidden" name="author" value="$safeauthor">
<input type="hidden" name="email" value="$email">
<input type="hidden" name="body" value="$safebody">
<input type="hidden" name="sure" value="yes">
<input type="hidden" name="tid" value="$tid">
<input type="submit" value="Post Now!"></form>

<br><hr size="1" noshadow>
<a href="search.pl">Search SCUL Forum</a>


</body>
</html>

EOT
;
}


sub print_success_page {
	my $link = shift;
	
	print <<EOT
<html>
<head>
<link rel="shortcut icon" href="../../favicon.gif">
<title>SCUL Forum</title>
</head>
<body bgcolor="black" text="silver" link="blue" alink="red" vlink="#333390">
<font color="#909090" face="Courier" size="4"><h2>Thank You!</h2> Your message has been posted.<br>

You can find your message <a href="$link">here</a>.<br>

Please click <a href="index.pl">here</a>, if you want to return to the message index page.<br></font>
<br><hr size="1" noshadow>
<a href="search.pl">Search SCUL Forum</a>

</body>
</html>
EOT
}





sub print_missing_author_page { print <<EOT
<html>
<head>
<link rel="shortcut icon" href="../../favicon.gif">
<title>SCUL Forum</title>
</head>
<body bgcolor="black" text="silver" link="blue" alink="red" vlink="#333390">
<font color="#909090" face="Courier" size="4"><h2>Unable to post the message</h2>
The subject field is missing or blank.<br>
<font><br><hr size="1" noshadow>
<a href="search.pl">Search SCUL Forum</a>

</body>
</html>
EOT
}

sub print_html_author_page { print <<EOT
<html>
<head>
<link rel="shortcut icon" href="../../favicon.gif">
<title>SCUL Forum</title>
</head>
<body bgcolor="black" text="silver" link="blue" alink="red" vlink="#333390">
<font color="#909090" face="Courier" size="4"><h2>Unable to post the message</h2>
Weird symbols or HTML tags are not allowed in the name field.<br>
<font><br><hr size="1" noshadow>
<a href="http://crufthenge.mit.edu/scul/search.html">Search SCUL Forum and/or Website</a>
</body>
</html>
EOT
}

sub print_html_subject_page { print <<EOT
<html>
<head>
<link rel="shortcut icon" href="../../favicon.gif">
<title>SCUL Forum</title>
</head>
<body bgcolor="black" text="silver" link="blue" alink="red" vlink="#333390">
<font color="#909090" face="Courier" size="4"><h2>Unable to post the message</h2>
Weird symbols or HTML tags are not allowed in the subject field.<br>
<font><br><hr size="1" noshadow>
<a href="search.pl">Search SCUL Forum</a>

</body>
</html>
EOT
}

sub print_bad_email_page { print <<EOT
<html>
<head>
<link rel="shortcut icon" href="../../favicon.gif">
<title>SCUL Forum</title>
</head>
<body bgcolor="black" text="silver" link="blue" alink="red" vlink="#333390">
<font color="#909090" face="Courier" size="4"><h2>Unable to post the message</h2>
You have entered an invalid email address.<br>
<font><br><hr size="1" noshadow>
<a href="search.pl">Search SCUL Forum</a>

</body>
</html>
EOT
}

sub print_blank_body_page { print <<EOT
<html>
<head>
<link rel="shortcut icon" href="../../favicon.gif">
<title>SCUL Forum</title>
</head>
<body bgcolor="black" text="silver" link="blue" alink="red" vlink="#333390">
<font color="#909090" face="Courier" size="4"><h2>Unable to post the message</h2>
The message field is missing or blank<br>
<font><br><hr size="1" noshadow>
<a href="search.pl">Search SCUL Forum</a>

</body>
</html>
EOT
}
