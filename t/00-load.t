use strict;
use warnings;
use Test::More tests => 2;

BEGIN {
    use_ok('Getopt::Long::Extended');
    can_ok('Getopt::Long::Extended', 'extended_get_options');
}

diag( "Testing Getopt::Long::Extended $Getopt::Long::Extended::VERSION, Perl $], $^X" );
