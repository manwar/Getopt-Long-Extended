use strict;
use warnings;
use Test::More;
use Test::Warn;
use Getopt::Long::Extended qw(extended_get_options);

### Test 1: store_true basic functionality
{
    warnings_are {
        local @ARGV = ('--verbose');
        my $specs = {
            verbose => {
                action => 'store_true',
                help => 'Enable verbose output'
            }
        };

        my ($result, $options) = extended_get_options(\@ARGV, $specs);

        ok($result, "store_true: Parsing succeeds");
        ok(exists $options->{verbose}, "store_true: Option exists");
        is($options->{verbose}, 1, "store_true: Flag is set to true");
    } [], "store_true: No warnings expected";
}

### Test 2: store_true default case
{
    warnings_are {
        local @ARGV = ();
        my $specs = {
            verbose => {
                action => 'store_true',
                help => 'Enable verbose output'
            }
        };

        my ($result, $options) = extended_get_options(\@ARGV, $specs);

        ok($result, "store_true default: Parsing succeeds");
        ok(exists $options->{verbose}, "store_true default: Option exists");
        is($options->{verbose}, 0, "store_true default: Flag defaults to false");
    } [], "store_true default: No warnings expected";
}

### Test 3: store_false basic functionality
{
    warnings_are {
        local @ARGV = ('--quiet');
        my $specs = {
            quiet => {
                action => 'store_false',
                help => 'Disable verbose output'
            }
        };

        my ($result, $options) = extended_get_options(\@ARGV, $specs);

        ok($result, "store_false: Parsing succeeds");
        ok(exists $options->{quiet}, "store_false: Option exists");
        is($options->{quiet}, 0, "store_false: Flag is set to false");
    } [], "store_false: No warnings expected";
}

### Test 4: store_false default case
{
    warnings_are {
        local @ARGV = ();
        my $specs = {
            quiet => {
                action => 'store_false',
                help => 'Disable verbose output'
            }
        };

        my ($result, $options) = extended_get_options(\@ARGV, $specs);

        ok($result, "store_false default: Parsing succeeds");
        ok(exists $options->{quiet}, "store_false default: Option exists");
        is($options->{quiet}, 1, "store_false default: Flag defaults to true");
    } [], "store_false default: No warnings expected";
}

### Test 5: Combined boolean flags
{
    warnings_are {
        local @ARGV = ('--verbose', '--quiet');
        my $specs = {
            verbose => {
                action => 'store_true',
                help => 'Enable verbose output'
            },
            quiet => {
                action => 'store_false',
                help => 'Disable verbose output'
            }
        };

        my ($result, $options) = extended_get_options(\@ARGV, $specs);

        ok($result, "Combined flags: Parsing succeeds");
        ok(exists $options->{verbose}, "Combined flags: Verbose exists");
        is($options->{verbose}, 1, "Combined flags: Verbose is true");
        ok(exists $options->{quiet}, "Combined flags: Quiet exists");
        is($options->{quiet}, 0, "Combined flags: Quiet is false");
    } [], "Combined flags: No warnings expected";
}

done_testing;
