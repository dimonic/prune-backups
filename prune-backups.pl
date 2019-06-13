#!/usr/bin/perl -w
use DateTime;

# length of time for each backup type. ADjust as needed
my $max_monthly = DateTime::Duration->new( years => 2 );
my $max_weekly = DateTime::Duration->new( months => 2 );
my $max_daily = DateTime::Duration->new( weeks => 2 );
my $day_of_week_to_keep = 6; # saturday

# pass filenames as parameters
foreach my $backup_file (@ARGV) {

	($yyyy, $mm, $dd) = ($backup_file =~ m/.*(\d\d\d\d)-(\d\d)-(\d\d)/);

	my $filedate = DateTime->new( year => $yyyy, month => $mm, day => $dd );
	my $now = DateTime->now;

	if ( $now > $filedate + $max_monthly ) {
		print "File older than ", $max_monthly->years, " years, deleting $backup_file.\n";
		unlink $backup_file;
	} elsif ( $now > $filedate + $max_weekly ) {
		print "File older than ", $max_weekly->months, " months.\n";
		if ( $filedate->week_day_of_month() != 1 ) {
			print "Not first backup of month, deleting $backup_file.\n";
			unlink $backup_file;
		} else {
			print "Keeping first day $day_of_week_to_keep of month file.\n";
		}
	} elsif ( $now > $filedate + $max_daily ) {
		print "File older than ", $max_daily->weeks, " weeks.\n";
		if ($filedate->dow() != $day_of_week_to_keep) {
			print "Not day $day_of_week_to_keep, deleting $backup_file.\n";
			unlink $backup_file;
		} else {
			print "Keeping ", $filedate->day_name(), " file\n.";
		}
	} else {
		print "Keeping daily file $backup_file.\n";
	}
}
