#!/usr/bin/perl -w

use strict;
use Test::More;

require_ok 'autodie::exception';

note "new() with all arguments"; {
    my %args = (
        args            => [qw(foo bar)],
        function        => "Test::Something",
        file            => "whatever",
        line            => 23,
        package         => "other",
        # specifically undef to check autodie::exception doesn't try to
        # replace undefs with defaults
        caller          => undef,
        context         => 'void',
        return          => 42,
        errno           => "Oh god, the burning",
        eval_error      => "Why is everything on fire?"
    );
    
    my $obj = autodie::exception->new(%args);
    for my $key (keys %args) {
        is $obj->$key, $args{$key}, $key;
    }
}

done_testing;
