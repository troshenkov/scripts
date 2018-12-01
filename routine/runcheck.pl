#!/usr/bin/perl

use POSIX qw(strftime);
my $date = strftime "%m/%d/%Y", localtime;

@testProc = ('zimbra', 'mysql', 'apache2', 'named', 'squid', 'vsftpd', 'sshd');

foreach (@testProc){
    my $out = `ps aux | grep $_ | grep -v root`;

    if ($out =~ /$_/) { print "$_ is running\n";}
	
	else {
		print "$_ not running, will be start now\n";
		system("/etc/init.d/$_ start");
		open (LOGFILE, '>>/var/log/test.log');
		print LOGFILE "$date - $_ not running, will be start now\n";
		close LOGFILE;
		}
}

