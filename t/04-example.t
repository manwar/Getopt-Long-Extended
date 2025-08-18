use strict;
use warnings;
use Test::More;
use Test::Warn;
use Getopt::Long::Extended qw(extended_get_options);

# Test specification
my $specs = {
    output => {
        nargs => 1,
        help => 'Output file path'
    },
    copy => {
        nargs => 3,
        required => 1,
        metavar => ['SRC', 'DST', 'MODE'],
        help => 'Copy operation'
    },
    files => {
        nargs => 2,
        help => 'List of files to process'
    }
};

# Test 1: Basic successful case (should produce no warnings)
{
    warning_is {
        my @args = (
            '--output', 'result.txt',
            '--copy', 'src.txt', 'dest.txt', 'overwrite',
            '--files', 'a.txt', 'b.txt'
        );

        my ($result, $options) = extended_get_options(\@args, $specs);

        ok($result, "Successful parsing");
        is($options->{output}, 'result.txt', "Regular option (output)");
        is_deeply(
            $options->{copy},
            ['src.txt', 'dest.txt', 'overwrite'],
            "Fixed multiple values (copy)"
        );
        is_deeply(
            $options->{files},
            ['a.txt', 'b.txt'],
            "Fixed multiple values (files)"
        );
    } [], "No warnings during successful parsing";
}

# Test 2: Missing required arguments (should warn)
{
    warning_like {
        my @args = ('--copy', 'file1', 'file2'); # Missing 3rd argument
        my ($result, $options) = extended_get_options(\@args, $specs);

        ok(!$result, "Fails with missing arguments");
    } qr/Incorrect number of arguments for copy \(expected 3\)/,
    "Got expected warning about missing arguments";
}

# Test 3: Fixed arguments edge case (no warnings)
{
    warning_is {
        my ($result, $options) = extended_get_options(
            ['--files', 'file1.txt', 'file2.txt'],
            { files => { nargs => 2 } }
        );

        ok($result, "Accepts exactly 2 files");
        is_deeply($options->{files}, ['file1.txt', 'file2.txt'], "Files stored correctly");
    } [], "No warnings with exact argument count";
}

# Test 4: No arguments provided (should warn about required options)
{
    warning_like {
        my ($result, $options) = extended_get_options([], $specs);

        ok(!$result, "Fails with no arguments when required options exist");
    } qr/Missing required option: copy/,
    "Got expected warning about missing required option";
}

# Test 5: Optional arguments case (no warnings)
{
    warning_is {
        my $optional_specs = {
            output => {
                nargs => 1,
                help => 'Output file path'
            }
        };

        my ($result, $options) = extended_get_options([], $optional_specs);

        ok($result, "Succeeds with no arguments when no required options");
    } [], "No warnings with optional arguments";
}

done_testing;
