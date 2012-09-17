
use strict;
use warnings;

use Module::Build 0.3601;


my %module_build_args = (
  "build_requires" => {
    "Carp" => 0,
    "File::Copy" => 0,
    "File::Find" => 0,
    "Module::Build" => "0.3601",
    "Test::More" => "0.94",
    "perl" => "5.004"
  },
  "configure_requires" => {
    "Module::Build" => "0.3601"
  },
  "dist_abstract" => "Manage smoke tests across multiple branches/checkouts/projects",
  "dist_author" => [
    "Dave Rolsky, <autarch\@urth.org>",
    "Yanick Champoux <yanick\@cpan.org>"
  ],
  "dist_name" => "SmokeRunner-Multi",
  "dist_version" => "0.18",
  "license" => "perl",
  "module_name" => "SmokeRunner::Multi",
  "recommends" => {},
  "recursive_test_files" => 1,
  "requires" => {
    "Archive::Tar" => 0,
    "Class::Accessor::Fast" => 0,
    "Class::Factory::Util" => 0,
    "Class::Singleton" => 0,
    "Cwd" => 0,
    "DBD::SQLite" => 0,
    "DBI" => 0,
    "DateTime::Format::Strptime" => 0,
    "Exporter" => 0,
    "File::Basename" => 0,
    "File::Find::Rule" => 0,
    "File::HomeDir" => 0,
    "File::Path" => 0,
    "File::Spec" => 0,
    "File::Temp" => 0,
    "File::Which" => 0,
    "File::chdir" => 0,
    "IPC::Run3" => 0,
    "List::Util" => 0,
    "Params::Validate" => 0,
    "Scalar::Util" => 0,
    "YAML::Syck" => 0,
    "base" => 0,
    "strict" => 0,
    "warnings" => 0
  },
  "script_files" => []
);


my $build = Module::Build->new(%module_build_args);

$build->create_build_script;
