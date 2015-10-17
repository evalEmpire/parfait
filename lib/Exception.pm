package Exception;

use v5.22;
use strict;
use warnings;
use Carp 'croak';

our $VERSION = '0.01';

use overload
  q[""]         => \&as_string,
  fallback      => 1;

=head1 NAME

Exception - The basic exception object

=head1 SYNOPSIS

    use Exception;

    my $exception = Exception->new(%args);

    say $exception;  # stringification

=head1 DESCRIPTION

This is the basic exception object for core exceptions.

It can also be used by other modules.

=head1 METHODS

=head2 Constructors

=head3 new

    my $exception = Exception->new(\%args);

Create a new exception object.  C<%args> is any L<attribute|/Attributes> below.

Most attributes do not have defaults, the caller is responsible for setting them.

=cut

my %Attributes = map { $_ => 1 } qw(
    args
    subroutine
    file
    line
    package
    context
    errno
    message
);

sub new {
    my($class, $args) = @_;
    my $self = bless {}, $class;

    for my $key (keys %$args) {
        croak "Unknown attribute '$key'" unless $Attributes{$key};
        $self->{$key} = $args->{$key};
    }

    # A handful of easy defaults
    $self->{args}       //= [];
    $self->{errno}      //= $!;
    
    return $self;
}

=head2 Attributes

=head3 args

    my $args = $error->args;

Provides a reference to the arguments passed to the subroutine that
threw the exception.

If the error did not come from inside a subroutine, C<$args> will be
an empty array ref.

Defaults to an empty array ref.

=cut

sub args {
    return $_[0]->{args};
}

=head3 subroutine

    my $fully_qualified_name = $error->subroutine;

The fully qualified name of the subroutine that threw the exception.

=cut

sub subroutine {
    return $_[0]->{subroutine};
}

=head3 file

    my $file = $error->file;

The file in which the error occurred.

=cut

sub file {
    return $_[0]->{file};
}

=head3 line

    my $line = $error->line;

The line in C<< $error->file >> where the exceptional code was called.

=cut

sub line {
    return $_[0]->{line};
}

=head3 package

    my $package = $error->package;

The package from which the exceptional subroutine was called.

=cut

sub package     { return $_[0]->{package}; }

=head3 context

    my $context = $error->context;

The context in which the subroutine was called by autodie; usually
the same as the context in which you called the autodying subroutine.
This can be 'list', 'scalar', or 'void'.

For some core functions that always return a scalar value regardless
of their context (eg, C<chown>), this may be 'scalar', even if you
used a list context.

=cut

sub context {
    return $_[0]->{context}
}

=head3 errno

    my $errno = $error->errno;

The value of C<$!> at the time when the exception occurred.

Defaults to C<$!>.

=cut

sub errno {
    return $_[0]->{errno};
}

=head3 message

    my $message = $error->message;

The text of the error message.

This will not include the "at X line Y" context information.

=cut

sub message {
    return $_[0]->{message} //= $_[0]->_build_message;
}

sub _build_message {
    my $self = shift;

    my $sub = $self->subroutine;
    $sub =~ s/^CORE:://;

    return sprintf "Can't %s(%s): %s",
      $sub,
      $self->_formatted_arg_list,
      $self->errno;
}

sub _formatted_arg_list {
    my $self = shift;

    return join ", ", map { $self->_format_arg($_) } @{$self->args};
}

sub _format_arg {
    my $self = shift;
    my $arg  = shift;

    return 'undef'      if not defined($arg);

    # Leave references and globs unquoted to make it clear they're references.
    return $arg         if ref $arg || ref \$arg eq 'GLOB';

    # It's a string, quote it.
    $arg =~ s{'}{\\'}g;
    return qq{'$arg'}
}

=head2 Methods

=head3 as_string

    my $string = $error->as_string;

This will produce a human readable message with context, the familiar "error at X line Y.\n".

=cut

sub as_string { return $_[0]->{as_string} //= $_[0]->_build_as_string }

sub _build_as_string {
    my $self = shift;

    return sprintf "%s at %s line %d.\n",
      $self->message,
      $self->file,
      $self->line;
}

=head2 Stringification

If used as a string, L</as_string> will be called.

=cut

1;
