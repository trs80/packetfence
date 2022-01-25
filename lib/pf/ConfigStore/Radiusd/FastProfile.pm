package pf::ConfigStore::Radiusd::FastProfile;

=head1 NAME

pf::ConfigStore::Radiusd::FastProfile add documentation

=cut

=head1 DESCRIPTION

pf::ConfigStore::Radiusd::FastProfile

=cut

use HTTP::Status qw(:constants is_error is_success);
use Moo;
use namespace::autoclean;
use pf::file_paths qw(
    $fast_config_file
    $fast_default_config_file
);
extends 'pf::ConfigStore';


sub configFile { $fast_config_file }

sub pfconfigNamespace {'config::Fast'}

sub default_section { 'default' }

sub importConfigFile { $fast_default_config_file }

__PACKAGE__->meta->make_immutable unless $ENV{"PF_SKIP_MAKE_IMMUTABLE"};

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

