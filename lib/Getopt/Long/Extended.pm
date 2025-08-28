package Getopt::Long::Extended;

use strict;
use warnings;
use Carp;
use Getopt::Long;
use Exporter qw(import);
use List::Util qw(first);

our $VERSION = '0.01';

our @remaining_args = ();

our @EXPORT = qw(extended_get_options remaining_arguments generate_help_text);

=head1 NAME

Getopt::Long::Extended - A declarative and extensible Getopt::Long wrapper

=head1 VERSION

Version 0.01

=head1 SYNOPSIS

    use Getopt::Long::Extended qw(extended_get_options);

    my $specs = {
        'verbose' => {
            action => 'store_true',
            help   => 'Enable verbose output'
        },
        'file' => {
            nargs    => 1,
            required => 1,
            help     => 'Path to the input file'
        },
        'log-level' => {
            metavar => 'LEVEL',
            help    => 'Set the logging level (debug, info, warn, error)'
        },
    };

    my ($success, $options, $remaining) = extended_get_options(\@ARGV, $specs);

    if ($options->{_help_text}) {
        print $options->{_help_text};
        exit;
    }

    unless ($success) {
        print "Try 'program.pl --help'\n";
        exit 1;
    }

    if ($options->{verbose}) {
        print "Verbose mode enabled.\n";
    }

    print "Input file: " . $options->{file} . "\n";
    print "Remaining arguments: @$remaining\n";


=head1 DESCRIPTION

Getopt::Long::Extended is a wrapper around L<Getopt::Long> that provides a more
declarative, Python-style interface for defining command-line options. It simplifies
the process of creating command-line applications by allowing you to define your
options in a data structure (a hash reference) rather than through a series of
complex variable bindings.

This module provides an extensible framework for defining options, handling help
text, and performing custom validation, while still leveraging the powerful parsing
engine of Getopt::Long.

=head1 FUNCTIONS

=head2 extended_get_options(\@arguments, \%specs)

The primary function of the module. It parses command-line arguments based on
a declarative specification.

=over 4

=item * B<@arguments>

A reference to an array of command-line arguments, typically C<\@ARGV>.

This array will be modified in place to contain only the remaining (non-option) arguments.

=item * B<%specs>

A hash reference where each key is an option name (e.g., C<"verbose">) and each value is
another hash reference containing the option's properties.

=back

=head2 Return Value

Returns a three-element list:

=over 4

=item * B<success>

A boolean value (1 or 0) indicating whether parsing was successful and all validation
checks passed.

=item * B<options>

A hash reference containing the parsed options. Option names are keys, and their
values are the parsed arguments. A special key C<_help_text> is populated if C<--help> is passed.

=item * B<remaining>

A reference to an array of arguments that were not recognized as options.

=back

=cut

sub extended_get_options {
    my ($args_ref, $specs_ref) = @_;

    croak "extended_get_options requires a list of arguments as the first parameter."
        unless defined $args_ref && ref($args_ref) eq 'ARRAY';
    croak "extended_get_options requires a hash reference of options as the second parameter."
        unless defined $specs_ref && ref($specs_ref) eq 'HASH';

    my %opt_vars;
    my %option_spec;
    my %options = ();

    if (first { $_ eq '--help' } @$args_ref) {
        return (1, { _help_text => generate_help_text($specs_ref) }, []);
    }

    for my $name (keys %$specs_ref) {
        my $spec_details = $specs_ref->{$name};
        if (exists $spec_details->{action}) {
            if ($spec_details->{action} eq 'store_true') {
                $options{$name} = 0;
            } elsif ($spec_details->{action} eq 'store_false') {
                $options{$name} = 1;
            }
        }
    }

    for my $name (keys %$specs_ref) {
        my $spec_details = $specs_ref->{$name};
        my $getopt_spec = $name;

        if (exists $spec_details->{nargs}) {
            my $nargs = $spec_details->{nargs};
            if ($nargs > 1) {
                $getopt_spec .= "=s{".$nargs."}";
                $opt_vars{$name} = [];
            } elsif ($nargs == 0) {
                # This case is handled by `action`
            } else {
                $getopt_spec .= '=s';
                $opt_vars{$name} = \my $var;
            }
        } elsif (exists $spec_details->{action}) {
            if ($spec_details->{action} eq 'store_true') {
                $getopt_spec .= '!';
                $opt_vars{$name} = \my $var;
            } elsif ($spec_details->{action} eq 'store_false') {
                $option_spec{$getopt_spec} = sub { $options{$name} = 0 };
                next; # Skip to the next iteration after setting the handler
            }
        } else {
            # Default to a single string argument
            $getopt_spec .= '=s';
            $opt_vars{$name} = \my $var;
        }

        # The key for Getopt::Long needs to be the spec string.
        # The value is the variable reference.
        $option_spec{$getopt_spec} = $opt_vars{$name};
    }

    my @user_args = @$args_ref;

    # Check for options with insufficient arguments and issue a custom warning
    my $found_insufficient_args = 0;
    foreach my $arg (@user_args) {
        if ($arg =~ /^--(\w+)/) {
            my $option_name = $1;
            if (exists $specs_ref->{$option_name} && exists $specs_ref->{$option_name}->{nargs}) {
                my $nargs = $specs_ref->{$option_name}->{nargs};
                if ($nargs > 0) {
                    # Find the index of the option in the argument list
                    my ($arg_index) = first { $user_args[$_] eq $arg } 0 .. $#user_args;
                    my $remaining_count = @user_args - ($arg_index + 1);
                    if ($remaining_count < $nargs) {
                        warn "Incorrect number of arguments for $option_name (expected $nargs)";
                        $found_insufficient_args = 1;
                        last;
                    }
                }
            }
        }
    }

    if ($found_insufficient_args) {
        return (0, {}, \@user_args);
    }

    Getopt::Long::Configure("no_auto_abbrev", "no_ignore_case", "pass_through");

    my $success = Getopt::Long::GetOptionsFromArray(
        \@user_args,
        %option_spec,
    );

    @remaining_args = @user_args;

    for my $name (keys %$specs_ref) {
        my $spec_details = $specs_ref->{$name};
        if (exists $spec_details->{nargs} && $spec_details->{nargs} > 1) {
            $options{$name} = $opt_vars{$name};
        } elsif (exists $opt_vars{$name}) {
            $options{$name} = ${$opt_vars{$name}} if defined ${$opt_vars{$name}};
        }
    }

    my $valid = $success;

    # Check for missing required options first.
    for my $name (keys %$specs_ref) {
        my $spec_details = $specs_ref->{$name};
        my $value = $options{$name};

        if (exists $spec_details->{required} && $spec_details->{required}) {
            if (!defined $value || (ref($value) eq 'ARRAY' && @$value == 0)) {
                warn "Missing required option: $name";
                $valid = 0;
            }
        }
    }

    return ($valid, \%options, \@remaining_args);
}

=head2 generate_help_text(\%specs)

Generates and returns a formatted help message based on the provided specifications hash.

This is the subroutine used internally when a C<--help> argument is detected, but it can
also be called directly to generate help text for other purposes.

=head1 OPTION SPECIFICATIONS

The specification hash for each option can contain the following keys:

=over 4

=item * B<nargs>

(Optional) Defines the number of arguments the option expects.
If C<1>, it takes a single value (default).
If C<0>, it behaves as a boolean flag (equivalent to C<store_true>).
If C<2> or more, it takes multiple arguments as an array.

=item * B<action>

(Optional) A special action to perform when the option is present.
C<store_true>: The option value is set to 1 if present, 0 otherwise.
C<store_false>: The option value is set to 0 if present, 1 otherwise.

=item * B<required>

(Optional) A boolean. If set to a true value, an error will be issued if
the option is not present on the command line.

=item * B<help>

(Optional) A string providing a short description of the option. This text is
used by C<generate_help_text>.

=item * B<metavar>

(Optional) A string or array reference of strings that describe the arguments in the help text.

=back

=cut

sub generate_help_text {
    my ($specs_ref) = @_;
    my $help_text = "Usage:\n";

    for my $name (sort keys %$specs_ref) {
        my $spec = $specs_ref->{$name};
        my $metavar = exists $spec->{metavar} && ref($spec->{metavar}) eq 'ARRAY' && @{$spec->{metavar}} > 0 ? $spec->{metavar}[0] : uc($name);
        my $description = exists $spec->{help} ? $spec->{help} : '';

        my $opt_display = length($name) > 1 ? "--$name" : "-$name";

        if (exists $spec->{nargs} && $spec->{nargs} > 0) {
            $opt_display .= " <$metavar>";
        }

        $help_text .= sprintf "  %-20s %s\n", $opt_display, $description;
    }

    return $help_text;
}

=head2 remaining_arguments()

This function returns the array of arguments that were not recognized as options
by the last call to C<extended_get_options>. This is a convenience function that
provides access to the same data returned as the third element of the list from C<extended_get_options>.

=cut

sub remaining_arguments {
    return @remaining_args;
}

# This function is not used in the purely functional approach.
sub _add_option {
    warn "add_option is not supported in the functional API.";
    return 0;
}

=head1 AUTHOR

Mohammad Sajid Anwar C<< <mohammad.anwar@yahoo.com >>

=head1 LICENSE AND COPYRIGHT

Copyright (C) 2025 Mohammad Sajid Anwar.

This program  is  free software; you can redistribute it and / or modify it under
the  terms  of the the Artistic License (2.0). You may obtain a  copy of the full
license at:

L<http://www.perlfoundation.org/artistic_license_2_0>

Any  use,  modification, and distribution of the Standard or Modified Versions is
governed by this Artistic License.By using, modifying or distributing the Package,
you accept this license. Do not use, modify, or distribute the Package, if you do
not accept this license.

If your Modified Version has been derived from a Modified Version made by someone
other than you,you are nevertheless required to ensure that your Modified Version
 complies with the requirements of this license.

This  license  does  not grant you the right to use any trademark,  service mark,
tradename, or logo of the Copyright Holder.

This license includes the non-exclusive, worldwide, free-of-charge patent license
to make,  have made, use,  offer to sell, sell, import and otherwise transfer the
Package with respect to any patent claims licensable by the Copyright Holder that
are  necessarily  infringed  by  the  Package. If you institute patent litigation
(including  a  cross-claim  or  counterclaim) against any party alleging that the
Package constitutes direct or contributory patent infringement,then this Artistic
License to you shall terminate on the date that such litigation is filed.

Disclaimer  of  Warranty:  THE  PACKAGE  IS  PROVIDED BY THE COPYRIGHT HOLDER AND
CONTRIBUTORS  "AS IS'  AND WITHOUT ANY EXPRESS OR IMPLIED WARRANTIES. THE IMPLIED
WARRANTIES    OF   MERCHANTABILITY,   FITNESS   FOR   A   PARTICULAR  PURPOSE, OR
NON-INFRINGEMENT ARE DISCLAIMED TO THE EXTENT PERMITTED BY YOUR LOCAL LAW. UNLESS
REQUIRED BY LAW, NO COPYRIGHT HOLDER OR CONTRIBUTOR WILL BE LIABLE FOR ANY DIRECT,
INDIRECT, INCIDENTAL,  OR CONSEQUENTIAL DAMAGES ARISING IN ANY WAY OUT OF THE USE
OF THE PACKAGE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

=cut

1; # End of Getopt::Long::Extended
