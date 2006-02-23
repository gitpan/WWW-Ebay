# -*- cperl -*-

# Test GUI elements of the distribution

use Test::More no_plan;
use strict;

BEGIN { &use_ok('WWW::Ebay::Email') }

my $oWEE = new WWW::Ebay::Email;
ok(ref($oWEE));

# Test the Email GUI (if Tk is installed):
SKIP:
  {
  eval 'require Tk';
  skip 'Tk is not installed', 3 if $@;
  # Initialize the email body:
  my $s = 'emptybody';
  $oWEE->body($s);
  my $mw = new MainWindow;
  # Make sure we can create a Tk window:
  ok(ref $mw);
  my $f = $mw->Frame;
  # Make sure we can create a Tk Frame:
  ok(ref $f);
  my $t = $oWEE->editor($f);
  # Make sure the editor created a widget:
  ok(ref $t, 'WWW::Ebay::Email::editor failed');
 SKIP:
    {
    # The widget is created as a Scrolled('Text') but it comes back
    # blessed as a Frame!?!
    skip 'WWW::Ebay::Email::editor is not a widget', 2 unless (ref($t) eq 'Tk::Frame');
    # Make sure the email body is really there:
    like($t->get('1.0', 'end'), qr/\s*$s\s*/);
    # Now change the body in the GUI:
    my $s1 = 'testbody';
    $t->delete('1.0', 'end');
    $t->insert('end', $s1);
    $oWEE->editor_finish;
    # Make sure the changed email body is reflected back in the
    # object:
    like($oWEE->body, qr/\s*$s1\s*/);
    } # end of SKIP for editor() failed
  } # end of SKIP for Tk not loaded

__END__
