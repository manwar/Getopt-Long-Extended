use strict;
use warnings;
use Test::More tests => 4;
use Getopt::Long::Extended qw(extended_get_options);

# Test basic single argument
{
    local @ARGV = ('--name', 'value');
    my $specs = {
        'name' => { nargs => 1 }
    };

    my ($result, $options) = extended_get_options(\@ARGV, $specs);

    ok($result, 'Parsing succeeded');
    is($options->{name}, 'value', 'Got correct value');
}

# Test boolean flag
{
    local @ARGV = ('--verbose');
    my $specs = {
        'verbose' => { action => 'store_true' }
    };

    my ($result, $options) = extended_get_options(\@ARGV, $specs);

    ok($result && $options->{verbose}, 'Boolean flag set');
}

# Test optional flag (no argument)
{
    local @ARGV = ();
    my $specs = {
        'flag' => { }
    };

    my ($result, $options) = extended_get_options(\@ARGV, $specs);

    ok($result && !$options->{flag}, 'Optional flag not set');
}
