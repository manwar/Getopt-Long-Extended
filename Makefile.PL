#!/usr/bin/perl

use v5.14;
use strict;
use warnings FATAL => 'all';
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME               => 'Getopt::Long::Extended',
    AUTHOR             => q{Mohammad Sajid Anwar <mohammad.anwar@yahoo.com>},
    VERSION_FROM       => 'lib/Getopt/Long/Extended.pm',
    ABSTRACT_FROM      => 'lib/Getopt/Long/Extended.pm',
    LICENSE            => 'artistic_2',
    MIN_PERL_VERSION   => 5.014,
    CONFIGURE_REQUIRES => {
        'ExtUtils::MakeMaker' => 0,
    },
    BUILD_REQUIRES => {
        'Test::More'      => 0,
        'Test::Exception' => 0,
    },
    PREREQ_PM => {
        'Getopt::Long' => 0,
    },
    dist  => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean => { FILES => 'Getopt-Long-Extended-*' },
    (eval { ExtUtils::MakeMaker->VERSION(6.46) } ? (META_MERGE => {
        'meta-spec' => { version => 2 },
        provides    => {
            'Getopt::Long::Extended' => { file => 'lib/Getopt/Long/Extended.pm', version => '0.01' },
        },
        resources => {
            repository => {
                type => 'git',
                url  => 'https://github.com/manwar/Getopt-Long-Extended.git',
                web  => 'https://github.com/manwar/Getopt-Long-Extended',
            },
        }})
     : ()
    ),
);
