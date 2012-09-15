use strict;
use warnings;

use Test::More tests => 6;

use File::Path qw( mkpath );
use File::Spec;
use SmokeRunner::Multi::TestSet;

use lib 't/lib';
use SmokeRunner::Multi::Test;


test_setup();

my $root_dir = root_dir();
my $set_dir  = set_dir();
my $t_dir    = test_dir();

my $last_mod_time = 1174854166;

my $path_sep = $^O eq 'MSWin32' ? ';' : ':';
local $ENV{PATH} = join $path_sep, 't/bin', File::Spec->path();

my $svn_dir = File::Spec->catdir( $set_dir, '.svn' );
mkpath( $svn_dir, 0, 0755 )
    or die "Cannot mkpath $svn_dir: $!";

mkpath( $t_dir, 0, 0755 )
    or die "Cannot mkpath $t_dir: $!";

NEW:
{
    my $set = SmokeRunner::Multi::TestSet->new( set_dir => $set_dir );
    isa_ok( $set, 'SmokeRunner::Multi::TestSet::SVN' );
}

SVN_INFO:
{
    my $set = SmokeRunner::Multi::TestSet->new( set_dir => $set_dir );
    is( $set->_svn_uri(), 'https://svn.urth.org/svn/Alzabo/trunk',
        'svn uri is parsed from svn info correctly' );
    is( $set->_last_mod_time(), $last_mod_time,
        'last mod time is parsed from svn info correctly' );
}

OUT_OF_DATE:
{
    my $set = SmokeRunner::Multi::TestSet->new( set_dir => $set_dir );

    is( $set->seconds_out_of_date, $last_mod_time,
        'seconds out of date is same as last mod time' );
    ok( $set->is_out_of_date(), 'set is out of date' );

    my $time = time;
    $set->update_last_run_time($time);
    ok( ! $set->is_out_of_date(), 'set is not out of date' );
}
