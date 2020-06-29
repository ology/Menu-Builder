use utf8;
package MenuBuilder::Schema::Result::Schedule;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

MenuBuilder::Schema::Result::Schedule

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<schedule>

=cut

__PACKAGE__->table("meal");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 name

  data_type: 'text'
  is_nullable: 0

=head2 account_id

  data_type: 'integer'
  is_nullable: 0

=head2 monday

  data_type: 'integer'
  is_nullable: 1

=head2 tuesday

  data_type: 'integer'
  is_nullable: 1

=head2 wednesday

  data_type: 'integer'
  is_nullable: 1

=head2 thursday

  data_type: 'integer'
  is_nullable: 1

=head2 friday

  data_type: 'integer'
  is_nullable: 1

=head2 saturday

  data_type: 'integer'
  is_nullable: 1

=head2 sunday

  data_type: 'integer'
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "id", { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "name", { data_type => "text", is_nullable => 0 },
  "account_id", { data_type => "integer", is_nullable => 0 },
  "monday", { data_type => "integer", is_nullable => 1 },
  "tuesday", { data_type => "integer", is_nullable => 1 },
  "wednesday", { data_type => "integer", is_nullable => 1 },
  "thursday", { data_type => "integer", is_nullable => 1 },
  "friday", { data_type => "integer", is_nullable => 1 },
  "saturday", { data_type => "integer", is_nullable => 1 },
  "sunday", { data_type => "integer", is_nullable => 1 },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");


# Created by DBIx::Class::Schema::Loader v0.07049 @ 2020-01-04 20:36:01
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:FfeGolOHhL34Bav0g6UeNg


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
