#!/usr/bin/perl

#use warnings;
use strict;

use CGI::Minimal;
use DBI;

my ($urlroot, $dsn, $user, $pass, $tpp, $ppp, $spp);

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


my $tid = $cgi->param('tid');
my $startat = $cgi->param('startat') + 0;


$cmd = qq|select title, posts, nposts from threads where tid=$tid|;

$sth = $dbh->prepare ($cmd) or die 
	"Couldn't prepare statement: $dbh->errstr";

$sth->execute or die
	"Couldn't execute statement: $cmd";


my ($title, $poststr, $nposts) = $sth->fetchrow_array;

$sth->finish;

my $safetitle = CGI::Minimal->url_decode ($title);




my $endat;


if ($startat > 0) { $startat++ }

if ($startat + 10 > $nposts) {
	$endat = $nposts;
} else {
	$endat = $startat + 10;
	if ($startat == 0) { $endat++ }

}

my @posts = split ',', $poststr;


print_header ();

for (my $i=$startat; $i<$endat; $i++) {
	print_post ($posts[$i], $i);
}

print_footer ();










sub print_header {
	print <<EOT
<html>
  <head>
<title>$safetitle</title>
<META HTTP-EQUIV="Cache-Control" CONTENT="no-cache">.
<link rel="stylesheet" href="/css/main.css" type="text/css" />
<link rel="icon" href="../../favicon.gif" type="image/x-icon" />
</head>
 <body bgcolor="black" text="silver" link="blue" alink="red" vlink="#333390">
<table bgcolor="#ffffff" border="0" cellpadding="0" cellspacing="1" width="775">
      <tr width="100%">
        <td>
          <table width="100%" bgcolor="#060606" cellpadding="0" cellspacing="0" border="0">

            <tr>
              <td align="left">
			    <font face="Courier" size="3" color="#0000FF">
                <a href="$urlroot/index.pl"><b>[ return to forums ]</b></a></font>
              </td></tr><tr width="100%"><td><table bgcolor="#909090" border="0" cellpadding="0" cellspacing="0" width="100%"><tr><td><table border="0" width="100%" cellspacing="1" cellpadding="0"><tr bgcolor="#080808"><td width="15%"><font color="#0000FF" face="Courier" size="4">From</font></td><td><font color="#0000FF" face="Courier" size="4">Message</font></td></tr>
EOT
}

sub print_post {
	my $pid = shift;
	my $npost = shift;
	
	$cmd = <<EOT
select date, author, email, subject, body from posts
  where pid="$pid"
EOT
;

	$sth = $dbh->prepare ($cmd) or die 
		"Couldn't prepare statement: $dbh->errstr";

	$sth->execute or die
		"Couldn't execute statement: $cmd";

	my ($pd, $pa, $pe, $ps, $pb) = $sth->fetchrow_array;
	
	$pa = CGI::Minimal->url_decode ($pa);
	$ps = CGI::Minimal->url_decode ($ps);
	$pb = CGI::Minimal->url_decode ($pb);
	
	$sth->finish;
	
	my $emailhtml = '';
	if ($pe ne '') {
		$emailhtml = <<EOT
&nbsp;<a href="mailto:$pe"><img src="$urlroot/images/email.gif" border="0" alt="Email"></a>
EOT
	}
	
	my $color;
	if ($npost%2 < 1) { $color = "#101010"}
	else { $color = "#050505" }
	
	print <<EOT
<tr><td bgcolor="$color" valign="top"><font color="#909090" face="Courier" size="4">
<a name="$pid">$pa</a>
<br>Pilot<br>$emailhtml<br><br>$pd<br></font></td><td valign="top" bgcolor="$color"><img src="$urlroot/images/document.gif" border="0"> <font color="#909090" face="Courier" size="4"><u>$ps</u><br><font size="-1">IP: Logged</font><br><br>
begin transmission:<br><br>
$pb
<br><br>:end transmission<br></font></td></tr>
EOT
}

sub print_footer {

	my $thispage = int ($startat/10) + 1;

	print <<EOT
</td></tr></table></td></tr></table></td></tr>
<tr><td valign="top" align="right"><font color="#0000FF" face="Courier" size="4">
EOT
;
	if ($startat != 0) { print qq|<a href="$urlroot/t/$tid">&lt;&lt;</a>Original Post |
	}
	
	if ($startat > 10) { 
		my $prev = $startat - 10;
		$prev=0 if $prev==1;
		print qq|<a href="$urlroot/t/$tid,$prev">&lt;&lt;</a>Previous Page |;
	}
	
	print <<EOT
<font color="#0000FF" face="Courier" size="4"> P $thispage </b></font>
EOT
;
	
	if ($nposts > $endat) {
		my $next = $endat+1;
		print qq|Next Page <a href="$urlroot/t/$tid,$next">&gt;&gt;</a> |;
	}
	
	print <<EOT
</td></tr></table></td></tr></table>
<br>
<br>
<table border="0" cellspacing="0">
  <tr bgcolor="#060606">
    <td>
      <font color="#0000FF" face="Courier" size="2">
        <b>Post a reply to this transmission:</b>
	  </font>
	</td>
	<td>

	</td>
  </tr>
  <tr>
    <td><table border="0">

<form action="$urlroot/post.pl" name="REPLYFORM" method="post">

<tr><td><font color="#909090" face="Courier" size="4">Name:</font></td><td><input type="text" name="author" maxlength="20"></td></tr>

<tr><td><font color="#909090" face="Courier" size="4">Email:</font></td><td><input type="text" name="email" maxlength="50"></td></tr>
<tr><td></td><td>
<br><br></td></tr>

<tr><td><font color="#909090" face="Courier" size="4">Subject:</font></td><td><input type="text" name="subject" value="RE:$safetitle" size="30" maxlength="50"></td></tr>

<tr><td valign="top"><font color="#909090" face="Courier" size="4">begin transmission:</font></td><td><textarea name="body" cols="80" rows="10" wrap="soft"></textarea></td></tr>

<input type="hidden" name="tid" value="$tid">


<tr><td></td><td><font face="Courier"><input type="submit" value="Preview / Post"></font></form></td></tr></table></td></tr></table>
<a href="search.pl">Search SCUL Forum</a>
 
 </body>
</html>
EOT
}