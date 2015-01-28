#!./perl

BEGIN {
    chdir 't' if -d 't';
    @INC = '../lib';
    require './test.pl';
}

note "use feature 'exceptions'"; {
    BEGIN { ok !$^H{"feature_exceptions"}, "off at level 1" }
    {
        use feature "exceptions";
        BEGIN { ok $^H{"feature_exceptions"}, "turned on at level 2" }

        {
            BEGIN { ok $^H{"feature_exceptions"}, "survives lexical entry" }
            no feature "exceptions";
            BEGIN { ok !$^H{"feature_exceptions"}, "explicitly off at level 3" }
        }

        BEGIN { ok $^H{"feature_exceptions"}, "still on at level 2" }
    }
    BEGIN { ok !$^H{"feature_exceptions"}, "still off at level 1" }
}

done_testing;
