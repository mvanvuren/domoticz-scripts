#!/usr/bin/perl
# Prerequisites:
#  - Hombot 3.0 Hacking: https://www.roboter-forum.com/index.php?thread/10009-lg-hombot-3-0-wlan-kamera-steuerung-per-weboberfl%C3%A4che/&postID=107354#post107354
#  - The Hombot is behind a switch that is operated by domoticz (STOFFIE_SWITCH_IDX).
#  - Status is recorded within a virtual text field within domoticz (STOFFIE_STATUS_IDX)
#
# This program is started by cron every 5 minutes.
# It starts by checking if current time falls between scheduled start and end hours.
# If not, the program exits.
# The next cycle, the previous state (switch and status) and last action time recorded
# is retrieved from domoticz.
# If domoticz switch is off, a check is performed if Hombot already performed
# a cleaning cycle today. If so, the program exits.
# Otherwise the switch is turned on and status is set to AWAKE. After which the program exits.
# In the mean time the Hombot will start charging it's battery.
# The next cycle the program tries to determine if it should start cleaning or
# if it should switch off the Hombot as it already performed a full cleaning cycle.
# If battery percentage is 100 and there has not been a cleaning cycle that day,
# a start command will be issued to the Hombot.
# If battery percentage is 100 and a cleaning cycle was started that day,
# the Hombot switch will be turned off (after a couple of minutes the Hombot will fall asleep).
use strict;
use warnings;
use POSIX qw/strftime/;
use LWP::Simple qw($ua get);
use JSON qw( decode_json );
use Date::Parse;
use Net::Ping;
use File::Basename;

my $DOMO_URL = $ENV{DOMO_URL};
my $LOG_PATH = $ENV{LOG_PATH};
my $LOG_FILE = "$LOG_PATH/stoffie/stoffie.log";
my $STOFFIE_URL = $ENV{STOFFIE_URL};
my $STOFFIE_IP = $ENV{STOFFIE_IP};
my $TELEGRAM_SCRIPT = $ENV{TELEGRAM_SCRIPT};
my $STOFFIE_SWITCH_IDX = 373;
my $STOFFIE_STATUS_IDX = 198;
my $SECONDS_PER_DAY = 86400;
my $SECONDS_PER_MINUTE = 60;
my $MAX_WORKING_TIME_IN_MINUTES = 60;
my %SCHEDULED_DAYS = ( 1 => 'Mon', 2 => 'Tue', 3 => 'Wed', 4 => 'Thu' );
my $SCHEDULED_START_HOUR = 12;
my $SCHEDULED_END_HOUR = 17;
my $ACTIVATE_TURBO_MODE = 0;

exit_if_not_scheduled();

my ($domo_switch_status, $domo_status, $domo_lasttime) = get_info_domoticz();
if ($domo_switch_status eq 'Off') {
	exit_if_run_today($domo_lasttime);
	wakeup_stoffie();
    exit;
}
exit_if_not_ready(); # lost control

my ($stoffie_status, $stoffie_battery) = get_info_stoffie();
my @states = add_status($stoffie_status);
my %status = map { $_ => 1 } @states;
my $ready_to_clean = ($stoffie_battery == 100);
my $is_working = $states[-1] eq 'WORKING';
my $has_started_working = $is_working || exists($status{'WORKING'});
my $working_time_in_minutes = int((time - $domo_lasttime) / $SECONDS_PER_MINUTE);
my $max_working_time_reached = $is_working && ($working_time_in_minutes > $MAX_WORKING_TIME_IN_MINUTES || $stoffie_battery == 20);
my $finished_cleaning = $ready_to_clean && $has_started_working; # status: 

exit_if_max_working_time_reached() if ($max_working_time_reached);
finish_cleaning() if ($finished_cleaning);
start_cleaning() if ($ready_to_clean);

##########################################################################################################
sub get_switch_status_domoticz {
	my $json = get_json("$DOMO_URL/json.htm?type=devices&rid=$STOFFIE_SWITCH_IDX");
	my $result = $json->{'result'}[0];
	my $domo_switch_status = $result->{'Status'};
	my $domo_switch_status_lasttime = str2time($result->{'LastUpdate'});
	#$domo_lasttime = $domo_lasttime - ($domo_lasttime % $SECONDS_PER_DAY); # update to start of day 00:00:00

	return ($domo_switch_status, $domo_switch_status_lasttime);
}

sub get_status_domoticz {
	my $json = get_json("$DOMO_URL/json.htm?type=devices&rid=$STOFFIE_STATUS_IDX");
	my $result = $json->{'result'}[0];
	my $domo_status = $result->{'Data'};
	my $domo_status_lasttime = str2time($result->{'LastUpdate'});

	return ($domo_status, $domo_status_lasttime);
}

sub get_info_domoticz {
	my ($domo_switch_status, $domo_switch_status_lasttime) = get_switch_status_domoticz();
	my ($domo_status, $domo_status_lasttime) = get_status_domoticz();
	my $domo_lasttime = $domo_switch_status_lasttime >= $domo_status_lasttime ? $domo_switch_status_lasttime : $domo_status_lasttime;

	return ($domo_switch_status, $domo_status, $domo_lasttime);
}

sub get_info_stoffie {
	my %stoffie_status = map { split(/=/, $_) } split(/\n/, get_status_stoffie());
	# TODO: simplify
	exit if (!exists($stoffie_status{'JSON_ROBOT_STATE'}) || !exists($stoffie_status{'JSON_BATTPERC'}));
	exit if ($stoffie_status{'JSON_ROBOT_STATE'} eq '' || $stoffie_status{'JSON_BATTPERC'} eq '');
	
	my $stoffie_status = $stoffie_status{'JSON_ROBOT_STATE'};
	my $stoffie_battery = int($stoffie_status{'JSON_BATTPERC'});

	return ($stoffie_status, $stoffie_battery);
}

sub exit_if_not_scheduled {
    my $wday = (localtime())[6];
	my $chour = (localtime())[2];
	exit if (!exists($SCHEDULED_DAYS{$wday}) || $chour < $SCHEDULED_START_HOUR || $chour >= $SCHEDULED_END_HOUR);
}

sub exit_if_run_today {
	my $dtime = shift;
	$dtime = $dtime - ($dtime % $SECONDS_PER_DAY); # start of day 00:00:00
	my $ctime = time();
	my $dayssince = int(($ctime - $dtime) / $SECONDS_PER_DAY);
	exit if ($dayssince == 0);
}

sub wakeup_stoffie {
	get "$DOMO_URL/json.htm?type=command&param=switchlight&idx=$STOFFIE_SWITCH_IDX&switchcmd=On";
	send_message('Stoffie wakker maken...');
	set_status('AWAKE');
}

sub shutdown_stoffie {
	get "$DOMO_URL/json.htm?type=command&param=switchlight&idx=$STOFFIE_SWITCH_IDX&switchcmd=Off";
	send_message('Stoffie gaat slapen...');
	add_status('SHUTDOWN');
	exit;
}

sub exit_if_not_ready {
	my $p = Net::Ping->new('icmp');
	my $ping = $p->ping($STOFFIE_IP);
	$p->close();
	if (!$ping) {
		shutdown_stoffie(); # Stoffie doesn't respond
	}
}

sub exit_if_max_working_time_reached {
	homing();
	exit;
}

sub start_cleaning {
	get "$STOFFIE_URL/json.cgi?%7b%22COMMAND%22:%22CLEAN_START%22%7d";
	send_message('Stoffie is begonnen met stofzuigen.');
	add_status('WORKING');

	if ($ACTIVATE_TURBO_MODE) {
		sleep 10;
		#get "$STOFFIE_URL/json.cgi?%7b%22COMMAND%22:%7b%22TURBO%22%3a%22true%22%7d%7d"; # turbo mode (=noisy mode)
		#send_message("Turbo mode geactiveerd.");
	}
}

sub homing {
	get "$STOFFIE_URL/json.cgi?%7b%22COMMAND%22:%22HOMING%22%7d";
	send_message('Stoffie keert terug naar het basisstation.');
	add_status('HOMING');
}

sub finish_cleaning {
	get "$DOMO_URL/json.htm?type=command&param=switchlight&idx=$STOFFIE_SWITCH_IDX&switchcmd=Off";
	send_message('Stoffie is klaar en gaat slapen. !!! Graag reservoir legen !!!');
	add_status('DONE');
	exit;
}

sub add_status {
	my $status = shift;
	my @states = split(/>/, $domo_status);

	if ($states[-1] ne $status) {
		push(@states, $status);
		$domo_status = join('>', @states);
		set_status($domo_status);
	}
	return @states;
}

sub set_status {
	my $status = shift;
	get "$DOMO_URL/json.htm?type=command&param=udevice&idx=$STOFFIE_STATUS_IDX&nvalue=0&svalue=$status";
	send_message("Status Stoffie: $status");
}

sub get_json {
	my $url = shift;

	my $json = get $url;
	die "Could not get $url!" unless $json;

	return decode_json($json);
}

sub get_status_stoffie {
	my $url = "$STOFFIE_URL/status.txt";
	my $stoffie_status = get $url;
	die "Could not get $url!" unless defined $stoffie_status;	

	$stoffie_status =~ s/"//g;
	
	return $stoffie_status;
}

sub send_message {
	
	return if ($^O ne 'linux');

	my $message = strftime("%Y-%m-%d %H:%M:%S", localtime) . ' ' . shift;

	log_message($message);

	system("$TELEGRAM_SCRIPT \"" . $message . "\""); # TODO: replace by Domoticz notify	
}

sub log_message {
	my $message = shift . "\n";

	open my $file, '>>', $LOG_FILE or die $!;
	print $file $message;
}

1;
