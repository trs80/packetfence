#!/usr/bin/perl

=head1 NAME

savedsearch

=cut

=head1 DESCRIPTION

unit test for savedsearch

=cut

use strict;
use warnings;
#
BEGIN {
    #include test libs
    use lib qw(/usr/local/pf/t);
    #Module for overriding configuration paths
    use setup_test_config;
}

use Test::More tests => 5;
use pf::savedsearch;

#This test will running last
use Test::NoWarnings;

#This is the first test
ok (1 == 1,"Yes 1 does equals 1");

#This is the second test
ok (1 != 2,"No 1 does not equals 2");

my $test_pid = 'test_pid';
my $test_namespace = 'test_namespace';
my $test_name = 'test_name';

my $data = {
    pid => $test_pid,
    namespace => $test_namespace,
    name => $test_name,
};

my $results = savedsearch_add($data);

ok ($results, "Added $test_pid $test_namespace $test_name");

$results = savedsearch_name_taken($data);

ok ($results, "Was added $test_pid $test_namespace $test_name");

=head1 AUTHOR

Inverse inc. <info@inverse.ca>

=head1 COPYRIGHT

Copyright (C) 2005-2022 Inverse inc.

=head1 LICENSE

This program is free software; you can redistribute it and/or
modify it under the terms of the GNU General Public License
as published by the Free Software Foundation; either version 2
of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301,
USA.

=cut

1;

