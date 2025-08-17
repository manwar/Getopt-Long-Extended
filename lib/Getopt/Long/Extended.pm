package Getopt::Long::Extended;

use strict;
use warnings;
use 5.008001;
use Getopt::Long qw(GetOptionsFromArray);
use Exporter 'import';

our $VERSION = '0.01';
our @EXPORT = qw(extended_get_options);

sub extended_get_options {
    my ($args, $specs) = @_;

    # Validate inputs
    unless (ref $args eq 'ARRAY') {
        warn "First argument must be an array reference";
        return (0, {}, []);
    }

    unless (ref $specs eq 'HASH') {
        warn "Second argument must be a hash reference";
        return (0, {}, $args);
    }

    my %options;
    my @getopt_specs;
    my %var_mapping;
    my @args_copy = @$args;

    # Convert Python-style specs to Getopt::Long format
    foreach my $opt_name (keys %$specs) {
        my $spec = $specs->{$opt_name};

        # Validate spec structure
        unless (ref $spec eq 'HASH') {
            warn "Spec for $opt_name must be a hash reference";
            return (0, {}, \@args_copy);
        }

        my $dest = $spec->{dest} || $opt_name;
        $dest =~ s/^-+//;  # Remove leading dashes

        if (exists $spec->{nargs}) {
            # Handle multi-argument options
            my $nargs = $spec->{nargs};

            unless ($nargs =~ /^\d+$/ && $nargs > 0) {
                warn "Invalid nargs value for $opt_name: $nargs";
                return (0, {}, \@args_copy);
            }

            if ($nargs == 1) {
                push @getopt_specs, ["$opt_name=s", \$options{$dest}];
            } else {
                push @getopt_specs, ["$opt_name=s", sub {
                    my ($opt, $val) = @_;
                    $options{$dest} = [$val];
                    # Collect remaining arguments
                    for (my $i = 1; $i < $nargs && @args_copy; $i++) {
                        push @{$options{$dest}}, shift @args_copy;
                    }
                }];
            }
        }
        elsif ($spec->{action} && $spec->{action} eq 'store_true') {
            push @getopt_specs, [$opt_name, \$options{$dest}];
        }
        elsif ($spec->{action} && $spec->{action} eq 'store_false') {
            push @getopt_specs, ["no$opt_name", \$options{$dest}];
        }
        else {
            # Default to optional flag (no argument)
            push @getopt_specs, [$opt_name . '!', \$options{$dest}];
        }

        # Store metavar info for help messages
        $var_mapping{$opt_name} = {
            metavars => ref $spec->{metavar} eq 'ARRAY'
                ? $spec->{metavar}
                : (exists $spec->{nargs} && $spec->{nargs} > 1
                    ? ['ARG'] x $spec->{nargs}
                    : ['ARG']),
            help => $spec->{help} || '',
        };
    }

    # Add help option if not defined
    unless (exists $specs->{help}) {
        push @getopt_specs, ['help', \$options{help}];
        $var_mapping{help} = {
            metavars => [],
            help => 'Show this help message',
        };
    }

    # Parse options
    my $result = GetOptionsFromArray(
        \@args_copy,
        map { @$_ } @getopt_specs
    );

    # Verify all required arguments were collected
    if ($result) {
        foreach my $opt_name (keys %$specs) {
            my $spec = $specs->{$opt_name};
            my $dest = $spec->{dest} || $opt_name;
            $dest =~ s/^-+//;

            if (exists $spec->{required} && $spec->{required} && !exists $options{$dest}) {
                warn "Missing required option: $opt_name";
                $result = 0;
                last;
            }

            if (exists $spec->{nargs} && $spec->{nargs} > 1) {
                if (!exists $options{$dest} || ref $options{$dest} ne 'ARRAY' ||
                    @{$options{$dest}} != $spec->{nargs}) {
                    warn "Incorrect number of arguments for $opt_name (expected $spec->{nargs})";
                    $result = 0;
                    last;
                }
            }
        }
    }

    # Handle help by returning it in options
    if ($options{help}) {
        $options{_help_text} = _get_help_text(\%var_mapping);
    }

    return ($result, \%options, \@args_copy);
}

sub _get_help_text {
    my ($var_mapping) = @_;

    my $output = "Usage:\n";
    foreach my $opt (sort keys %$var_mapping) {
        my $spec = $var_mapping->{$opt};
        my $opt_display = length($opt) > 1 ? "--$opt" : "-$opt";

        if (ref $spec->{metavars} eq 'ARRAY' && @{$spec->{metavars}}) {
            $opt_display .= ' ' . join(' ', @{$spec->{metavars}});
        }

        $output .= sprintf "  %-20s %s\n", $opt_display, $spec->{help};
    }

    return $output;
}

1;

__END__

=head1 NAME

Getopt::Long::Extended - Python-style argument parsing for Getopt::Long

=head1 SYNOPSIS

  use Getopt::Long::Extended qw(extended_get_options);

  my $specs = {
      'copy' => {
          nargs => 3,
          metavar => ['SRC_BUCKET', 'SRC_KEY', 'DEST_KEY'],
          help => 'Copy operation',
      },
  };

  my ($result, $options) = extended_get_options(\@ARGV, $specs);

=head1 DESCRIPTION

This module extends Getopt::Long to support Python-style argument definitions
with fixed numbers of arguments (nargs) and metavars.

=head1 SEE ALSO

L<Getopt::Long>, L<Getopt::ArgParse>

=head1 LICENSE

This is released under the same terms as Perl itself.

=head1 AUTHOR

Mohammad Sajid Anwar <mohammad.anwar@yahoo.com>
