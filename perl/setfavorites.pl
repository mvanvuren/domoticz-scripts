#!/usr/bin/perl
use strict;
use warnings;
use LWP::Simple qw($ua get);
use JSON qw( decode_json );
use constant { true => 1, false => 0 };

my $DOMO_URL = $ENV{DOMO_URL};

my $url = "$DOMO_URL/json.htm?type=devices&filter=light&used=true"; # get devices
my $json = get $url; 
die "Could not get $url!" unless defined $json;
my $decoded_json = decode_json($json);

my @devices = @{$decoded_json->{'result'}};
if (scalar(@devices) > 0) {

	foreach my $device (@devices) {
		next if ($device->{'Name'} =~ /^SA/ || $device->{'Name'} =~ /^PIRL/); # TODO: drop SA devices as mechanism does not seem to work
		my $switchtype = $device->{'SwitchType'};
		next if ($switchtype eq 'Doorbell');

		my $status = $switchtype eq 'Contact' ? ($device->{'Data'} eq 'Open' ? 'On' : 'Off') : $device->{'Data'};
		my $favorite = $device->{'Favorite'};
		
		my $isfavorite;
		if ($status eq 'On') {
			$isfavorite = 1 if ($favorite == 0);
		} else {
			$isfavorite = 0 if ($favorite == 1);
		}

		if (defined $isfavorite) {
			print "$device->{'Name'} ($switchtype): $status ==> $isfavorite\n";
			my $idx = $device->{'idx'};
			get "$DOMO_URL/json.htm?type=command&param=makefavorite&idx=$idx&isfavorite=$isfavorite";
		}
	}
}

1;
