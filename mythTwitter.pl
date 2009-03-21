#!/usr/bin/perl -w


=head1 record.pl

	A script to read a twitter feed with recording suggestions
	Run as a cron job

	in the format:
	* want(s) to watch <program name>
	[ optional details ]
	* on <channel>
	* on <date>
	* at <time>

=cut

use strict;


# CONSTANTS

# twitter username and password
use constant TWITTER_USERNAME	=> '<USERNAME>';
use constant TWITTER_PASSWORD	=> '<PASSWORD>';


# MODULES
use Net::Twitter;
use HTTP::Date;


# connect to twitter
my $twitter = Net::Twitter->new(username => TWITTER_USERNAME, password => TWITTE
R_PASSWORD);	

# test update
# $twitter->update("Test");

# read followers tweets

# get status
my %args = (
	since	=> `head -n 1 /var/log/mythtv/mythTwitter.log`
);
my $timeline = $twitter->friends_timeline(\%args);
my $time = time2str;
system('echo "' . $time . "\n" . '" > /var/log/mythtv/mythTwitter.log');

=pod

API format:

<status> 
  <created_at>Sun Jan 11 02:36:52 +0000 2009</created_at> 
  <id>1110214744</id> 
  <text>Test</text> 
  <source>&lt;a href=&quot;http://search.cpan.org/dist/Net-Twitter/&quot;&gt;Per
l Net::Twitter&lt;/a&gt;</source> 
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
    <profile_image_url>http://static.twitter.com/images/default_profile_normal.p
ng</profile_image_url> 
    <url></url> 
    <protected>true</protected> 
    <followers_count>1</followers_count> 
  </user> 
</status>
=cut

for (@$timeline) {
	my $user = $_->{user}{screen_name};
	my $status = sprintf '%s: %s', $user, $_->{text};
	system('echo "' . $status . "\n" . '" >> /var/log/mythtv/mythTwitter.log
');

	# ignore @replies and only read messages "want ... watch"
	if ($user ne TWITTER_USERNAME and $status =~ m/want.*watch.*/) {
		(my $title = $status) =~ s/^.*watch\s*//;
		$twitter->update(sprintf('@%s you want to watch "%s"?', $user, $
title));
		system('echo "FOUND: ' . $title . "\n" . '" >> /var/log/mythtv/m
ythTwitter.log');
	}

	# find out what users (that are being followed) want to watch
	# search for matching titles in EPG
	# if 1 "good" match, schedule it and output: @username will tape "title"
 on "channel" at "time"
	# if multiple matches, @username you want: (1) <channel>@<time>, (2) <ch
annel>@<time> ?
	# allow confirmation by @reply?
}

# done
exit(0);

