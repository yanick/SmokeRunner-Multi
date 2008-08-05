package SmokeRunner::Multi::Reporter::Smolder;

use strict;
use warnings;

use base 'SmokeRunner::Multi::Reporter';

use File::Temp qw( tempdir );
use File::Which qw( which );
use SmokeRunner::Multi::SafeRun qw( safe_run );
use YAML::Syck qw( Dump );


my @SmolderKeys = qw( server username password );

sub new {
    my $class = shift;

    my $self = $class->SUPER::new(@_);

    my $smolder_config = SmokeRunner::Multi::Config->instance()->smolder();

    for my $k (@SmolderKeys) {
        die "No config item for smolder $k in config"
            unless $smolder_config->{$k};
    }

    die "Runner must be a TAPArchive runner"
        unless $self->runner()->isa('SmokeRunner::Multi::Runner::TAPArchive');

    $self->{smolder} = $smolder_config;

    return $self;
}

sub report {
    my $self = shift;

    my @params;
    for my $k (@SmolderKeys) {
        push @params, '--' . $k;
        push @params, $self->{smolder}->{$k};
    }

    push @params, '--project', $self->runner()->set()->name();

    my $file = $self->runner()->tap_archive_file();
    push @params, '--file', $file;

    my $stderr_buffer;
    my $stdout_buffer;
    safe_run(
        command       => 'smolder_smoke_signal',
        args          => \@params,
        stdout_buffer => \$stdout_buffer,
        stderr_buffer => \$stderr_buffer,
    );
    die "Error running smolder_smoke_signal:\n$stderr_buffer\n"
        if defined $stderr_buffer && length $stderr_buffer;
}


1;

__END__

=head1 NAME

SmokeRunner::Multi::Reporter::Smolder - Reports test runs to a Smolder installation

=head1 SYNOPSIS

  my $reporter =
      SmokeRunner::Multi::Reporter::Smolder->new( runner => $runner );

  $reporter->report();

=head1 DESCRIPTION

This class implements test reporting by reporting to a Smolder
installation.

=head1 METHODS

This class provides the following methods:

=head2 SmokeRunner::Multi::Reporter::Smolder->new(...)

This method creates a new reporter object. It requires one parameter:

=over 4

=item * runner

A C<SmokeRunner::Multi::Runner> object. You should already have called
C<< $runner->run_tests() >> on this object.

This runner object must be a C<SmokeRunner::Multi::Runner::Smolder>
object.

=back

Additionally, it expects to find Smolder configuration information in
the config file. This information should include "server" "username",
and "password" keys.

  smolder:
    server: smolder.example.com
    username: someone
    password: something

If this config data is not present, the constructor will die.

=head2 $reporter->report()

This executes F<smolder_smoke_signal> to actually report the test
results. It uses the configuration information found in the config
file for the appropriate executable arguments.

The set's name will be passed to F<smolder_smoke_signal> as the value
for "--project".

This will fail if it cannot find a F<smolder_smoke_signal> executable
in your path, since this is needed to actually do the reporting.

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
