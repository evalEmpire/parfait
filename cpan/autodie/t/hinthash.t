#!/usr/bin/perl -w

use strict;
use warnings;

use FindBin;
use lib "$FindBin::Bin/lib";

use Test::More 'no_plan';

note "use autodie hint hash"; {
    use autodie;
    BEGIN {
        ok $^H{"autodie/open"};
    }
}

note "no autodie;"; {
    no autodie;
    BEGIN {
        ok !$^H{"autodie/open"};
    }
}

note "use autodie qw(function)"; {
    use autodie qw(chmod);
    BEGIN {
        ok $^H{"autodie/chmod"};
        ok !$^H{"autodie/open"};
    }
}
