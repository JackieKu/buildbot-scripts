#!/usr/bin/perl

use common::sense;

use Cwd;
use FindBin;
use File::Spec;
use Text::ParseWords;

my $KUUTILS_DIR = $ENV{KUUTILS_DIR} || 'E:\software\_util_\KuUtils';

sub D
{
	print STDERR ">> @_\n";
}

# Get the environment variables set by batch file
sub cmd_env
{
	open(my $fh, "-|", "cmd.exe /c \"$_[0] & echo ====ENV==== & set\"") || die;
	while (my $_ = <$fh>) {
		if (/^====ENV====/) {
			while (my $_ = <$fh>) {
				my $eq = index($_, '=');
				next if ($eq <= 0);
				chomp;
				$ENV{substr($_, 0, $eq)} = substr($_, $eq + 1);
			}
			last;
		}
	}
	close($fh);
}

sub cmd_env_profiles
{
	my $cmd = "cd /d \"$KUUTILS_DIR\" & call vars.cmd";
	for my $profile (@_) {
		$cmd .= " & call extvars.cmd $profile";
	}
	cmd_env($cmd);
}

sub cmd_env_for_target
{
	given ($ENV{label}) {
		when ('borland') {
			cmd_env_profiles($ENV{label});
		}
	}
}

sub env_fixup
{
	# Exclude the directories contain a shell
	#D($ENV{PATH});
	$ENV{PATH} = join(';', grep {!($_ eq '.' || -e "$_/sh.exe" || -e "$_/bash.exe")} File::Spec->path());
	#D($ENV{PATH});
}

sub run
{
	print STDERR "+ @_\n";
	system(@_);
}

sub run0
{
	run(@_) == 0 || die "$?: $!";
}

sub runS
{
	run(@_);
	if ($? == -1) {
		die "Cannot execute the command: $?: $!";
	}
	if ($? & 127) {
		die "Interrupted";
	}
	return $? >> 8;
}

(-d 'build') || mkdir 'build';
chdir('build') || die;

cmd_env_for_target();
if ($^O eq 'MSWin32') {
	env_fixup();
}

my $CMAKE = $ENV{CMAKE_EXECUTABLE} || 'cmake';
my $CMAKE_BUILD_TYPE = $ENV{CMAKE_BUILD_TYPE} || $ENV{Configuration} || 'Release';

for my $_ (@ARGV) {
	when ('gen') {
		run0($CMAKE, '-G', $ENV{CMAKE_GENERATOR}, "-DCMAKE_BUILD_TYPE=$CMAKE_BUILD_TYPE", shellwords($ENV{CMAKE_OPTS}), '..');
	}
	when ('build') {
		run0('cmake', '--build', cwd(), '--config', $CMAKE_BUILD_TYPE, '--', shellwords($ENV{CMAKE_BUILDER_OPTIONS}));
	}
	when ('pack') {
		run0('cpack', '-C', $CMAKE_BUILD_TYPE);
	}
	when ('test') {
		my @args = ('-C', $CMAKE_BUILD_TYPE, '-j', '2');

		if ($ENV{label} =~ /^mingw/ && $^O ne 'MSWin32') {
			exec("$FindBin::Bin/cmake-run-tests-on-vbox", @args);
			die "$?: $!";
		}

		my $rv = runS('ctest', @args);
		open(my $fh, '>', 'TEST_RESULT');
		if ($rv != 0) {
			print $fh "$rv:FAILED\n";
		} else {
			print $fh "0:OK\n";
		}
		close($fh);
	}
}

exit(0);
