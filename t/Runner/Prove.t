use strict;
use warnings;

use Test::More tests => 4;

use File::Basename qw( basename );
use File::Spec;
use File::Which qw( which );
use SmokeRunner::Multi::Runner::Prove;
use SmokeRunner::Multi::TestSet;

use lib 't/lib';
use SmokeRunner::Multi::Test;


test_setup();
write_t_files();

my $set = SmokeRunner::Multi::TestSet->new( set_dir => set_dir() );

NEW:
{
    my $runner = SmokeRunner::Multi::Runner::Prove->new( set => $set );
    isa_ok( $runner, 'SmokeRunner::Multi::Runner::Prove' );
}

RUN_TESTS:
{
 SKIP:
    {
        skip 'These tests require that prove be in the PATH.', 3
            unless which('prove');

        my $runner = SmokeRunner::Multi::Runner::Prove->new( set => $set );

        $runner->run_tests();
        like( $runner->output(), qr/\Q01-a\E(?:\.t \.\.|\.\.\.\.)/,
              'runner ran 01-a.t' );
        like( $runner->output(), qr/\Q02-b\E(?:\.t \.\.|\.\.\.\.)/,
              'runner ran 02-b.t' );
        like( $runner->output(), qr{\QTest Summary Report},
              'runner captured summary output' );
    }
}
