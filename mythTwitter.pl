#!/usr/bin/perl -w


=head1 record.pl

	A script to:
	+ read twitter feeds with recording suggestions
	+ TODO schedule said recording suggestions
	+ TODO tweet current mythtv status
	
	Run as a cron job

	Recording suggestion tweet format:
	* want(s) to watch <program name>
	[ optional details ]
	* on <channel>
	* on <date> (maybe day of week would suffice?)
	* at <time>

=cut

=head2 setup (mythbuntu)

	cp mythTwitter.pl /usr/bin
	sudo chmod a+x /usr/bin/mythTwitter.pl

	# change the twitter username/password constants
	# you need a twitter account for this, of course
	sudo nano /usr/bin/mythTwitter.pl

	# install dependencies
	sudo apt-get install libnet-twitter-perl
	
	# setup log file
	sudo touch /var/log/mythtv/mythTwitter.log
	sudo chgrp mythtv /var/log/mythtv/mythTwitter.log
	sudo chmod g+w /var/log/mythtv/mythTwitter.log

	# test
	sudo mythTwitter.pl

=cut

use strict;


# CONSTANTS

# twitter username and password
use constant CONSUMER_KEY        => '<CONSUMER_KEY>';
use constant CONSUMER_SECRET     => '<CONSUMER_SECRET>';
use constant ACCESS_TOKEN        => '<ACCESS_TOKEN>';
use constant ACCESS_TOKEN_SECRET => '<ACCESS_TOKEN_SECRET>';

# MODULES
use Net::Twitter;
use POSIX qw( strftime );


# connect to twitter
# help? http://github.com/semifor/Net-Twitter/wiki/Net::Twitter-and-the-death-of-Basic-Authentication
my $twitter = Net::Twitter->new(
    traits              => [qw/API::REST OAuth/],
    consumer_key        => CONSUMER_KEY,
    consumer_secret     => CONSUMER_SECRET,
    access_token        => ACCESS_TOKEN,
    access_token_secret => ACCESS_TOKEN_SECRET,
);
# test update
# $twitter->update("Test");

# read followers tweets

# get status
my %args = (
	since	=> `head -n 1 /var/log/mythtv/mythTwitter.log`
);
my $timeline = $twitter->friends_timeline(\%args);
system('echo "' . strftime("%Y-%m-%d", gmtime) . "\n" . '" > /var/log/mythtv/mythTwitter.log');


=pod
mythtv-status outputs:

MythTV status for localhost
===========================
Status...........: Mon 22 Jun 2009, 10:02 pm
Total Disk Space.: Total space is 1,430,548 MB, with 928,780 MB used (64.9%)
Next Recording In: 9 Hours, 57 Minutes

Encoders:
Soundwave (1) - Idle
Soundwave (2) - Idle
Soundwave (3) - Idle
Soundwave (5) - Idle

Scheduled Recordings:
2009-06-23 08:00:00 - Toasted TV (TEN Digital)
2009-06-23 09:00:00 - In The Night Garden (ABC1)
2009-06-23 18:30:00 - Neighbours (TEN Digital)
2009-06-23 19:30:00 - Talkin' Bout Your Generation (TEN Digital)

=cut

# get next recording from status
my $status = `mythtv-status`;
$status =~ s/^.*Scheduled Recordings:.(.*?\)).*$/$1/s;
system('echo "Next recording: ' . $status . "\n" . '" >> /var/log/mythtv/mythTwitter.log');
$twitter->update(sprintf('Next recording: %s', $status));

=pod

API format:

<status> 
  <created_at>Sun Jan 11 02:36:52 +0000 2009</created_at> 
  <id>1110214744</id> 
  <text>Test</text> 
  <source>&lt;a href=&quot;http://search.cpan.org/dist/Net-Twitter/&quot;&gt;Perl Net::Twitter&lt;/a&gt;</source> 
  <truncated>false</truncated> 
  <in_reply_to_status_id></in_reply_to_status_id> 
  <in_reply_to_user_id></in_reply_to_user_id> 
  <favorited>false</favorited> 
  <in_reply_to_screen_name></in_reply_to_screen_name> 
  <user> 
    <id>18571629</id> 
    <name>bboyle_BOT</name> 
    <screen_name>bboyle_BOT</screen_name> 
    <location></location> 
    <description></description> 
    <profile_image_url>http://static.twitter.com/images/default_profile_normal.png</profile_image_url> 
    <url></url> 
    <protected>true</protected> 
    <followers_count>1</followers_count> 
  </user> 
</status>
=cut

for (@$timeline) {
	my $user = $_->{user}{screen_name};
	$status = sprintf '%s: %s', $user, $_->{text};
	system('echo "' . $status . "\n" . '" >> /var/log/mythtv/mythTwitter.log');

	# ignore @replies and only read messages "want to watch"
	if ($status =~ m/want\s+to\s+watch.*/) {
		(my $title = $status) =~ s/^.*watch\s*([^-\x{2014}]*).*$/$1/;
		$title =~ s/\s+$//;
		$twitter->update(sprintf('@%s you want to watch %s?', $user, $title));
		system('echo "FOUND: ' . $title . "\n" . '" >> /var/log/mythtv/mythTwitter.log');
	}

	# find out what users (that are being followed) want to watch
	# search for matching titles in EPG
	# if 1 "good" match, schedule it and output: @username will tape "title" on "channel" at "time"
	# if multiple matches, @username you want: (1) <channel>@<time>, (2) <channel>@<time> ?
	# allow confirmation by @reply?
}

# done
exit(0);
