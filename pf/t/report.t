#!/usr/bin/perl -w

use strict;
use warnings;
use diagnostics;

use lib '/usr/local/pf/lib';
use Test::More tests => 19;
use Test::NoWarnings;

BEGIN { use_ok('pf::pfcmd::report') }

my @methods = qw(
    report_os_all
    report_os_active
    report_osclass_all
    report_osclass_active
    report_active_all
    report_inactive_all
    report_unregistered_active
    report_unregistered_all
    report_active_reg
    report_registered_all
    report_registered_active
    report_openviolations_all
    report_openviolations_active
    report_statics_all
    report_statics_active
    report_unknownprints_all
    report_unknownprints_active
);

# Test each method, assume no warnings and results
{
    no strict 'refs';

    foreach my $method (@methods) {
    
        ok(defined(&{$method}()), "testing $method call");
    }
}

=head1 AUTHOR

Olivier Bilodeau <obilodeau@inverse.ca>
        
=head1 COPYRIGHT
        
Copyright (C) 2010-2011 Inverse inc.

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

