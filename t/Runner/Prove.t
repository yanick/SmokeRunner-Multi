use strict;
use warnings;

use Test::More tests => 4;

use File::Basename qw( basename );
use File::Spec;
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
    my $runner = SmokeRunner::Multi::Runner::Prove->new( set => $set );

    $runner->run_tests();
    like( $runner->output(), qr/\Q01-a....1..5/,
          'runner ran 01-a.t' );
    like( $runner->output(), qr/\Q02-b..../,
          'runner ran 02-b.t' );
    like( $runner->output(), qr{\QFailed 1/2 test scripts},
          'runner captured summary output' );
}
