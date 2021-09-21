package pf::Report::sql;

=head1 NAME

pf::Report::sql -

=head1 DESCRIPTION

pf::Report::sql

=cut

use strict;
use warnings;
use Moose;
use pf::config::tenant;
use pf::Report;
use pf::util;
extends qw(pf::Report);

has default_limit => (is => 'rw', isa => 'Str', default => 25);

has cursor_type => ( is => 'rw', isa => 'Str');

has cursor_field => ( is => 'rw', isa => 'Str');

has cursor_default => ( is => 'rw', isa => 'Str');

has has_limit => ( is => 'rw', isa => 'Str', default => 'enabled');

has sql => ( is => 'rw', isa => 'Str');

sub generate_sql_query {
    my ($self, %info) = @_;
    my $sql = $self->sql;
    return ($sql, $self->create_bind(\%info));
}

sub create_bind {
    my ($self, $infos) = @_;
    my @bind;
    push @bind, pf::config::tenant::get_tenant();
    if ($self->cursor_type ne 'none') {
        push @bind, $infos->{cursor};
    }

    if (isenabled($self->has_limit)) {
        push @bind, $infos->{sql_limit};
    }

    return \@bind;
}

sub nextCursor {
    my ($self, $result, %infos) = @_;
    my $sql_limit = $infos{sql_limit};
    my $last_item;
    if (@$result == $sql_limit) {
        $last_item = pop @$result;
    }

    if ($last_item) {
        if ($self->cursor_type eq 'field') {
            return $last_item->{$self->cursor_field};
        }

        return $infos{cursor} + $infos{limit};
    }

    return undef;
}

sub build_query_options {
    my ($self, $data) = @_;
    my %options;
    $options{cursor} = $data->{cursor} // $self->cursor_default;
    $options{limit} = $data->{limit} // $self->default_limit // 25;
    $options{sql_limit} = $options{limit} + 1;
    return (200, \%options);
}

sub options_has_cursor {
    my ($self) = @_;
    return $self->cursor_type eq 'none' ? $pf::Report::JSON_FALSE : $pf::Report::JSON_TRUE;
}

sub options_has_limit {
    my ($self) = @_;
    return isenabled($self->has_limit) ? $pf::Report::JSON_TRUE : $pf::Report::JSON_FALSE;
}

=head1 AUTHOR

Inverse inc. <info@inverse.ca>

=head1 COPYRIGHT

Copyright (C) 2005-2021 Inverse inc.

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