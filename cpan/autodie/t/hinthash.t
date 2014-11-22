#!/usr/bin/perl -w

use strict;
use warnings;

use FindBin;
use lib "$FindBin::Bin/lib";

use Test::More;

{
    use autodie;
    BEGIN {
        ok $^H{"autodie/open"}, "use autodie";
    }
}

{
    no autodie;
    BEGIN {
        ok !$^H{"autodie/open"}, "no autodie";
    }
}

{
    use autodie qw(chmod);
    BEGIN {
        ok $^H{"autodie/chmod"}, "selected function has autodie";
        ok !$^H{"autodie/open"}, "  others do not";
    }
}

{
    use autodie;
    BEGIN { ok $^H{"autodie/open"} }
    {
        no autodie;
        BEGIN {
            ok !$^H{"autodie/open"}, "no autodie nested in use autodie";
        }
    }
}

done_testing;
