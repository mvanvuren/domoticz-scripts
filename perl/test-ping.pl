#!/usr/bin/perl
use strict;
use warnings;
use Net::Ping;

my $STOFFIE_IP = $ENV{STOFFIE_IP};

my $p = Net::Ping->new('icmp');
my $ping = $p->ping($STOFFIE_IP);
$p->close();
if (!$ping) {
    print("Stoffie doesn't respond\n");
} else {
    print("Stoffie is alive!\n");
}