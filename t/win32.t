#!/usr/bin/perl -w
use strict;
use Test::More;
use File::Basename qw(fileparse);
use Config;

# This number needs to fit into a 16 bit integer, but not an 8 bit integer.
use constant BIG_EXIT => 1000;

if ($^O ne "MSWin32") {
	plan skip_all => "Win32 only tests";
}

my $perl_path = $Config{perlpath};
$perl_path .= $Config{_exe} unless $perl_path =~ m/$Config{_exe}$/i;

my ($perl_exe, $perl_dir) = fileparse($perl_path);

plan tests => 10;

use IPC::System::Simple qw(run capture $EXITVAL);

chdir("t");

my $exit = run([1000], $perl_path, "exiter.pl", BIG_EXIT);

is($exit,BIG_EXIT,"16 bit exit value");

my $capture = capture([1000], $perl_path, "exiter.pl", BIG_EXIT);
is($EXITVAL,BIG_EXIT,"Capture uses 16 bit exit value");

# Testing to ensure that our PATH gets respected...

$ENV{PATH} = "";

eval {
	run($perl_exe,"-e1");
};

like($@,qr/failed to start/,"No calling perl when not in path");

eval {
	capture($perl_exe,"-e1");
};

like($@, qr/failed to start/, "Capture can't find perl when not in path");

$ENV{PATH} = $perl_dir;

run($perl_exe,"-e1");
ok(1,"run found perl in path");

$capture = capture($perl_exe,"-v");
ok(1,"capture found perl in path");
like($capture, qr/Larry Wall/, "Capture text successful");

$capture = capture("$perl_exe -v");
ok(1,"capture found single-arg perl in path");
like($capture, qr/Larry Wall/, "Single-arg Capture text successful");

$ENV{PATH} = "$ENV{SystemRoot};$perl_dir;$ENV{SystemRoot}\\System32";

run($perl_exe,"-e1");
ok(1,"perl found in multi-part path");
