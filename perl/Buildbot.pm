package Buildbot;

use common::sense;

use Exporter 'import';
our %EXPORT_TAGS = (
	env => [qw(cmd_env cmd_env_profiles set_env_for_target env_fixup)],
	run => [qw(run run0 runS)],
	var => [qw($T $KUUTILS_DIR)],
);
our @EXPORT;
for my $_ (values(%EXPORT_TAGS)) {
	push(@EXPORT, @$_);
}
our @EXPORT_OK = qw(D);

our $KUUTILS_DIR = $ENV{KUUTILS_DIR} || 'E:\software\_util_\KuUtils';
our $T = $ENV{label};

sub D
{
	print STDERR ">> @_\n";
}

# Get the environment variables set by batch file
sub cmd_env
{
	open(my $fh, "-|", "cmd.exe /c \"$_[0] & echo ====ENV==== & set\"") || die "$?: $!";
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

sub set_env_for_target
{
	given ($T) {
		when ('borland') {
			cmd_env_profiles($T);
		}
		when (/qt5?-(mingw|msvc)/) {
			cmd_env_profiles("qt-$1");
		}
	}
}

sub env_fixup
{
	return if ($^O ne 'MSWin32');

	require File::Spec;
	import File::Spec;
	# Exclude the directories contain a shell
	#D($ENV{PATH});
	$ENV{PATH} = join(';', grep {!($_ eq '.' || m:GnuWin32|Sysinternals|[/\\]_media_[/\\]|perl[/\\]c[/\\]bin:i || -e "$_/sh.exe" || -e "$_/bash.exe")} File::Spec->path());
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

1;
