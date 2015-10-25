#!./perl -w

BEGIN {
    chdir 't' if -d 't';
    @INC = '../lib';
    require './test.pl';
}

note "without exceptions"; {
    ok !open my $fh, "i-do-not-exist";
    pass "Did not die";
    ok $!;
}

note "file not found exception"; {
    exception_ok {
        use feature 'exceptions';
#line 18 foo.bar
        open my $fh, "i-do-not-exist";
        return;
    } {
        args            => ['*main::$fh', 'i-do-not-exist'],
        subroutine      => 'CORE::open',
        file            => 'foo.bar',
        line            => 18,
        package         => __PACKAGE__,
        context         => 'void',
        message         => sub { qq[Can't open(*main::\$fh, 'i-do-not-exist'): @{[ $_[0]->errno ]}] },
    }
}

note "piped open: program doesn't exist"; {
    exception_ok {
        use feature 'exceptions';
#line 18 foo.bar
        open my $fh, "-|", "i-do-not-exist";
        return;
    } {
        args            => ['*main::$fh', '-|', 'i-do-not-exist'],
        subroutine      => 'CORE::open',
        file            => 'foo.bar',
        line            => 18,
        package         => __PACKAGE__,
        context         => 'void',
        message         => sub { qq[Can't open(*main::\$fh, '-|', 'i-do-not-exist'): @{[ $_[0]->errno ]}] },
    }
}

note "invalid separator"; {
    skip_without_perlio;

    exception_ok {
        use feature 'exceptions';
#line 18 foo.bar
        open my $fh, ">>>", "i-do-not-exist";
        return;
    } {
        args            => ['*main::$fh', '>>>', 'i-do-not-exist'],
        subroutine      => 'CORE::open',
        file            => 'foo.bar',
        line            => 18,
        package         => __PACKAGE__,
        context         => 'void',
        warnings        => [qq[Invalid separator character '>' in PerlIO layer specification > at foo.bar line 18.\n]],
        error           => q[Unknown open() mode '>>>'],
        message         => qq[Can't open(*main::\$fh, '>>>', 'i-do-not-exist'): Unknown open() mode '>>>']
    }
}

done_testing;
