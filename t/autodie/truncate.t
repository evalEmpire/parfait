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
    eval {
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
    TODO: {
        local $TODO = 'caller is not set inside the op';
        is          $err->caller,   undef;
    }
    is          $err->line,     19;
    is          $err->context,  "void";
    is          $err->return,   undef;
    is          $err->errno,    $errno;
    is          $err->eval_error, "this is the error before truncate";
}

done_testing;
