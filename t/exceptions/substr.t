#!./perl -w

BEGIN {
    chdir 't' if -d 't';
    @INC = '../lib';
    require './test.pl';
}

note "without exceptions"; {
    my $string = 'foo';
    
    ok !eval { substr $string, 9, 4, "bar" };
    ok !ref $@;
}

note "with exceptions"; {
    my $string = 'foo';

    exception_ok {
        use feature 'exceptions';
#line 22 foo.bar
        substr $string, 9, 4, "bar";
        return;
    } {
        args            => ['foo', 9, 4, 'bar'],
        subroutine      => 'CORE::substr',
        file            => 'foo.bar',
        line            => 22,
        package         => __PACKAGE__,
        context         => 'void',
        error           => 'substr outside of string'
    }
}
