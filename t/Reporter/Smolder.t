use strict;
use warnings;

use Test::More tests => 10;

use File::Spec;
use SmokeRunner::Multi::Reporter::Smolder;
use SmokeRunner::Multi::Runner::Smolder;
use SmokeRunner::Multi::TestSet;
use YAML::Syck qw( LoadFile );

use lib 't/lib';
use SmokeRunner::Multi::Test;


test_setup();
write_t_files();

my $set = SmokeRunner::Multi::TestSet->new( set_dir => set_dir() );

my $path_sep = $^O eq 'MSWin32' ? ';' : ':';
$ENV{PATH} = join $path_sep, 't/bin', File::Spec->path();


NEW:
{
    my $runner = SmokeRunner::Multi::Runner->new( set => $set );
    my $reporter = eval {
        SmokeRunner::Multi::Reporter::Smolder->new( runner => $runner );
    };
    like( $@, qr/No config item for smolder server/,
          'cannot create a new Smolder reporter without smolder config' );

    write_smolder_config();
    $reporter = eval {
        SmokeRunner::Multi::Reporter::Smolder->new( runner => $runner );
    };
    like( $@, qr/\QRunner must be a Smolder runner/,
          'cannot create a new Smolder reporter with a base runner' );

    $runner = SmokeRunner::Multi::Runner::Smolder->new( set => $set );
    $runner->run_tests();

    $reporter = eval {
        local $ENV{PATH} = '';
        SmokeRunner::Multi::Reporter::Smolder->new( runner => $runner );
    };
    like( $@, qr/\Qfind a smolder_smoke_signal executable/,
          'cannot create a new Smolder reporter if we cannot find smolder_smoke_signal' );

    $reporter = eval {
        SmokeRunner::Multi::Reporter::Smolder->new( runner => $runner );
    };
    isa_ok( $reporter, 'SmokeRunner::Multi::Reporter::Smolder' );
}

REPORT:
{
    my $runner = SmokeRunner::Multi::Runner::Smolder->new( set => $set );
    $runner->run_tests();

    my $reporter =
        SmokeRunner::Multi::Reporter::Smolder->new( runner => $runner );

    my $log = File::Spec->catfile( File::Spec->tmpdir(), 'smolder_smoke_signal.log' );
    if ( -f $log ) {
        unlink $log
            or die "Cannot unlink $log: $!";
    }

    $reporter->report();

    ok( -f $log, 'smolder_smoke_signal was called' );
    my $signal = LoadFile($log);

    my %args = @{ $signal->{args} };

    for my $k ( qw( server username password ) ) {
        is( $args{"--$k"}, SmokeRunner::Multi::Config->instance()->smolder()->{$k},
            "$k passed to smolder_smoke_signal is same as $k in config" );
    }

    is( $args{'--project'}, $set->name(),
        'project passed to smolder_smoke_signal was set name' );
    ok( -f $args{'--file'},
        'file passed to smolder_smoke_signal exists' );
}