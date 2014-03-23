#!/usr/bin/perl

use common::sense;

use FindBin;
use lib "$FindBin::Bin/../perl";

use Buildbot;
use File::Spec::Functions qw(catdir);
use autouse 'Text::ParseWords' => qw(shellwords);

(-d 'build') || mkdir 'build';
chdir('build') || die "$?: $!";

set_env_for_target();
env_fixup();
$ENV{CMAKE_PREFIX_PATH} = path_var(
	catdir($ENV{WORKSPACE}, 'S', '_lib_'), 
	catdir($ENV{B_SCRIPT_D}, 'cmake')
);

my $CMAKE = $ENV{CMAKE_EXECUTABLE} || 'cmake';
my $CMAKE_BUILD_TYPE = $ENV{CMAKE_BUILD_TYPE} || $ENV{Configuration} || 'RelWithDebInfo';

for my $_ (@ARGV) {
	when ('gen') {
		my @args;
		push (@args, '-G', $ENV{CMAKE_GENERATOR}) if ($ENV{CMAKE_GENERATOR});
		run0($CMAKE, @args, "-DCMAKE_BUILD_TYPE=$CMAKE_BUILD_TYPE", shellwords($ENV{CMAKE_OPTS}), '..');
	}
	when ('build') {
		run0('cmake', '--build', '.', '--config', $CMAKE_BUILD_TYPE, '--', shellwords($ENV{CMAKE_BUILDER_OPTIONS}));
	}
	when ('pack') {
		run0('cpack', '-C', $CMAKE_BUILD_TYPE);
	}
	when ('test') {
		my $rv = runS(($T =~ /^mingw/ && $^O ne 'MSWin32') ? "$FindBin::Bin/ctest-vbox" : 'ctest',
			'-C', $CMAKE_BUILD_TYPE, '-j', '2');
		open(my $fh, '>', 'TEST_RESULT') || die "$?: $!";
		if ($rv != 0) {
			print $fh "$rv:FAILED\n";
		} else {
			print $fh "0:OK\n";
		}
		close($fh);
	}
}

exit(0);
