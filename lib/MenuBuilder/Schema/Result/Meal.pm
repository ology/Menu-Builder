use utf8;
package MenuBuilder::Schema::Result::Meal;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

MenuBuilder::Schema::Result::Meal

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<meal>

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

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "name",
  { data_type => "text", is_nullable => 0 },
  "account_id",
  { data_type => "integer", is_nullable => 0 },
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
