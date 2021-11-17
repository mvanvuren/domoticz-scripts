#!/usr/bin/perl
use Net::Ping;

my $STOFFIE_IP = $ENV{STOFFIE_IP};

my $p = Net::Ping->new('icmp');
my $ping = $p->ping($STOFFIE_IP, 2);
$p->close();
if (!$ping) {
    print("Stoffie doesn't respond\n");
} else {
    print("Stoffie is alive!\n");
}