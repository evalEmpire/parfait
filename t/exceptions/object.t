#!./perl

BEGIN {
    chdir 't' if -d 't';
    @INC = '../lib';
    require './test.pl';
}

require_ok 'Exception';

note "Bad arguments"; {
    ok !eval {
        Exception->new({ foo => "bar" });
    };
    like $@, qr{^Unknown attribute 'foo'};
}

note "Default arguments"; {
    local $! = 1;
    my $errno_as_string = "$!";
    
    my $exception = Exception->new();

    is @{$exception->args},     0;
    is $exception->errno,       $!;
    is $exception->error,       $!;
}

note 'Preserve $! and $@'; {
    local $! = 1;
    my $errno_as_string = "$!";
    local $@ = "error";

    my $exception = Exception->new();

    is $!, $errno_as_string;
    is $@, "error";
}

note 'message from error'; {
    my $exception = Exception->new({
        file            => 'foo.pl',
        line            => 1234,
        error           => 'Mouse out of cheese',
        args            => [123, "foo"],
        subroutine      => 'Some::thing',
    });

    is $exception->message, qq[Can't Some::thing('123', 'foo'): Mouse out of cheese];
}

note 'Stringification'; {
    my $exception = Exception->new({
        file    => 'foo.pl',
        line    => 1234,
        message => 'This is a test',
    });

    is $exception->message, "This is a test", "message does not include the context";
    is $exception->as_string, "This is a test at foo.pl line 1234.\n";
    is "$exception", $exception->as_string, "stringification";
}

done_testing;
