# Welcome to Piledriver

Piledriver is a backwards compatible fork of Perl 5. Its goals are...

* To be 100% backwards compatible.
* Make rapid advances to the language using good ideas from CPAN.
* To be welcoming to new developers.

Piledriver draws its inspiration from [perl5i](https://metacpan.org/pod/perl5i). Its major feature improvements will aim to bring good ideas from CPAN in as core features. This will probably include...

* Core functions that throw exceptions (similar to [autodie](https://metacpan.org/pod/autodie))
* [Moose](https://metacpan.org/pod/Moose)-style objects
* [Everything is an object](https://metacpan.org/pod/perl5i#Autoboxing)
* Better file handling (similar to [Path::Tiny](https://metacpan.org/pod/Path::Tiny))
* Better date handling (similar to [DateTime](https://metacpan.org/pod/DateTime))
* Better default behaviors, less gotchas
* Less global variables
* More built in data utilities, less CPAN modules to install

Piledriver also aims to expand who can and wants to work on the Perl 5 core language by...

* Having better documentation about how to contribute.
* Making it simpler to contribute.
* Reducing the complexity of the code.
* Using well-understood services and tools such as Github and Travis.
* Having a well behaved, principled community.
* Acknowleding the importance of non-code contributions.
* Reducing the risk of adding new features to the language.

Piledriver is 100% backwards compatible with Perl 5, you can safely run your existing Perl 5 code on Piledriver. Features will be turned on a block by block basis allowing even old, crufty projects to transition.

    # This is Perl 5
    open my $fh, "<", $file or die "Can't open $file for reading: $!";

    {
        # This is Piledriver (except this doesn't work yet)
        use piledriver v1;
        my $fh = $file->path->openr;
    }

We have our own [wiki](https://github.com/evalEmpire/piledriver/wiki) and [issue tracker](https://github.com/evalEmpire/piledriver/issues). Right now the focus is on [getting exceptions working](https://github.com/evalEmpire/piledriver/issues/17) as our first stable feature, but if you have an idea you'd like to see worked on, [let us know](https://github.com/evalEmpire/piledriver/issues/new)!

Currently the project is just getting started. There are no releases and no complete features.
