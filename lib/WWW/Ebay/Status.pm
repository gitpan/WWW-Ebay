#!/usr/local/bin/perl -w

# $rcs = ' $Id: Status.pm,v 1.15 2008/03/02 18:16:27 Daddy Exp $ ' ;

=head1 NAME

WWW::Ebay::Status -- encapsulate auction status

=head1 SYNOPSIS

=begin example

  use WWW::Ebay::Status;
  my $oStatus = new WWW::Ebay::Status;

=end example

=begin testing

use WWW::Ebay::Status;
my $oStatus = new WWW::Ebay::Status;
ok(ref $oStatus);
# Get ready to test all the fields:
my @asField = qw( listed ended congratulated paid payment_cleared shipped received left_feedback got_feedback archived );
my @asOn = qw( on -1 1 99 yes ok positive ON YES );
# Make sure all fields are zero to start with:
foreach my $s (@asField)
  {
  is($oStatus->$s, 0);
  } # foreach
# Now turn them all on...
foreach my $s (@asField)
  {
  $oStatus->$s($asOn[int(rand(scalar(@asOn)))]);
  } # foreach
# ...And make sure they stayed on:
foreach my $s (@asField)
  {
  ok($oStatus->$s);
  } # foreach
# Set a few bits:
my @asTestOff = qw( listed congratulated payment_cleared received left_feedback got_feedback archived );
my @asTestOn = qw( ended paid shipped );
foreach my $s (@asTestOn)
  {
  $oStatus->$s(1);
  is($oStatus->$s, 1);
  } # foreach
foreach my $s (@asTestOff)
  {
  $oStatus->$s(0);
  is($oStatus->$s, 0);
  } # foreach
# Freeze it..
my $i = $oStatus->as_integer;
# ...And thaw it again:
my $oNew = $oStatus->new_from_integer($i);
# Make sure exactly the same fields are set:
foreach my $s (@asTestOn)
  {
  is($oNew->$s, 1);
  } # foreach
foreach my $s (@asTestOff)
  {
  is($oNew->$s, 0);
  } # foreach

=end testing

=head1 DESCRIPTION

A convenience class for keeping track of the status of one auction,
such as an auction you are selling on www.ebay.com

The status of an auction consists of several yes/no flags.
Each yes/no flag indicates whether a certain operation has been performed on this auction.
The available flags are described below under FLAGS.

=head1 BUGS

Please tell the author if you find any.

=head1 METHODS

=over

=cut

package WWW::Ebay::Status;

use strict;
use warnings;

my
$VERSION = do { my @r = (q$Revision: 1.15 $ =~ /\d+/g); sprintf "%d."."%03d" x $#r, @r };

# We use a bitvector for simplicity, even though many of the states
# are mutually exclusive.

use Bit::Vector;
use Carp qw( carp cluck );
use Data::Dumper; # for debugging only

# These constants return the bit position of the yes/no value:
use constant ONLINED => 0;  # Have we posted the auction, or is it in
                            # the "outbox"?
use constant ALLOVER => 1;  # Has the auction ended, or still in progress?
use constant CONGRAT => 2;  # Have we sent congrats email to the buyer?
use constant GOTPAID => 3;  # Have we received payment?
use constant CLEARED => 4;  # Has the check cleared?
use constant SHIPPED => 5;  # Have we shipped the item?
use constant SHIPACK => 6;  # Has buyer informed us that item was received?
use constant FEDBACK => 7;  # Have we sent feedback to buyer?  Outbox == sent
use constant EATBACK => 8;  # Has the buyer left feedback for us?
use constant ARCHIVE => 30;  # This is a huge number because it's
                             # pretty much the last thing anybody can
                             # ever do with an auction

my $iNumBits = 32;

=item new

Creates and returns a new Status object.
All status flags are 'off'.

=cut

sub new
  {
  my $proto = shift;
  my $class = ref($proto) || $proto;
  unless ($class)
    {
    carp "You can not call new like that";
    $class = 'FAIL';
    } # unless
  my $oVector = new Bit::Vector($iNumBits);
  my $self  = {
               _vec => $oVector,
              };
  return bless ($self, $class);
  } # new

=item new_from_integer

Creates and returns a new Status object,
with all values derived from the given integer.
(Most likely, the integer was obtained by calling as_integer() on another WWW::Ebay::Status object.)
Useful as a Thaw method.

=cut

sub new_from_integer
  {
  # die sprintf(" + this is %s::new_from_integer(@_)\n", __PACKAGE__);
  my $arg = shift;
  # If this was called as a method, the integer is the second
  # argument:
  $arg = shift if (
                   # This lets them call it as new_from_integer WWW::Ebay::Status(0):
                   # Or as WWW::Ebay::Status::new_from_integer(0):
                   ($arg eq __PACKAGE__)
                   ||
                   # This lets them call it as $o->new_from_integer(0):
                   (ref($arg) eq __PACKAGE__)
                  );
  # If arg is missing or undef, use zero:
  $arg ||= 0;
  # Create a new object:
  my $self = &new(__PACKAGE__);
  # No error-checking here; ASSume that $arg is something that
  # Bit::Vector sees as a decimal integer:
  $self->{_vec}->from_Dec($arg);
  return $self;
  } # new_from_integer

=item reset

Set all flags to false.

=cut

sub reset
  {
  $_[0] = new_from_integer(0);
  } # reset

=item any_local_actions

Consider that this Status object refers to auction X.  This method
returns true if any operations have been performed on auction X after
it has ended.

=cut

sub any_local_actions
  {
  my $self = shift;
  return (
          $self->{_vec}->bit_test(CONGRAT) ||
          $self->{_vec}->bit_test(GOTPAID) ||
          $self->{_vec}->bit_test(SHIPPED) ||
          $self->{_vec}->bit_test(SHIPACK) ||
          $self->{_vec}->bit_test(FEDBACK) ||
          $self->{_vec}->bit_test(EATBACK) ||
          $self->{_vec}->bit_test(ARCHIVE)
         );
  } # any_local_actions

=item as_text

Returns a human-readable description of all the set flags.

=cut

sub as_text
  {
  my $self = shift;
  my $s = '';
  foreach my $sBit (qw( listed ended congratulated paid payment_cleared shipped received left_feedback got_feedback archived ))
    {
    $self->$sBit() and $s .= qq{$sBit, };
    } # foreach
  # Delete comma off the end:
  chop $s; chop $s;
  return $s;
  } # as_text

=item as_integer

Returns an integer representation of the status bits.
Useful as a Freeze method.

=cut

sub as_integer
  {
  return shift->{_vec}->to_Dec;
  } # as_integer

=back

=head1 FLAGS

These are the yes/no flags that apply to an auction.
They all act as get/set methods:
give an argument to set the value;
give no arguments to get the value.

=over

=cut

=item listed

I.e. this auction has been uploaded to eBay and is underway.

=cut

sub listed
  {
  return shift->_getset(ONLINED, @_);
  } # listed

=item ended

I.e. bidding is closed.

=cut

sub ended
  {
  return shift->_getset(ALLOVER, @_);
  } # ended

=item congratulated

I.e. we have sent a "Congratulations, please pay me now" email.

=cut

sub congratulated
  {
  return shift->_getset(CONGRAT, @_);
  } # congratulated

=item paid

=cut

sub paid
  {
  return shift->_getset(GOTPAID, @_);
  } # paid

=item payment_cleared

=cut

sub payment_cleared
  {
  return shift->_getset(CLEARED, @_);
  } # payment_cleared

=item shipped

=cut

sub shipped
  {
  return shift->_getset(SHIPPED, @_);
  } # shipped

=item received

=cut

sub received
  {
  return shift->_getset(SHIPACK, @_);
  } # received

=item left_feedback

=cut

sub left_feedback
  {
  return shift->_getset(FEDBACK, @_);
  } # left_feedback

=item got_feedback

=cut

sub got_feedback
  {
  return shift->_getset(EATBACK, @_);
  } # got_feedback

=item archived

E.g. all actions are done, don't show this auction any more.

=cut

sub archived
  {
  return shift->_getset(ARCHIVE, @_);
  } # archived

=back

=cut

sub _getset
  {
  my $self = shift;
  my ($bit, $arg) = @_;
  if (defined $arg)
    {
    if ($arg)
      {
      $self->{_vec}->Bit_On($bit);
      }
    else
      {
      $self->{_vec}->Bit_Off($bit);
      }
    } # if
  return $self->{_vec}->bit_test($bit);
  } # _getset

=head1 AUTHOR

Martin Thurn, C<mthurn@cpan.org>, L<http://www.sandcrawler.com/SWB/cpan-modules.html>.

=head1 COPYRIGHT

                Copyright (C) 2001-2007 Martin Thurn
                         All Rights Reserved

=cut

1;

__END__

