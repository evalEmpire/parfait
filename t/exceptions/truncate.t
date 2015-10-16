#!./perl -w

BEGIN {
    chdir 't' if -d 't';
    @INC = '../lib';
    require './test.pl';
}

note "without exceptions"; {
    ok !truncate("i-do-not-exist", 0);
    pass("Did not die");
    ok $!;
}

note "with exceptions"; {
    exception_ok {
        package Foo;
        use feature 'exceptions';

        local $SIG{__WARN__} = sub { push @warnings, @_ };
#line 19 something_else.foo
        truncate("i-do-not-exist", 0);
    } {
        args            => ["i-do-not-exist", 0],
        subroutine      => "CORE::truncate",
        file            => "something_else.foo",
        line            => 19,
        package         => "Foo",
        context         => "scalar",
        message         => sub { qq[Can't truncate('i-do-not-exist', '0'): @{[ $_[0]->errno ]}] },
    };
}

note "with exceptions in a subroutine"; {
    exception_ok {
        {
            package Foo;
            use feature 'exceptions';
            sub try_truncate {
#line 45 something_else.foo
                truncate("i-do-not-exist", 23);
            }
        }
        Foo::try_truncate();
    } {
        args            => ["i-do-not-exist", 23],
        subroutine      => "CORE::truncate",
        file            => "something_else.foo",
        line            => 45,
        package         => "Foo",
        context         => "scalar",
        message         => sub { qq[Can't truncate('i-do-not-exist', '23'): ].$_[0]->errno },
    };
}

# Check that we don't panic if there's no caller information.
fresh_perl_like
    q[use feature 'exceptions'; truncate("i-do-not-exist", 0);],
    qr{^Can't truncate\('i-do-not-exist', '0'\):};

# Check that we don't panic in a subroutine but outside an eval.
fresh_perl_like
    q[use feature 'exceptions'; sub foo { truncate("i-do-not-exist", 0); } foo();],
    qr{^Can't truncate\('i-do-not-exist', '0'\):};

done_testing;
