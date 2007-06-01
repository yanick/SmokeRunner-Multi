package SmokeRunner::Multi::Config;

use strict;
use warnings;

use base 'Class::Singleton';

use File::Spec;
use YAML::Syck qw( LoadFile );


sub _new_instance {
    my $class = shift;

    my $file = $class->_FindConfigFile();

    my $cfg = LoadFile($file);

    die "Config in $file for the smoke-runner was not valid.\n"
        unless $cfg
        && $cfg->{root};

    return bless $cfg, $class;
}

sub _FindConfigFile {
    my $class = shift;


    my @files;

    push @files, $ENV{SMOKERUNNER_CONFIG}
        if $ENV{SMOKERUNNER_CONFIG};

    my $home_dir = (getpwuid( $> ) )[7];
    push @files,File::Spec->catfile( $home_dir ,'.smokerunner', 'smokerunner.conf' )
        if $home_dir && -d $home_dir;

    push @files, '/etc/smokerunner/smokerunner.conf';

    for my $file (@files) {
        return $file if -f $file && -r _;
    }

    die "Cannot find a config file for the smoke-runner. Looked in [@files].\n";
}

sub root_dir { return $_[0]->{root} }
sub runner   { return $_[0]->{runner} }
sub reporter { return $_[0]->{reporter} }
sub smolder  { return $_[0]->{smolder} || {} }


1;

__END__

=head1 NAME

SmokeRunner::Multi::Config - Config information for a Smokerunner::Multi setup

=head1 SYNOPSIS

  use SmokeRunner::Multi::Config;

  my $config = SmokeRunner::Multi::Config->instance();

  print $config->root_dir();

=head1 DESCRIPTION

This class reads the config file for C<SmokeRunner::Multi>, and
provides access to the data in it. It is a singleton, so the config
will only be read when the object is first created.

=head1 METHODS

This class provides the following methods:

=head2 SmokeRunner::Multi::Config->instance()

Returns the instance of the config object. The first time this is
called, it will read the config file.

The config file should be in YAML format.

=head3 Finding the config file

This class will look for the config file in several locations.

First, if the C<SMOKERUNNER_CONFIG> variable is set, it checks this
location.

Next, if the the current user has a home directory, it will look in
F<[home]/.smokerunner/smokerunner.conf>. Finally it looks in
F</etc/smokerunner/smokerunner.conf>.

If it cannot find a file it will die.

=head2 $config->root_dir()

The root directory for the smokerunner. This should contain the test
sets, and it will be used for storing data on the filesystem, so it
needs to be writeable by the smoke runner process.

=head2 $config->runner()

The C<SmokeRunner::Multi::Runner> subclass to use. This can be a full
class name, or just the unique part of the subclass ("Prove" or
"TAPModel").

=head2 $config->reporter()

The C<SmokeRunner::Multi::Reporter> subclass to use. This can be a
full class name, or just the unique part of the subclass ("Smolder").

=head2 $config->smolder()

Returns a hash reference of Smolder configuration data.

=head1 CONFIGURATION

The configuration file is expected to be in YAML. There are three
required config keys:

=over 4

=item * root

The root directory for you test sets.

=item * runner

The class used to run tests. This can be either a full class name
(C<SmokeRunner::Multi::Runner::Prove>), or just a short name of a
Runner class (C<Prove>).

=item * reporter

The class used to run tests. This can be either a full class name
(C<SmokeRunner::Multi::Reporter::Prove>), or just a short name of a
Reporter class (C<Smolder>).

=back

=head1 TODO

This class doesn't lend itself well to supporting config info for new
types of runner or reporter classes. That should be fixed ;)

=head1 AUTHOR

Dave Rolsky, <autarch@urth.org>

=head1 BUGS

Please report any bugs or feature requests to
C<bug-smokerunner-multi@rt.cpan.org>, or through the web interface at
L<http://rt.cpan.org>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.

=head1 COPYRIGHT & LICENSE

Copyright 2007 LiveText, Inc., All Rights Reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

The full text of the license can be found in the LICENSE file included
with this module.

=cut
