
# $rcs = ' $Id: Email.pm,v 1.21 2006/03/19 03:53:40 Daddy Exp $ ' ;

=head1 COPYRIGHT

                Copyright (C) 2002 Martin Thurn
                         All Rights Reserved

=head1 NAME

WWW/Ebay/Email.pm

=head1 SYNOPSIS

  use WWW::Ebay::Email;
  my $oMsg = new WWW::Ebay::Email;

=head1 DESCRIPTION

Encapsulates a composition GUI and sending mechanism for simple email
messages, such as email regarding buying and selling items in an
online auction.

=head1 OPTIONS

Object (hash) values and editor (GUI) widgets
correspond to conceptual elements of email messages
used during negotiation of a (successful) auction.

=head1 AUTHOR

Martin Thurn

=head1 METHODS

=cut

package WWW::Ebay::Email;

require 5;

use Email::Send;
use Email::Send::Env;
use Email::Simple;

use strict;

use vars qw( $AUTOLOAD $VERSION );
$VERSION = sprintf("%d.%02d", q$Revision: 1.21 $ =~ /(\d+)\.(\d+)/o);

use constant DEBUG_SMTP => 1;

sub new
  {
  my $proto = shift;
  my $class = ref($proto) || $proto;
  my $self = {
              # Email address of the recipient:
              'to' => '',
              # String: my email address:
              'from' => '',
              # Boolean: should a copy be sent to myself:
              'ccme' => 1,
              'subject' => '',
              # String: the body of the email:
              'body' => '',
              # String: what kind of email this is:
              'kind' => '',
             };
  return bless ($self, $class);
  } # new


sub _elem
  {
  my $self = shift;
  my $elem = shift;
  my $ret = $self->{$elem};
  if (@_)
    {
    $self->{$elem} = shift;
    } # if
  return $ret;
  } # _elem

sub AUTOLOAD
  {
  # print STDERR " + this is ::Single::AUTOLOAD($AUTOLOAD,@_)\n";
  $AUTOLOAD =~ s/.*:://;
  shift->_elem($AUTOLOAD, @_);
  } # AUTOLOAD


# define this so AUTOLOAD does not try to handle it:

sub DESTROY
  {
  my $self = shift;
  # Delete (references to) GUI elements:
  $self->{_gui_body} = undef;
  } # DESTROY


sub freeze_UNUSED
  {
  # Make this object storable.
  my $self = shift;
  # Do not store the editor (Tk) interface:
  $self->{_gui_body} = undef;
  } # freeze


=head2 editor

Creates and returns a GUI email editor, a Tk Widget.

Takes one argument, a Tk Widget insnack/ fruit gummyto which the email editor will be packed.

=cut

sub editor
  {
  my $self = shift;
  # Before we do anything, make sure Tk is loadable:
  eval 'use Tk::Text';
  if ($@)
    {
    carp $@;
    return '';
    } # if
  # Takes one argument, a Tk Widget (that can have items packed into it).
  my $w = shift;
  my $f1 = $w->Frame(
                    )->pack(qw( -side top -fill x ));
  $f1->Label(
             -text => 'To: ',
            )->pack(qw( -side left ));
  $f1->Entry(
             -textvariable => \$self->{to},
             -width => 35,
            )->pack(qw( -side left -pady 5 ));
  my $f2 = $w->Frame(
                    )->pack(qw( -side top -fill x ));
  $f2->Checkbutton(
                   -text => 'Cc to myself ('. $self->from .')',
                   -variable => \$self->{ccme},
                  )->pack(qw( -side left -pady 5 ));
  my $f3 = $w->Frame(
                    )->pack(qw( -side top -fill x ));
  my $oText = $f3->Scrolled('Text',
                            # Optional on the West:
                            -scrollbars => 'ow',
                            -width => 70,
                            -height => 20,
                           )->pack(qw( -padx 5 -pady 5 ));
  $oText->insert('end', $self->{body});
  $self->{_gui_body} = $oText;
  # print STDERR " + oText is $oText\n";
  return $oText;
  } # editor

=head2 editor_finish

You must call this after the user is finished editing, in order to
save changes from the GUI back into the object.

=cut

sub editor_finish
  {
  my $self = shift;
  # Retrieve the volatile items from the GUI:
  $self->body($self->{_gui_body}->get('1.0', 'end'));
  $self->{_gui_body} = undef;
  } # editor_finish


=head2 send_me

Send this email.

Takes zero or one or three arguments.
The first argument is the hostname or IP address of an SMTP server which
will accept our message for delivery.
The 2nd and 3rd arguments are username and password for that SMTP server, if it requires authentication.

=cut

sub send_me
  {
  my $self = shift;
  my $sSMTPserver = shift || '';
  my $sUsername = shift || '';
  my $sPassword = shift || '';
  my $oMsg = Email::Simple->new('');
  $oMsg->body_set($self->body);
  $oMsg->header_set('Subject' => $self->subject);
  $oMsg->header_set('X-Mailer' => 'With Perl All Things Are Possible');
  $oMsg->header_set('From' => $self->from);
  $oMsg->header_set('To' => $self->to);
  $oMsg->header_set('Cc' => $self->from) if $self->ccme;
  # Set up the environment:
  $ENV{SMTPSERVER} = $sSMTPserver;
  $ENV{SMTPUSERNAME} = $sUsername;
  $ENV{SMTPPASSWORD} = $sPassword;
  return Email::Send::send('Env' => $oMsg);
  } # send_me

1;

__END__

