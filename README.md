# Getopt::Long::Extended

Python-style argument parsing for Getopt::Long

## Installation

    perl Makefile.PL
    make
    make test
    make install

## Usage

```perl
use Getopt::Long::Extended qw(extended_get_options);

my $specs = {
    'copy' => {
        nargs => 3,
        metavar => ['SRC_BUCKET', 'SRC_KEY', 'DEST_KEY'],
        help => 'Copy operation',
    },
};

my ($result, $options) = extended_get_options(\@ARGV, $specs);
```

## License

This is released under the same terms as Perl itself.
