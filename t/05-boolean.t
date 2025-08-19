use strict;
use warnings;
use Test::More;
use Test::Warn;
use Getopt::Long::Extended qw(extended_get_options);

BEGIN { $ENV{TEST_MODE} = 1 }

# Initialize test counter
my $test_count = 0;

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

        $test_count += 3;
        ok($result, "store_true: Parsing succeeds");
        ok(exists $options->{verbose}, "store_true: Option exists");
        is($options->{verbose}, 1, "store_true: Flag is set to true");
    } [], "store_true: No warnings expected";
    $test_count++;
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

        $test_count += 3;
        ok($result, "store_true default: Parsing succeeds");
        ok(exists $options->{verbose}, "store_true default: Option exists");
        is($options->{verbose}, 0, "store_true default: Flag defaults to false");
    } [], "store_true default: No warnings expected";
    $test_count++;
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

        $test_count += 3;
        ok($result, "store_false: Parsing succeeds");
        ok(exists $options->{quiet}, "store_false: Option exists");
        is($options->{quiet}, 0, "store_false: Flag is set to false");
    } [], "store_false: No warnings expected";
    $test_count++;
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

        $test_count += 3;
        ok($result, "store_false default: Parsing succeeds");
        ok(exists $options->{quiet}, "store_false default: Option exists");
        is($options->{quiet}, 1, "store_false default: Flag defaults to true");
    } [], "store_false default: No warnings expected";
    $test_count++;
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

        $test_count += 5;
        ok($result, "Combined flags: Parsing succeeds");
        ok(exists $options->{verbose}, "Combined flags: Verbose exists");
        is($options->{verbose}, 1, "Combined flags: Verbose is true");
        ok(exists $options->{quiet}, "Combined flags: Quiet exists");
        is($options->{quiet}, 0, "Combined flags: Quiet is false");
    } [], "Combined flags: No warnings expected";
    $test_count++;
}

done_testing($test_count);


__END__
use strict;
use warnings;
use Test::More tests => 12;
use Getopt::Long::Extended qw(extended_get_options);

# Test 1: simple flag
my ($res1, $opts1, $args1) = extended_get_options(
    ['--verbose'],
    { verbose => { action => 'store_true' } }
);
is($res1, 1, 'parse success');
is($opts1->{verbose}, 1, 'verbose flag set');
is_deeply($args1, [], 'no remaining args');

# Test 2: store_false
my ($res2, $opts2, $args2) = extended_get_options(
    ['--no-cache'],
    { cache => { action => 'store_false' } }
);
is($res2, 1, 'parse success');
is($opts2->{cache}, 0, 'cache correctly false');

# Test 3: single argument
my ($res3, $opts3, $args3) = extended_get_options(
    ['--file', 'foo.txt'],
    { file => { nargs => 1 } }
);
is($res3, 1, 'parse success');
is($opts3->{file}, 'foo.txt', 'file option parsed');

# Test 4: multi-argument
my ($res4, $opts4, $args4) = extended_get_options(
    ['--coords', '10', '20', '30'],
    { coords => { nargs => 3 } }
);
is($res4, 1, 'parse success');
is_deeply($opts4->{coords}, ['10','20','30'], 'multi-arg parsed correctly');

# Test 5: missing required
my ($res5, $opts5, $args5) = extended_get_options(
    [],
    { name => { required => 1, nargs => 1 } }
);
is($res5, 0, 'missing required returns failure');

# Test 6: help text
my ($res6, $opts6, $args6) = extended_get_options(
    ['--help'],
    { verbose => { action => 'store_true', help => 'Enable verbose' } }
);
ok($opts6->{help}, 'help flag set');
like($opts6->{_help_text}, qr/--verbose\s+Enable verbose/, 'help text contains verbose');


__END__

use strict;
use warnings;
use Test::More;
use Test::Warn;
use Getopt::Long::Extended qw(extended_get_options);

BEGIN { $ENV{TEST_MODE} = 1 }

# Initialize test counter
my $test_count = 0;

### Test 1: store_true basic functionality
{
    warning_is {
        local @ARGV = ('--verbose');
        my $specs = {
            verbose => {
                action => 'store_true',
                help => 'Enable verbose output'
            }
        };

        my ($result, $options) = extended_get_options(\@ARGV, $specs);

        $test_count += 3;
        ok($result, "store_true: Parsing succeeds");
        ok(exists $options->{verbose}, "store_true: Option exists");
        is($options->{verbose}, 1, "store_true: Flag is set to true");
    } [], "store_true: No warnings expected";
    $test_count++;
}

### Test 2: store_true default case
{
    warning_is {
        local @ARGV = ();
        my $specs = {
            verbose => {
                action => 'store_true',
                help => 'Enable verbose output'
            }
        };

        my ($result, $options) = extended_get_options(\@ARGV, $specs);

        $test_count += 3;
        ok($result, "store_true default: Parsing succeeds");
        ok(exists $options->{verbose}, "store_true default: Option exists");
        is($options->{verbose}, 0, "store_true default: Flag defaults to false");
    } [], "store_true default: No warnings expected";
    $test_count++;
}

### Test 3: store_false basic functionality
{
    warning_is {
        local @ARGV = ('--quiet');
        my $specs = {
            quiet => {
                action => 'store_false',
                help => 'Disable verbose output'
            }
        };

        my ($result, $options) = extended_get_options(\@ARGV, $specs);

        $test_count += 3;
        ok($result, "store_false: Parsing succeeds");
        ok(exists $options->{quiet}, "store_false: Option exists");
        is($options->{quiet}, 0, "store_false: Flag is set to false");
    } [], "store_false: No warnings expected";
    $test_count++;
}

### Test 4: store_false default case
{
    warning_is {
        local @ARGV = ();
        my $specs = {
            quiet => {
                action => 'store_false',
                help => 'Disable verbose output'
            }
        };

        my ($result, $options) = extended_get_options(\@ARGV, $specs);

        $test_count += 3;
        ok($result, "store_false default: Parsing succeeds");
        ok(exists $options->{quiet}, "store_false default: Option exists");
        is($options->{quiet}, 1, "store_false default: Flag defaults to true");
    } [], "store_false default: No warnings expected";
    $test_count++;
}

### Test 5: Combined boolean flags
{
    warning_is {
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

        $test_count += 5;
        ok($result, "Combined flags: Parsing succeeds");
        ok(exists $options->{verbose}, "Combined flags: Verbose exists");
        is($options->{verbose}, 1, "Combined flags: Verbose is true");
        ok(exists $options->{quiet}, "Combined flags: Quiet exists");
        is($options->{quiet}, 0, "Combined flags: Quiet is false");
    } [], "Combined flags: No warnings expected";
    $test_count++;
}

done_testing($test_count);
