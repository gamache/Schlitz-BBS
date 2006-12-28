#!/usr/bin/perl

use warnings;
use strict;
use DBI;

use CGI::Minimal;
my $cgi = CGI::Minimal->new;

my ($urlroot, $dsn, $user, $pass, $tpp, $ppp, $spp);

### read config file

if (open CONF, './conf.pl') {
	while (<CONF>) { eval }
	close CONF;
}


my $dbh = DBI->connect ($dsn, $user, $pass);
my $sth;
my $cmd;


my $upload;


if ($cgi->param ('file') ne '') {
	my $img = $cgi->param('file');
	$sth = $dbh->prepare (qq|select contenttype, file from files where name="$img"|);
	my $nrows = $sth->execute;
	
	if ($nrows > 0) {
		my $r = $sth->fetchrow_hashref;
		my $data = $$r{'file'};
		my $type = $$r{'contenttype'};
		print "Content-type: $type\n\n", $data;
	} else {
		print "Content-type: image/gif\nStatus: 404 Not found\n\n";
		print system('/bin/cat', '404lol.gif');
	}
}
elsif ($upload = $cgi->param ('upload')) {
	my $size = do { use bytes; length($upload) };
	my $type = $cgi->param_mime('upload');
	my $name = $cgi->param('name');
	

	if ($name eq '') { $name = $cgi->param_filename('upload'); }
	warn "$name";
	
	my $sth = $dbh->prepare (qq|select name from files where name="$name"|);
	$sth->execute;
	my @n = $sth->fetchrow_array;
	
	if (scalar @n > 0) {
		print upload_tpl( <<EOT
<p><font color="red">The name "$name" is already taken.  Please hit your browser's "Back"
button, and choose another name.</font>
EOT
	);
		exit 0;
	}
	
	my $sth = $dbh->prepare (qq|insert into files (name, date, contenttype, file) values
   ("$name", now(), "$type", ?)|);
   
	$sth->execute($upload);
	$sth->finish;

	
	my $bytes = do { use bytes; length($upload) };
	
 	print upload_tpl(upload_success($bytes, $name));
} 
else {
	print upload_tpl(upload_form());
}






sub upload_tpl { 
	my $content = shift;
return<<EOT
Content-type: text/html

<html>
<head>
 <title>SCUL Forum Image Hosting</title>
</head>
<body bgcolor="black" text="silver" link="blue" alink="red" vlink="#333390">
<font color="#909090" face="Courier" size="4">
<center><h3>Upload a File</h3>
<font size="-1">(<a href="$urlroot/">return to forums</a>)</font>

<br><br>&nbsp;<br>
<table width="70%" border=0>
<tr><td align=left>
$content
</td></tr></table></body></html>
EOT
;
}


sub upload_form { return <<EOT
<form action="upload.pl" enctype="multipart/form-data" method="post">
<table width="100%" border=0 cellpadding=0 cellspacing=15>
 <tr>
  <td width="50%">
   <div align="right">
    Select file to upload:
   </div>
  </td>
  <td width="50%" align="left">
   <input type="file" name="upload">
  </td>
 </tr>
 <tr>
  <td>
  <div align="right">
   Optionally, enter a name for your file:
  </div>
  </td>
  <td>
   <input type="text" name="name" size=32>
  </td>
 </tr>
 <tr>
  <td colspan=2>
  <br>
  <div align="center">
   <input type=submit value=Submit>
   <br><br>
   <p>Your file will be accessible at <b>$urlroot/u/<i>NAME</i></b><br><br>
  </div>
  </td>
 </tr>
</table>
</form>
EOT
}

sub upload_success { 
	my $bytes = shift;
	my $name = shift;
	return <<EOT
The file was uploaded successfully, and is now available at 
<a href="$urlroot/u/$name">$urlroot/u/$name</a>.
<br><br>
$bytes bytes received.
EOT
}

