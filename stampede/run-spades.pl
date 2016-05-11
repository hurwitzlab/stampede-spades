#!/usr/bin/env perl

use strict;
use warnings;
use feature 'say';
use autodie;
use Cwd 'cwd';
use Data::Dump 'dump';
use FindBin '$Bin';
use File::Basename 'basename';
use File::Spec::Functions qw'catdir catfile';
use File::Path 'remove_tree';
use File::Find::Rule;
use Getopt::Long;
use Pod::Usage;
use Readonly;
use Text::RecordParser::Tab;

my $DEBUG = 0;

main();

# --------------------------------------------------
sub main {
    my %args = get_args();

    if ($args{'help'} || $args{'man_page'}) {
        pod2usage({
            -exitval => 0,
            -verbose => $args{'man_page'} ? 2 : 1
        });
    }; 

    debug("args = ", dump(\%args));
    my $in_dir  = $args{'dir'}     or pod2usage('No input --dir');
    my $out_dir = $args{'out-dir'} or pod2usage('No --out-dir');
    my $spades  = $args{'spades'}  or pod2usage('No --spades');

    unless (-s $spades) {
        pod2usage("Cannot find binary ($spades)");
    }

    my @files;
    if (-f $in_dir) {
        debug("Directory arg '$in_dir' is actually a file");
        push @files, $in_dir;
    }
    else {
        debug("Looking for files in '$in_dir'");
        @files = File::Find::Rule->file()->in($in_dir);
    }

    printf "Found %s files\n", scalar(@files);

    if (@files < 1) {
        pod2usage('No input data');
    }

    my %file_type;
    my $file_desc = $args{'file-desc'} || '';
    if ($file_desc && -s $file_desc) {
        my $p = Text::RecordParser::Tab->new($file_desc);
        while (my $r = $p->fetchrow_hashref) {
            my $fname = $r->{'filename'} or next;
            my $type  = $r->{'type'}     or next;
            $file_type{ $fname } = $type;
        }
    }

    my @inputs;
    for my $file (@files) {
        my $basename = basename($file);
        my $type     = $file_type{ $basename } || '-s';
        push @inputs, "$type $file";
    }   

    unless (@inputs) {
        pod2usage("Found no usable inputs");
    } 

    debug("inputs =", dump(\@inputs));

    my @options;
    for my $opt (qw[cov-cutoff phred-offset k]) {
        if (my $val = $args{ $opt }) {
            my $dashes = length($opt) == 1 ? '-' : '--';
            push @options, sprintf "%s%s %s", $dashes, $opt, $val;
        }
    }

    execute(join(' ',
        $spades,
        '--only-assembler',
        @options,
        '-o', $out_dir, 
        @inputs
    ));

    printf("Finished, see results in '%s'\n", $out_dir);
}

# --------------------------------------------------
sub debug {
    say @_ if $DEBUG;
}

# --------------------------------------------------
sub execute {
    my @cmd = @_ or return;
    debug("\n\n>>>>>>\n\n", join(' ', @cmd), "\n\n<<<<<<\n\n");

    unless (system(@cmd) == 0) {
        die sprintf(
            "FATAL ERROR! Could not execute command:\n%s\n",
            join(' ', @cmd)
        );
    }
}

# --------------------------------------------------
sub get_args {
    my %args = (
        'dir'          => '',
        'debug'        => 0,
        'sc'           => 0,
        'meta'         => 0,
        'iontorrent'   => 0,
        'cov-cutoff'   => '',
        'phred-offset' => 0,
        'k'            => '',
        'file-desc'    => '',
        'out-dir'      => catdir(cwd(), 'spades-out'),
        'spades'       => catfile($Bin, 'bin', 'spades.py'),
    );

    GetOptions(
        \%args,
        'dir|d=s',
        'out-dir|o=s',
        'sc',
        'meta',
        'iontorrent',
        'k:s',
        'cov-cutoff|c:s',
        'phred-offset|p:s',
        'spades|s:s',
        'file-desc|f:s',
        'debug',
        'help',
        'man',
    ) or pod2usage(2);

    $DEBUG = $args{'debug'};

    if (-d $args{'out-dir'}) {
        remove_tree($args{'out-dir'});
    }

    return %args;
}

__END__

# --------------------------------------------------

=pod

=head1 NAME

run-spades.pl - runs spades

=head1 SYNOPSIS

  run-spades.pl -d /path/to/data

Required Arguments:

  -d|--dir   Input directory

Options (defaults in parentheses):

  --sc              This flag is required for MDA (single-cell) data
  --meta            This flag is required for metagenomic sample data
  --iontorrent      This flag is required for IonTorrent data
  -k                Comma-separated list of k-mer sizes; must be odd 
                    and less than 128 (auto)
  -c|cov-cutoff     Coverage cutoff value, a positive float number, 
                    or 'auto', or 'off' (off)
  -p|--phred-offset PHRED quality offset in the input reads [33 or 64]

  -f|--file-desc    Tab-delimited file of file (basename) and library
  -o|--out-dir      Output dir (cwd) 
  -s|--spades       Path to "spades.py"
  --help            Show brief help and exit
  --man             Show full documentation

=head1 DESCRIPTION

Runs SPAdes.

=head1 SEE ALSO

SPAdes.

=head1 AUTHOR

Ken Youens-Clark E<lt>kyclark@email.arizona.eduE<gt>.

=head1 COPYRIGHT

Copyright (c) 2016 Ken Youens-Clark

This module is free software; you can redistribute it and/or
modify it under the terms of the GPL (either version 1, or at
your option, any later version) or the Artistic License 2.0.
Refer to LICENSE for the full license text and to DISCLAIMER for
additional warranty disclaimers.

=cut
