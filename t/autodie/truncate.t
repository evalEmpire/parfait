#!./perl

BEGIN {
    chdir 't' if -d 't';
    @INC = '../lib';
    require './test.pl';
}

note "without autodie"; {
    ok !truncate("i-do-not-exist", 0);
    pass("Did not die");
    ok $!;
}

note "with autodie"; {
    ok !eval {
        package Foo;
        use autodie;

        local $@ = "this is the error before truncate";
#line 19 something_else.foo
        truncate("i-do-not-exist", 0);
    };
    my $err     = $@;
    my $errno   = $!;
    isa_ok      $err,           "autodie::exception";
    ok eq_array(  $err->args,     ["i-do-not-exist", 0] );
    is          $err->function, "CORE::truncate";
    is          $err->file,     "something_else.foo";
    is          $err->package,  "Foo";
    is          $err->caller,   '(eval)';
    is          $err->line,     19;
    is          $err->context,  "scalar";
    is          $err->return,   undef;
    is          $err->errno,    $errno;
    is          $err->eval_error, "this is the error before truncate";
}

note "with autodie in a subroutine"; {
    {
        package Foo;
        use autodie;
        sub try_truncate {
            local $@ = "this is another error before truncate";
#line 45 something_else.foo
            truncate("i-do-not-exist", 23);
        }
    }

    ok !eval { Foo::try_truncate() };

    my $err     = $@;
    my $errno   = $!;
    isa_ok      $err,           "autodie::exception";
    ok eq_array(  $err->args,     ["i-do-not-exist", 23] );
    is          $err->function, "CORE::truncate";
    is          $err->file,     "something_else.foo";
    is          $err->package,  "Foo";
    is          $err->caller,   'Foo::try_truncate';
    is          $err->line,     45;
    is          $err->context,  "scalar";
    is          $err->return,   undef;
    is          $err->errno,    $errno;
    is          $err->eval_error, "this is another error before truncate";
}

# Check that we don't panic if there's no caller information.
fresh_perl_like
    q[use autodie; truncate("i-do-not-exist", 0);],
    qr{^Can't truncate\('i-do-not-exist', '0'\):};

# Check that we don't panic in a subroutine but outside an eval.
fresh_perl_like
    q[use autodie; sub foo { truncate("i-do-not-exist", 0); } foo();],
    qr{^Can't truncate\('i-do-not-exist', '0'\):};

done_testing;
