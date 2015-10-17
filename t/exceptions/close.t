#!./perl -w

BEGIN {
    chdir 't' if -d 't';
    @INC = '../lib';
    require './test.pl';
}

use Symbol;

note "without exceptions"; {
    open my $fh, '<', __FILE__;
    close $fh;
    ok !close $fh;
    pass "Did not die";
    ok $!;
}

note "basic close failure"; {
    exception_ok {
        use feature 'exceptions';
        open my $fh, '<', __FILE__;
        close $fh;
#line 24 foo.bar
        close $fh;
        1;
    } {
        args            => ['*main::$fh'],
        subroutine      => 'CORE::close',
        file            => 'foo.bar',
        line            => 24,
        package         => __PACKAGE__,
        context         => 'void',
        message         => sub { qq[Can't close(*main::\$fh): @{[ $_[0]->errno ]}] },
    }
}

done_testing;
