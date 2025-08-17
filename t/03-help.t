use strict;
use warnings;
use Test::More tests => 5;  # Now correctly matches the 5 tests we run
use Getopt::Long::Extended qw(extended_get_options);

# Test help output
{
    local @ARGV = ('--help');
    my $specs = {
        'test' => {
            help => 'Test option description',
            nargs => 1,
            metavar => ['TESTARG']
        },
    };

    my ($result, $options) = extended_get_options(\@ARGV, $specs);

    # Verify results - these are 4 tests
    ok($result, 'Help parsing succeeded');
    ok(exists $options->{_help_text}, 'Help text generated');
    like($options->{_help_text}, qr/Test option description/, 'Help text contains description');
    like($options->{_help_text}, qr/TESTARG/, 'Help text contains metavar');
}

# This is the 5th test
{
    local @ARGV = ('--help');
    my $specs = {
        'test' => { help => 'Test option' }
    };

    my ($result, $options) = extended_get_options(\@ARGV, $specs);
    pass("Execution continues after help");
}
