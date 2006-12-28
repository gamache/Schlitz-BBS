#!/usr/bin/perl

#use warnings;
use strict;

use CGI::Minimal;
use CGI::Cookie;
use DBI;




my ($urlroot, $dsn, $user, $pass, $tpp, $ppp, $spp);

### read config file

if (open CONF, './conf.pl') {
	while (<CONF>) { eval }
	close CONF;
}


my $cgi = CGI::Minimal->new;
my $dbh = DBI->connect ($dsn, $user, $pass);

my $html = "Content-type:text/html\n\n";



my $theme = $cgi->param('theme');
$theme='default' if (! defined $theme);


### handle cookies

my $sth = $dbh->prepare ('select now()');
$sth->execute;
my @a = $sth->fetchrow_array;
my $nowdate = $a[0];
$sth->finish;

my %cookies = CGI::Cookie->fetch;

foreach my $key (keys %cookies) {
	warn "$key, $cookies{$key}";
	warn $cookies{$key}->name();
	warn $cookies{$key}->value();
}

my $lastview;
if ($lastview = $cookies{'lastview'}) {
	$lastview = $cookies{'lastview'}->value();
}


my $newck = new CGI::Cookie (
	-name		=>	'lastview',
	-value		=>	"$nowdate",
	-expires	=>	'+3M'
);

print "Set-Cookie: $newck\n";




### now render and print the html

my $startat = $cgi->param('startat') + 0;

$html .= index_header();



my $cmd = <<EOT
select sql_calc_found_rows 
 tid, title, nposts, author, lastpost, lastauthor, posts
 from threads order by lastpost desc limit $startat,30
EOT
;

$sth = $dbh->prepare ($cmd) or die 
	"Couldn't prepare statement: $dbh->errstr";

$sth->execute or die
	"Couldn't execute statement: $cmd";

while (my ($tid, $title, $nposts, $author, $lastpost, $lastauthor, $posts) =
		$sth->fetchrow_array) {
		
	my $nreplies = $nposts - 1;
	
	my $startat = (int (($nreplies-1)/$ppp)) * $ppp;
	$posts =~ /(\d+)$/;
	my $pid = $1;
	
	$title = CGI::Minimal->url_decode($title);
	$author = CGI::Minimal->url_decode($author);
	
	my $new;
	if ($lastpost gt $lastview) { $new=1 }

	$html .= index_thread ($tid, $title, $nreplies, $author, $lastpost, $lastauthor, $pid, $new, $startat);
}

$sth->finish;

$sth = $dbh->prepare ('select found_rows()');
$sth->execute;
my @r=$sth->fetchrow_array;
my $nthreads = $r[0];
$sth->finish;


$html .= index_pages($nthreads);

$html .= index_footer();

$dbh->disconnect;


print $html;






sub index_header { return <<EOT
<html>
<head>
<link rel="shortcut icon" href="../../favicon.gif">
<title>Schlitz BBS!</title>
</head>
<body bgcolor="black" text="silver" link="blue" alink="red" vlink="#333390">
<TABLE bgcolor="#303030" border="0" cellpadding="0" cellspacing="1">
      <TR>
        <TD width="100%">
        
        
          <TABLE width="100%" bgcolor="#000000" cellpadding="0" cellspacing="0" border="0">
            <TR>
              <TD align="left">

<div align=center>
<font color="#909090" face="Courier" size="4"> * * * SCUL BBS * * *</font>
<br>
</div>
<table width="100%" border=0 cellpadding=0 cellspacing=0>
<tr><td width="50%" align="left">
<font color="#909090" face="Courier" size="3">
<a href="http://scul.org/">scul.org</a> | 
<a href="http://scul.org/forums/index.html">members only</a> |
<a href="http://70.96.188.36/%7esculorg/HAL/index.php?title=Main_Page">HAL</a>
</font>
</td>
<td width="50%" align="right">
<font color="#909090" face="Courier" size="3">
<a href="s/">search the BBS</a> | 
<a href="u/">upload a file</a>
</font>
</td>
</tr>
</table>
<br>
<br>
</div>

       </TD>
			  <td align="right" valign="bottom">&nbsp;</td>
			</tr>
		  </table>

<table border="0" width="774" cellspacing="0" cellpadding="0" bgcolor="#202020"><tr><td>

<table border="0" width="774" cellspacing="1" cellpadding="1">

<tr bgcolor="#000000" valign="top"><td><font color="#909090" face="Courier" size="4">&nbsp;</font></td>
<td><font color="#909090" face="Courier" size="4">Subject&nbsp;</font></td>

<td width="5"><font color="#909090" face="Courier" size="4">Replies&nbsp;</font></td>

<td width="120"><font color="#909090" face="Courier" size="4">Created By&nbsp;</font></td>

<td width="120"><font color="#909090" face="Courier" size="4">Last Post&nbsp;</font></td></tr>
EOT
};

sub index_thread {
	my ($tid, $title, $nreplies, $author, $lastpost, $lastauthor, $pid, $new, $startat) = @_;
	
	my $dotstr = '&nbsp;';
	if ($new) { $dotstr = qq|<img src="$urlroot/images/new.gif">| }
	
	return <<EOT
<tr valign="top" bgcolor="#050505"><td width="1%">$dotstr</td><td>
<img src="$urlroot/images/document.gif" border="0"> <font face="Courier" size="4"><a href="$urlroot/t/$tid,$startat">
$title
</a></font></td>
<td><font color="#909090" face="Courier" size="4">$nreplies
</font></td>
<td><font color="#909090" face="Courier" size="4">$author 
</font></td>
<td><font color="#909090" face="Courier" size="4">
$lastpost<br>
<a href="$urlroot/t/$tid,$startat#$pid">$lastauthor</a>
</font></td></tr>
EOT
}


sub index_pages {
	my $nthreads = shift;
	
	my $html = <<EOT
</table></td></tr></table></td></tr></table>
<table border="0"><tr><td><font color="#909090" face="Courier" size="4"><p>powered by Schlitz BBS v1.0 by <a href="mailto:vms.snarly\@gmail.com">snarly</a></font></td></tr></table>
<table border="0" width="774" cellspacing="0" cellpadding="0">
<tr><td><font color="#909090" face="Courier" size="4"><p>Pages: 
EOT
;
	my $lastpage = int ($nthreads / $tpp) + 1;
	for (my $npage = 1; $npage <= $lastpage; $npage++) {
		my $pgstartat = ($npage-1) * $tpp;
		if ($pgstartat == $startat) {
			$html .= qq|<b>$npage</b> |;
		} else {
			$html .= qq|<a href="index.pl?startat=$pgstartat">$npage</a> |;
		}
	}
	
	$html .= "</td></tr></table>\n";
	return $html;
}


sub index_footer { return <<EOT
</font><br><br><br>

<table border="0">

<tr><td>
<table border="0" width="100%">
  <tr bgcolor="#000000"><td>
    <font color="#0010FF" face="Courier" size="2">
      <b>Post a new message:</b>
    </font>
  </td></tr>
</table>

</td></tr>
<br>
<tr>
<td>
<table border="0" cellspacing="0">
<form action="$urlroot/post.pl" method="post">
  <tr>
    <td>
	  <font color="#909090" face="Courier" size="4">
	    Name:
	  </font>
	</td>
	<td>
	  <input type="text" name="author" maxlength="20" value="">
	</td>
  </tr>
  <tr>
    <td>
	  <font color="#909090" face="Courier" size="4">
	    Email:
	  </font>
	</td>
	<td>
	  <input type="text" name="email" maxlength="50" value="">
	</td>
  </tr>

  <tr>
    <td>
	</td>
	<td>
	  <br>
	</td>
  </tr>

  <tr>
    <td>
	</td>
	<td>
	  <br>
	</td>
  </tr>

  <tr>
    <td>
	  <font color="#909090" face="Courier" size="4">
	    Subject:
	  </font>
	</td>
	<td>
	  <input type="text" name="subject" maxlength="50" size="50">
	</td>
  </tr>
  <tr>
    <td valign="top">
	  <font color="#909090" face="Courier" size="4">
	    Message:
	  </font>
	</td>
	<td valign="top">
	  <textarea name="body" cols="100" rows="10" wrap="soft"></textarea>
      <input type="hidden" name="action" value="preview">
	  <input type="hidden" name="board" value="board1">
	</td>
  </tr>
  <tr>
    <td>
	</td>
	<td>
	  <font face="Courier">
	    <input type="submit" value="Preview - Post">
	  </font>
	</td>
  </tr>
  <input type="hidden" name="tid" value="new">
</form>

</table>
</td>
</tr>
</table>
<br><hr size="1" noshadow>
<font color="#909090" face="Courier" size="2">
<a href="s/">search the BBS</a> | 
<a href="u/">upload a file</a>
</font>
</body>
</html>

EOT
}
