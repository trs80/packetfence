package pf::config::pfcron;

=head1 NAME

pf::config::pfcron

=cut

=head1 DESCRIPTION

Configuration from conf/pfcron.conf and conf/pfcron.conf.defaults

=cut

use strict;
use warnings;
use pfconfig::cached_hash;

BEGIN {
    use Exporter ();
    our ( @ISA, @EXPORT_OK );
    @ISA = qw(Exporter);
    @EXPORT_OK = qw(%ConfigCron %ConfigCronDefault);
}

tie our %ConfigCron, 'pfconfig::cached_hash', 'config::Cron';

tie our %ConfigCronDefault, 'pfconfig::cached_hash', 'config::CronDefault';

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
