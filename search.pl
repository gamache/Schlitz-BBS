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



my $q = $cgi->param('q');
my $sort = $cgi->param('sort');
my $adv = $cgi->param('adv');
my $startat = $cgi->param('startat') + 0;


if ($q eq '') {
	print_search_form ();
	exit 0;
}

my $advstr = '';
if ($adv eq 'yes') { $advstr = 'in boolean mode' }

if ($sort eq 'new') {
$cmd = <<EOT
select sql_calc_found_rows
  subject,author,date,tid,pid,seq, 
    match (subject,body) against ('$q' $advstr) as score
  from posts where match (subject,body) against ('$q' $advstr) 
  order by date desc 
  limit $startat,$spp
EOT
}

elsif ($sort eq 'old') {
$cmd = <<EOT
select sql_calc_found_rows
  subject,author,date,tid,pid,seq, 
    match (subject,body) against ('$q' $advstr) as score 
  from posts where match (subject,body) against ('$q' $advstr) 
  order by date 
  limit $startat,$spp
EOT
}

else {	# sort by relevance -- default
$cmd = <<EOT
select sql_calc_found_rows
  subject,author,date,tid,pid,seq, 
    match (subject,body) against ('$q' $advstr) as score
  from posts where match (subject,body) against ('$q' $advstr)  
  order by match (subject,body) against ('$q' $advstr) desc
  limit $startat,$spp
EOT
}


if (! ($sth = $dbh->prepare($cmd))) {
	print_bad_query_page ();
	exit 0;
}

$sth->execute;


print <<EOT
<html>
<head>
 <title>SCUL Forum Search Results</title>
</head>
<body bgcolor="black" text="silver" link="blue" alink="red" vlink="#333390">
<font color="#909090" face="Courier" size="4">
<center><h3>Search Results</h3>
<font size="-1">(<a href="$urlroot/">return to forums</a>)</font>
<br>&nbsp;


<table border=0 width="90%">
<tr><td colspan=4>
EOT
;	print_search_box ($q);

	print "</td></tr>\n";

	my $pagestr = <<EOT
<tr><td colspan=4><br></td></tr>
<tr>
 <td width="10%"><b>Score</b></td>
 <td width="40%"><b>Subject</b></td>
 <td width="20%"><b>Author</b></td>
 <td width="30%"><b>Date</b></td>
</tr>
<tr><td colspan=3>&nbsp;</td></tr>
EOT
;

while (my ($subject, $author, $date, $tid, $pid, $seq, $score) = $sth->fetchrow_array) {
	
	my $startat = (int ($seq/$ppp)) * $ppp;
	my $link = qq|<a href="$urlroot/t/$tid,$startat#$pid">|;
	my $scorestr = sprintf "%.3f", $score;

	$pagestr .= <<EOT
<tr>
 <td>$scorestr</td>
 <td>${link}$subject</a></td>
 <td>$author</a></td>
 <td>$date</a></td>
</tr>
EOT
}


$sth->finish;

$sth = $dbh->prepare('select found_rows()');
$sth->execute;
my @r=$sth->fetchrow_array;
$sth->finish;

my $nmatches = $r[0];
$pagestr .= "</table>\n<br>\n";

my $pageindex = "Search results: page ";

my $maxpage = (int ($nmatches/$spp)) + 1;
for (my $npage = 1; $npage <= $maxpage; $npage++) {
	my $start = ($npage-1) * $spp;

	if ($startat == $start) { $pageindex .= "$npage " }
	else { 
		my $nextstartat = $npage * $spp;
		$pageindex .= qq|<a href="$urlroot/search.pl?q=$q&sort=$sort&startat=$start">$npage</a> |;
	}
}

$pageindex .= "(Displaying " . ($startat+1) . "-" .
		(($nmatches>$startat+$spp+1) ? $startat+$spp+1 : $nmatches ) . 
		" of $nmatches)\n";




print <<EOT
<tr><td colspan=4 align=center>$pageindex</td></tr>
$pagestr
$pageindex
</body>
</html>
EOT
;




sub print_search_form { print <<EOT
<html>
<head>
 <title>SCUL Forum Search</title>
</head>
<body bgcolor="black" text="silver" link="blue" alink="red" vlink="#333390">
<font color="#909090" face="Courier" size="4">
<center><h3>Search SCUL Forum</h3>
<font size="-1">(<a href="$urlroot/">return to forums</a>)</font>

<br><br>&nbsp;<br>
<table width="70%" border=0>
<tr><td align=left>
EOT
;	print_search_box('');
	print <<EOT
<br><br><br>
<p>Advanced Search syntax:
<p>Use <b>"double quotes"</b> to search for a phrase.
<br>Use <b>word*</b> to perform wildcard searches.
<br>Use <b>(left and right parentheses)</b> to group search tokens.
<br>Use <b>+word</b>, <b>+"phrase words"</b> or <b>+(group words)</b>
 to require a word or phrase.
<br>Use <b>-word</b>, etc. to prohibit a word or phrase.
<br>Use <b>~word</b>, etc. to discourage a word or phrase.
<br>Use <b>&gt;word</b>, etc. to increase a word's search score.
<br>Use <b>&lt;word</b>, etc. to decrease a word's search score.

</td></tr></table>
</body>
</html>
EOT
}

sub print_bad_query_page { print <<EOT
<html>
<head>
<link rel="shortcut icon" href="../../favicon.gif">
<title>SCUL Forum</title>
</head>
<body bgcolor="black" text="silver" link="blue" alink="red" vlink="#333390">
<font color="#909090" face="Courier" size="4"><h2>Your query sucks</h2>
Try again, and take the dick out of your mouth this time.<br>
<font><br><hr size="1" noshadow>
<a href="$urlroot/search.pl">Search SCUL Forum</a>
</body>
</html>
EOT
}

sub print_search_box { 
	my $q = shift;
		
	print <<EOT
<form action="$urlroot/search.pl" method="get">
Query: <input type="text" name="q" value='$q' size=60>
<br>
<p>Sort by: 
<input type="radio" name="sort" value="rel" checked>Relevance &nbsp;
<input type="radio" name="sort" value="new">Newest First &nbsp;
<input type="radio" name="sort" value="old">Oldest First &nbsp;&nbsp;
<input type=checkbox name=adv value=yes>Advanced Search
<br>
<p><input type="submit" value="Search"></form>
EOT
}