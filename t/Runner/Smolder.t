use strict;
use warnings;

use Test::More tests => 6;

use File::Basename qw( basename );
use File::Spec;
use SmokeRunner::Multi::Runner::Smolder;
use SmokeRunner::Multi::TestSet;
use XML::Simple qw( XMLin );

use lib 't/lib';
use SmokeRunner::Multi::Test;


test_setup();
write_t_files();

my $set = SmokeRunner::Multi::TestSet->new( set_dir => set_dir() );

NEW:
{
    my $runner = SmokeRunner::Multi::Runner::Smolder->new( set => $set );
    isa_ok( $runner, 'SmokeRunner::Multi::Runner::Smolder' );

    isa_ok( $runner->model(), 'Test::TAP::Model' );
}

RUN_TESTS:
{
    my $runner = SmokeRunner::Multi::Runner::Smolder->new( set => $set );

    $runner->run_tests();
    my $struct = $runner->model()->structure();
    is_deeply( [ sort map { basename( $_->{file} ) } @{ $struct->{test_files} } ],
               [ '01-a.t', '02-b.t' ],
               'the expected test files were run'
             );
}

XML:
{
    my $runner = SmokeRunner::Multi::Runner::Smolder->new( set => $set );

    $runner->run_tests();
    my $xml = $runner->xml();

    my $results = XMLin($xml);

    ok( ( ! grep { $_->{results}{details} } @{ $results->{test_files} } ),
        'no details key in results' );

    is( $results->{test_files}[0]{event}[0]{str}, 'ok 1/5',
        'check str key for first test event in first file' );

    is( $results->{test_files}[0]{results}{skip}, 0,
        'skip key is set to 0 for results in first file' );
}
