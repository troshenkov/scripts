#!/usr/bin/perl
# ------------------------------------------------------------------------------
# Process Monitoring and Restart Script
# Author: Dmitry Troshenkov (troshenkov.d@gmail.com)
# Description:
#   This script checks if a list of services (e.g., Zimbra, MySQL, Apache2, etc.)
#   are running on the system. If any service is found to be stopped, the script
#   will attempt to start the service and log the action.
#
# Usage:
#   ./process_monitor.pl
#
# Features:
#   - Checks the status of a predefined list of processes.
#   - Starts any services that are not running.
#   - Logs actions to /var/log/test.log.
#
# Dependencies:
#   - ps (for process listing)
#   - init.d service scripts (for starting services)
#
# Configuration:
#   - Modify the @testProc array to include the list of services to monitor.
#
# Exit Codes:
#   0 - Script executed successfully.
#
# Example:
#   ./process_monitor.pl
#
# ------------------------------------------------------------------------------

use POSIX qw(strftime);
use File::Basename;

my $date = strftime "%m/%d/%Y", localtime;
my $log_file = '/var/log/test.log';

# Define the list of processes to check
my @testProc = ('zimbra', 'mysql', 'apache2', 'named', 'squid', 'vsftpd', 'sshd');

# Open log file in append mode
open my $log_fh, '>>', $log_file or die "Could not open log file $log_file: $!\n";

foreach my $proc (@testProc) {
    # Check if the process is running, excluding the current script's user
    my $out = `ps aux | grep -v 'grep' | grep -v '$0' | grep -v 'root' | grep -w '$proc'`;

    if ($out) {
        print "$proc is running\n";
    } else {
        print "$proc not running, will be started now\n";
        system("/etc/init.d/$proc start");

        # Log the action
        print $log_fh "$date - $proc not running, will be started now\n";
    }
}

# Close the log file
close $log_fh or warn "Could not close log file $log_file: $!\n";

exit 0;
