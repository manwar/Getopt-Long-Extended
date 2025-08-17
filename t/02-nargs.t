use strict;
use warnings;
use Test::More tests => 10;
use Getopt::Long::Extended qw(extended_get_options);

# Test basic nargs functionality
{
    local @ARGV = ('--copy', 'bucket1', 'key1', 'dest1');
    my $specs = {
        'copy' => {
            nargs => 3,
            metavar => ['BUCKET', 'KEY', 'DEST'],
            help => 'Copy operation',
        },
    };

    my ($result, $options) = extended_get_options(\@ARGV, $specs);

    ok($result, 'Parsing succeeded with correct nargs count');
    is(ref $options->{copy}, 'ARRAY', 'Got array reference');
    is_deeply(
        $options->{copy},
        ['bucket1', 'key1', 'dest1'],
        'Correct values stored'
    );
}

# Test insufficient arguments
{
    local @ARGV = ('--copy', 'bucket1', 'key1'); # Missing dest
    my $specs = {
        'copy' => { nargs => 3 }
    };

    my ($result, $options) = extended_get_options(\@ARGV, $specs);

    ok(!$result, 'Parsing fails with insufficient args');
}

# Test with remaining arguments
{
    local @ARGV = ('--copy', 'b1', 'k1', 'd1', 'extra1', 'extra2');
    my $specs = {
        'copy' => { nargs => 3 }
    };

    my ($result, $options, $remaining) = extended_get_options(\@ARGV, $specs);

    ok($result, 'Parsing succeeds with remaining args');
    is_deeply(
        $options->{copy},
        ['b1', 'k1', 'd1'],
        'Correct values stored'
    );
    is_deeply(
        $remaining,
        ['extra1', 'extra2'],
        'Remaining args preserved'
    );
}

# Test nargs=1 (special case)
{
    local @ARGV = ('--name', 'value1');
    my $specs = {
        'name' => { nargs => 1 }
    };

    my ($result, $options) = extended_get_options(\@ARGV, $specs);

    ok($result, 'Parsing succeeds with nargs=1');
    is($options->{name}, 'value1', 'Single value stored correctly');
}

# Test required nargs
{
    local @ARGV = (); # No args provided
    my $specs = {
        'copy' => {
            nargs => 2,
            required => 1,
        }
    };

    my ($result, $options) = extended_get_options(\@ARGV, $specs);

    ok(!$result, 'Parsing fails when required nargs not provided');
}
