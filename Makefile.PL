use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME          => 'Getopt::Long::Extended',
    VERSION_FROM  => 'lib/Getopt/Long/Extended.pm',
    PREREQ_PM     => {
        'Getopt::Long' => 0,
        'Exporter'     => 0,
        'Test::More'   => 0,
    },
    ABSTRACT_FROM => 'lib/Getopt/Long/Extended.pm',
    AUTHOR        => 'Mohammad Sajid Anwar',
    LICENSE       => 'perl',
);
