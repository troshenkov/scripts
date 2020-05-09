#!/usr/cisco/bin/perl5.16.3

use strict;
use warnings;
use Carp;
use English qw( -no_match_vars );
use Fatal qw{close};

use Getopt::Long;
use Text::Table;

Getopt::Long::Configure("permute");

my $farm       = q{};
my @resource        ;
my @hg              ;
my @queue           ;
my $delay      = 30 ;
my $head_print = 32 ;

my @farms_list = ( 'sjc-hw', 'csi-hw', 'blr-hw', 'imt', 'nsb', 'crdc' );
my @month = ( 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec' );

sub usage {
    print "Usage:                                                                                       \n";
    print "  q_mon.pl                                                                                   \n";
    print "    -f|--farm          [", join( ' ', @farms_list ) , "]                                     \n";
    print "    -r|--resource      [vcs dc]                                                              \n";
    print "    -H|--hg            ALL or --hg [Normal_HG/[Option_Name], Interactive_HG/Interact]        \n";
    print "    -q|--queue         ALL or --queue [ARG]/[Option_Name] --queue [ARG] ...                  \n";
    print "    -s|--sleeptime     Default: $delay sec                                                   \n";
    print "    -l|--headerlines   Default: $head_print lines                                            \n";
    print "    -h|--help          Print help                                                            \n";
    exit 0;
}

GetOptions(
    'f|farm=s'        => \$farm       ,
    'r|resource=s'    => \@resource   ,
    'H|hg=s'          => \@hg         ,
    'q|queue=s'       => \@queue      ,
    's|sleeptime=i'   => \$delay      ,
    'l|headerlines=i' => \$head_print ,
) || usage();

if ( !$farm | !@resource & !@hg & !@queue ) {
    usage();
}

if ( ! grep( /^$farm$/, @farms_list ) ) {
    usage();
}

my $lsid =  qx{lsid --farm $farm | grep -F 'My cluster name is' | sed s/'My cluster name is '// };

if ( ! $farm =~ $lsid ) {
    print "Fail connection to the Farm: $farm \n";
    exit 1;
}

if (@resource){
    my @tmp = qx( bhosts --farm $farm -s | grep -e 'master' -e 'TOTAL' | awk '{ print \$1 }' | sort -u );
    chomp @tmp;
    foreach my $item ( @resource ) {
        my $name = original_names($item);
        if ( ! grep( /^$name$/, @tmp ) ) {
            usage();
        }
    }
}

if (@hg) {
    my @tmp = qx( bmgroup --farm $farm -w | awk '{ print \$1 }' | grep '_HG' );
    chomp @tmp;
    if ( $hg[0] =~ "ALL" ) {
        @hg = ();
        foreach ( @tmp ) {
             push ( @hg, split( "\n", $_ ) );
        }
    } else {
        foreach my $item ( @hg ) {
            my $name = original_names($item);
            if ( ! grep( /^$name$/, @tmp ) ) {
                usage();
	    }
        }
    }
}

if (@queue) {
    my @tmp = qx( bqueues --farm $farm | cut -d" " -f1 | grep -v 'QUEUE_NAME' );
    chomp @tmp;
    if ( $queue[0] =~ "ALL" ) {
        @queue = ();
        foreach ( @tmp ) {
            push ( @queue, split( "\n", $_ ) );
        }
    } else {
        foreach my $item ( @queue ) {
            my $name = original_names($item);
            if ( ! grep( /^$name$/, @tmp ) ) {
                usage();
            }
        }
    }
}

my @data_line = ();
my $head_count = 0;

while (1) {

    my ( $sec, $min, $hour, $mday, $mon, $year, $wday, $yday, $isdst ) = localtime();
    push @data_line, sprintf( "%3s-%02d", $month[$mon], $mday );
    push @data_line, sprintf( "%02d:%02d:%02d", $hour, $min, $sec );
    push @data_line, qx{ bhosts --farm $farm -w | grep -v master | grep -c -e _Adm -e unavail -e _LIM -e unreachsed };
    my @columns = ( "Data\n", "Time\n", "Adm\n" );

    my @_bhosts = qx{ bhosts --farm $farm -s };
    foreach my $item ( @resource ){
        if ( $item =~ "dc" ) {
            push @data_line, res_dc( 'dc', \@_bhosts );
            push @columns, "DC\n";
        }
        if ( $item =~ "vcs" ) {
            ( my $vr, my $va )   = res_aval( 'vcs',  \@_bhosts );
            ( my $vur, my $vua ) = res_aval( 'vcsu', \@_bhosts );
            push @data_line, sprintf( "%s(%s)", $vr, $vur );
            push @data_line, $va;
            push @columns, "VCS\nTot", "VCS\nRes";
        }
    }

    foreach my $item (@hg){
            push @data_line, run_count( $farm, original_names($item) );
            push @columns, "HG Use%\n" . short_option_names($item);
    }

    my @new_queues = qx{ bqueues --farm $farm };
    foreach my $item (@queue){
        push @data_line, pend_run( original_names($item), \@new_queues );
        push @columns, short_option_names($item) . "\nPen", short_option_names($item) . "\nRun";
    }

    my @HEADER = map { $_ => \'|' } @columns;
    my $tb = Text::Table->new( @HEADER );
    $tb->load( join( " ", @data_line ) );

    if ($head_count > 0 ) {
        print $tb->body();
        print $tb->body_rule('-','|');
    }

    if ( ( $head_count % $head_print ) == 0 ) {
        my @uptime = qx{uptime};
        my $perf;
        ( $perf = $uptime[0] ) =~ s/.*load average://;
        print "\n:Started on " . $ENV{HOSTNAME} . " : " . $perf ;
        print $tb->rule('-', '+');
        print $tb->title();
        print $tb->rule('-', '+');
    }

    @data_line = ();
    sleep $delay;
    $head_count++;
}
## end while (1)

sub original_names {
    my $item = shift;
    my $name = $item;
    if ( $item =~ /\/s*(.+)$/  ) {
        $name = ( split( /\//, $item ) )[0];
    }
    return $name;
}

sub short_option_names {
    my $item = shift;
    my $name = $item;
    if ( $item =~ /\/s*(.+)$/ ) {
        $name = ( split( /\//, $item ) )[1];
    }
    return $name;
}

sub res_dc {
     my $r      = shift;
     my $rd_ref = shift;
     my @line = grep { /^$r / } @{$rd_ref};
     my $out = 'n/a';
     if ($line[0]) {
         $out = int( ( split( /\s+/, $line[0] ) )[1] );
     }
     return $out;
}

sub res_aval {
    my $r      = shift;
    my $rd_ref = shift;
    my @line = grep { /^$r / } @{$rd_ref};
    my $out1 = 'n/a';
    my $out2 = 'n/a';
    if ($line[0]) {
        $out1 = int( ( split( /\s+/, $line[0] ) )[1] );
        $out2 = int( ( split( /\s+/, $line[0] ) )[2] );
    }
    return ( $out1, $out2 );
}

sub run_count {
    my $f   = shift;
    my $hgi = shift;
    my @bho = qx{ bhosts --farm $f -w $hgi | grep -v -e closed_Adm -e unavail -e _LIM -e RUN -e MAX };
    my $run = 0;
    my $max = 0.001;
    my $out = 'n/a';
    if (@bho) {
        foreach my $line (@bho) {
            my @cols = split /\s+/, $line;
            $run += $cols[5];
            $max += $cols[3];
        }
        $out = int( 100 * ( 0.005 + $run / $max ));
    }
    return $out;
}

sub pend_run {
    my $q      = shift;
    my $qd_ref = shift;
    my @line = grep { /^$q / } @{$qd_ref};
    my $pend = 'n/a';
    my $run  = 'n/a';
    if ($line[0]) {
        $pend = int( ( split( /\s+/, $line[0] ) )[8] );
        $run  = int( ( split( /\s+/, $line[0] ) )[9] );
    }
    return ( $pend, $run );
}

