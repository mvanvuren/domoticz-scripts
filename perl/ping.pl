#!/usr/bin/perl
use DBI;
use Net::Ping;
use LWP::Simple;
use JSON qw( decode_json );
use Data::Dumper;
use strict;
use warnings;

my $DOMO_URL = $ENV{DOMO_URL};
my $ROUTER_IP = $ENV{ROUTER_IP};

# preventive reboot of bridge
my ($second, $minute, $hour, $dayOfMonth, $month, $yearOffset, $dayOfWeek, $dayOfYear, $daylightSavings) = localtime();

# network available?
my $p = Net::Ping->new();
if (!$p->ping($ROUTER_IP)) { # gateway can't be reached
	print("router can't be reached");
	exit;
}
$p->close();

my $dbh = DBI->connect('dbi:SQLite:dbname=/root/domoticz/scripts/perl/ping.s3db', '', '', { RaiseError => 1 }) or die $DBI::errstr;
my $dbpresent = $dbh->prepare( "UPDATE Device SET LastTime = ?, Present = ? WHERE Idx = ?" );  
my $dbselect = $dbh->prepare( "SELECT * FROM Device" );  
my $row;
$dbselect->execute();
while($row = $dbselect->fetchrow_hashref()) {
	if ($row->{IsWindows}) {
		$p = Net::Ping->new('icmp');
	} else {
		$p = Net::Ping->new('tcp', 2);
	}
	my $present = $p->ping($row->{IpAddress});
	$p->close();

	print "$row->{Name} ($row->{IpAddress}):  $present\n";

	my $idx = $row->{Idx};
	if ($present) {
		if (!$row->{Present}) {
			get "$DOMO_URL/json.htm?type=command&param=switchlight&idx=$idx&switchcmd=On";			
		}
		$dbpresent->execute(time(), 1, $idx); # record last time seen
	} else { # not present
		if ($row->{Present} && (time() - $row->{CooldownSeconds} > $row->{LastTime})) {
			$dbpresent->execute($row->{LastTime}, 0, $idx);
			get "$DOMO_URL/json.htm?type=command&param=switchlight&idx=$idx&switchcmd=Off";			
		}
	}
}
$dbselect->finish();
$dbpresent->finish();
$dbh->disconnect();

sub get_json {
	my $url = shift;

	my $json = get $url;
	die "Could not get $url!" unless $json;

	return decode_json($json);
}

1;
