#!/usr/bin/perl
use strict;
use warnings;
use POSIX qw/strftime/;
use LWP::Simple qw($ua get);
use JSON qw( decode_json );

my $DISKSTATION_URL = $ENV{DISKSTATION_URL};
my $DOMO_URL = $ENV{DOMO_URL};
my $DISKSTATION_USR = $ENV{DISKSTATION_USR};
my $DISKSTATION_PWD = $ENV{DISKSTATION_PWD};

my $authUrl = "$DISKSTATION_URL/webapi/entry.cgi?api=SYNO.API.Auth&method=login&version=6&account=$DISKSTATION_USR&passwd=$DISKSTATION_PWD&session=SurveillanceStation&format=sid";
my $json = get_json($authUrl);

my $synoToken = $json->{'data'}->{'sid'};

get_json("$DOMO_URL/json.htm?type=command&param=updateuservariable&vname=SynoToken&vtype=2&vvalue=$synoToken");

sub get_json {
	my $url = shift;

	my $json = get $url; 
	die "Could not get $url!" unless defined $json;

	return decode_json($json);
}
