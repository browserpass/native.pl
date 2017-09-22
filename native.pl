#!/usr/bin/perl

# native.pl - A perl client for testing Chrome Native Messaging.
# Copyright (C) 2017  Christoph Böhmwalder
# 
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
# 
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

use strict;
use warnings;

no warnings 'experimental';

use IO::Select;
use IPC::Open3;
use Symbol 'gensym';
use feature qw(switch);
use Term::ANSIColor;
use Term::ANSIColor qw(:constants);
use Time::HiRes qw ( time alarm sleep );

# check for arguments
# TODO: usage information
die "Invalid number of arguments" if $#ARGV+1 < 1;

my ($cmd_in, $cmd_out, $cmd_err);
$cmd_err = gensym;

# open specified program for piping
my $pid = open3($cmd_in, $cmd_out, $cmd_err, shift);

# check arguments again
die "No input" if $#ARGV+1 < 1;

# get text from arguments and calculate length
my $text = join("", @ARGV);
my $len = length $text;

# save the start time here
my $start = time;

# write the length to the pipe (little endian format)
print $cmd_in pack("L<", $len) . $text;

close($cmd_in);

# read from stdout/stderr
my $select = IO::Select->new($cmd_out, $cmd_err);
my $stdout_output = '';
my $stderr_output = '';

while (my @ready = $select->can_read(5)) {
    foreach my $handle (@ready) {
        if (sysread($handle, my $buf, 4096)) {
            given ($handle) {
                when ($cmd_out) { $stdout_output .= $buf }
                when ($cmd_err) { $stderr_output .= $buf }
            }
        } else {
            # EOF or error
            $select->remove($handle);
        }
    }
}

if ($select->count) {
    kill('TERM', $pid);
    die "Timed out\n";
}

close($cmd_out);
close($cmd_err);

# reap the exit code
waitpid($pid, 0);

# trim length bytes from response
$stdout_output = substr($stdout_output, 4) unless $stdout_output eq "";

my $duration = sprintf("%.3f", time - $start);

# print results
print YELLOW, "Request:", RESET, " |  ", CYAN, $text, RESET, "\n";
print YELLOW, "Result:", RESET, "  |  ", GREEN, ($stdout_output or "-\n"), RESET;
print YELLOW, "Errors:", RESET, "  |  ", RED, ($stderr_output or "-\n"), RESET;
print YELLOW, "Time:", RESET, "    |  ", $duration, "s\n";