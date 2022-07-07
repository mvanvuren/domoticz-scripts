#!/usr/bin/perl
use strict;
use warnings;
use LWP::Simple qw($ua get);
use URI::Escape;
use JSON qw( decode_json );
use POSIX qw(strftime);

my $DOMO_URL = $ENV{DOMO_URL};
my $LAT = $ENV{GEO_LAT};
my $LON = $ENV{GEO_LON};
my $IDX = 320;

my $json = get_json("http://api.open-notify.org/iss-pass.json?lat=$LAT&lon=$LON&alt=11&n=1");
my $duration = $json->{response}[0]->{duration};
my $risetime = $json->{response}[0]->{risetime};
my $srisetime = strftime('%d-%m-%Y %H:%M:%S', localtime $risetime);
my $text = "$srisetime D${duration}s\n";

get_json("$DOMO_URL/json.htm?type=command&param=udevice&idx=$IDX&nvalue=0&svalue=" . uri_escape( $text ) );

sub get_json {
	my $url = shift;

	my $json = get $url; 
	die "Could not get $url!" unless defined $json;

	return decode_json($json);
}

1;
