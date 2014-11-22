#!./perl -w

BEGIN {
    chdir 't' if -d 't';
    @INC = '../lib';
    require './test.pl';
}

my @Internal_to_perl = qw(
    truncate
);

note "Check that autodie functions implemented in Perl do not have autodie wrappers"; {
    use autodie;

    for my $func (@Internal_to_perl) {
        ok !defined $::{$func}, $func;
    }
}

done_testing;
