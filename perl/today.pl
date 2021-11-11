#!/usr/bin/perl

# TODO: vervangen door Python
use strict;
use warnings;
use LWP::Simple qw($ua get);
use JSON qw( decode_json );
use DateTime;
use DateTime::Format::Strptime;

my $DOMO_URL = $ENV{DOMO_URL};

my %idx = (
	193	=> 'MvV', # Tado - Martijn
	209	=> 'LD', # Tado - Leonie
	11	=> 'VoorD',
	76	=> 'Hal',
	73	=> 'WoonK',
	24	=> 'OverL',
	46	=> 'SchuifW',
	201	=> 'SchuifO',
	88	=> 'SlaapK',
	# 232	=> 'MobielM',
	# 233	=> 'MobielL',
	419	=> 'MobielM',
	420	=> 'MobielL',
	230	=> 'CamT',
	231	=> 'CamV',
	176	=> 'VoorDP',
	23	=> 'DeurB',
);

my $parser = DateTime::Format::Strptime->new( pattern => '%Y-%m-%d %H:%M:%S' );
my $today = DateTime->today();
my $message = '';
my $json = get_json("$DOMO_URL/json.htm?type=devices&filter=light&used=true");
my @alldevices = @{ $json->{'result'} };
for my $device (@alldevices) {
	my $idx = $device->{'idx'};
	next if (!exists($idx{$idx}));

	my $last = $parser->parse_datetime($device->{'LastUpdate'});

	if ($last >= $today) {
		print $last->strftime("%H:%M ") .  $idx{$idx} . "\n";
	}
}

sub get_json {
	my $url = shift;

	my $json = get $url; 
	die "Could not get $url!" unless defined $json;

	return decode_json($json);
}

1;
