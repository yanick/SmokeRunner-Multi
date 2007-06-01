package SmokeRunner::Multi::Runner::Smolder;

use strict;
use warnings;

use base 'SmokeRunner::Multi::Runner';
__PACKAGE__->mk_ro_accessors( 'model' );

use File::chdir;
use SmokeRunner::Multi::Validate qw( validate ARRAYREF_TYPE );
use Test::Harness;
use Test::TAP::Model 0.09;
use XML::Simple qw( XMLout );
use YAML::Syck qw( Dump );


sub new {
    my $class = shift;

    my $self = $class->SUPER::new(@_);

    $self->{model} = Test::TAP::Model->new();

    return $self;
}

sub run_tests {
    my $self = shift;

    # This is a horrible hack to prevent stderr output from spewing
    # onto the console or generating emails from cron. Ideally, the
    # harness here would record stderr and do something useful with
    # it.
    open my $copy, '>&', \*STDERR
        or die "Cannot dup STDERR: $!";
    close *STDERR
        or die "Cannot close STDERR: $!";

    my $switches;
    my $libdir = File::Spec->catfile( $self->set()->set_dir(), 'lib' );

    if ( -d $libdir ) {
	$switches = '-I' . $libdir;
    }

    local $Test::Harness::Switches = $switches;

    local $CWD = $self->set()->set_dir();
    eval { $self->model()->run_tests( $self->set()->test_files() ) };
    my $e = $@;

    open STDERR, '>&', $copy
        or die "Cannot dup copy of STDERR: $!";

    die $e if $@;
}

{
    my %OUT_options = (
        RootName => 'test_run',
        XMLDecl  => 1,
        KeyAttr  => [],
        NoAttr   => 1,
    );

    # This is a reimplementation of Test::TAP::XML that's been tweaked
    # to work with Test::TAP::Model 0.09.
    sub output {
        my $self = shift;

        my $struct = $self->model()->structure();

        for my $file ( @{ $struct->{test_files} } ) {
            for my $event ( @{ $file->{events} } ) {
                chomp $event->{line};
            }

            delete $file->{results}{details};

            if ( exists $file->{results} ) {
                for my $k ( qw( seen skip todo bonus ok max ) ) {
                    $file->{results}{$k} = 0
                        unless exists $file->{results}{$k};
                }
            }

            $file->{event} = delete $file->{events};
        }

        return XMLout(
            $struct,
            %OUT_options,
        );
    }
}


1;

__END__

=head1 NAME

SmokeRunner::Multi::Runner::TAPModel - Runner subclass which uses prove

=head1 SYNOPSIS

  my $runner = SmokeRunner::Multi::Runner::TAPModel->new( set => $set );

  $runner->run_tests();

  my $model = $runner->model();

=head1 DESCRIPTION

This subclass runs tests using C<Test::TAP::Model>

=head1 METHODS

This class provides the following methods:

=head2 SmokeRunner::Multi::Runner::TAPModel->new(...)

This method creates a new runner object. It requires one parameter:

=over 4

=item * set

A C<SmokeRunner::Multi::TestSet> object.

=back

=head2 $runner->run_tests()

This method runs the tests.

=head2 $runner->model()

This returns the C<Test::TAP::Model> object used to run the tests.

=head2 $runner->output()

This returns an XML string in the format expected by Smolder (as of
Smolder 1.01). Basically, this reimplements the C<xml()> method of
C<Test::TAP::XML>, but makes it work with the latest versions of
C<Test::TAP::Model>.

=head1 AUTHOR

Dave Rolsky, <autarch@urth.org>

=head1 BUGS

Please report any bugs or feature requests to
C<bug-smokerunner-multi@rt.cpan.org>, or through the web interface at
L<http://rt.cpan.org>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.

=head1 COPYRIGHT & LICENSE

Copyright 2007 LiveText, Inc., All Rights Reserved.

This program is free software; you can redistribute it and /or modify
it under the same terms as Perl itself.

The full text of the license can be found in the LICENSE file included
with this module.

=cut
