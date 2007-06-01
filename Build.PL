use strict;
use warnings;

use Module::Build;

my $builder = Module::Build->new(
    module_name => 'SmokeRunner::Multi',
    license     => 'perl',
    requires    => {
        'Class::Accessor'            => 0,
        'Class::Factory::Util'       => 0,
        'Class::Singleton'           => 0,
        'Cwd'                        => 0,
        'DateTime::Format::Strptime' => 0,
        'DBD::SQLite'                => 0,
        'DBI'                        => 0,
        'File::Basename'             => 0,
        'File::chdir'                => 0,
        'File::Find::Rule'           => 0,
        'File::Path'                 => 0,
        'File::Spec'                 => 0,
        'File::Temp'                 => 0,
        'File::Which'                => 0,
        'IPC::Run3'                  => 0,
        'List::Util'                 => 0,
        'Params::Validate'           => 0,
        # first version with prove
        'Test::Harness'              => 2.32,
        'Test::TAP::Model'           => 0.09,
        'YAML::Syck'                 => 0,
        'perl'                       => 5.008,
    },
    build_requires => {
        'Test::More' => 0,
    },
    script_files       => ['script/smokerunner-multi'],
    create_readme      => 1,
    license            => 'perl',
    create_makefile_pl => 'traditional',
    sign               => 1,
);

$builder->create_build_script();
