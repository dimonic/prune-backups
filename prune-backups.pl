#!/usr/bin/perl -w
use Getopt::Long;
use DateTime;
use Pod::Usage;

my $help = 0;
my $man = 0;
my $years = 2;
my $months = 2;
my $weeks = 2;
my $weekday_to_keep = 6; # monday = 1. saturday

GetOptions ('help|?' => \$help,
			'man' => \$man,
			'grandfather|years=i' => \$years,
			'father|months=i' => \$months,
			'son|weeks=i' => \$weeks,
			'day_to_keep=i' => \$weekday_to_keep ) or pod2usage(2);
pod2usage(1) if $help;
pod2usage(-exitval => 0, -verbose => 2) if $man;

# length of time for each backup type. ADjust as needed
my $max_monthly = DateTime::Duration->new( years => $years );
my $max_weekly = DateTime::Duration->new( months => $months );
my $max_daily = DateTime::Duration->new( weeks => $weeks );

# pass filenames as parameters
foreach my $backup_file (@ARGV) {
	($yyyy, $mm, $dd) = ($backup_file =~ m/.*(\d\d\d\d).(\d\d).(\d\d)/);
	my $filedate = DateTime->new( year => $yyyy, month => $mm, day => $dd );
	my $now = DateTime->now;

	if ( $now > $filedate + $max_monthly ) {
		print "File older than ", $max_monthly->years, " years, deleting $backup_file.\n";
		unlink $backup_file;
	} elsif ( $now > $filedate + $max_weekly ) {
		print "File older than ", $max_weekly->months, " months.\n";
		if ( $filedate->dow() == $weekday_to_keep && $filedate->weekday_of_month() == 1 ) {
			print "Keeping first day $weekday_to_keep of month file.\n";
		} else {
			print "Not first backup of month, deleting $backup_file.\n";
			unlink $backup_file;
		}
	} elsif ( $now > $filedate + $max_daily ) {
		print "File older than ", $max_daily->weeks, " weeks.\n";
		if ($filedate->dow() == $weekday_to_keep) {
			print "Keeping ", $filedate->day_name(), " file\n.";
		} else {
			print "Not day $weekday_to_keep, deleting $backup_file.\n";
			unlink $backup_file;
		}
	} else {
		print "Keeping daily file $backup_file.\n";
	}
}


__END__
=head1 prune-backups.pl
Implement grandfather, father, son backup strategy by pruning files that fall
out of configured time slots.

=head1 SYNOPSIS

prune-backup.pl [options] <file ...>

=head1 OPTIONS

=over 8

=item B<-help>

Shows brief help message.

=item B<-man>

Detailed man page

=item B<--years>

Number of years to keep monthly backups. The backup kept is the daily backup
of the weekday given by B<--weekday_to_keep>. This defaults to 2 years.

=item B<--months>

Number of months to keep weekly backups. The backup kept is the daily backup
of the weekday given by B<--weekday_to_keep>. Defaults to 2 months.

=item B<--weeks>

Number of weeks to keep daily backups. Defaults to 2 weeks.

=item B<--weekday_to_keep>

The number of the weekday (monday=1) to keep for weekly and monthly backups. 
Defaults to 6 (Saturday)

=back

=head1 DESCRIPTION

B<prune-backups.pl> parses files that have a date included anywhere in the filename
in the format yyyy-mm-dd.
 
prune-backups.pl should be run daily (by cron), on all the files you wish ro
"rotate". It is designed for the "grandfather, father, son" strategy - to keep
daily backups for a while, then weekly, then monthly.

Set the number of weeks you want to keep daily backups for,
then the number of months to keep weekly backups,
and then the number of year to keep monthly backups.
You can also set which day of the week you keep for the
weekly and monthly backups.

prune backups will delete any files that age out according to the rules
you have set.

=cut
