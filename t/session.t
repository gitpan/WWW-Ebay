use ExtUtils::testlib;

use Test::More no_plan;

BEGIN { use_ok('WWW::Ebay::Session') };

use strict;

my $sUser = $ENV{'EBAY_USERID'};
diag("Trying to sign in as $sUser, with password from env.var EBAY_PASSWORD...");
my $oSession = new WWW::Ebay::Session($sUser, $ENV{'EBAY_PASSWORD'});
ok(ref($oSession));
my $s = $oSession->signin;
isnt($s, 'FAILED', 'sign-in');
diag("Fetching $sUser\'s auctions...");
my @aoListings = $oSession->selling_auctions(); # 'Pages/selling.html');
my $iAnyError = $oSession->any_error;
diag($oSession->error);
SKIP:
  {
  skip sprintf("because %s has no auctions on-line", $oSession->{_user}), 1 if (@aoListings == 0);
  ok(! $iAnyError);
  diag(sprintf(q{The following auctions were found on %s's ebay selling page:}, $oSession->{_user}));
 LISTING:
  foreach my $oListing (@aoListings)
    {
    # diag(sprintf("  %s: %s", $oListing->id, $oListing->status->as_text));
    diag($oListing->as_string);
    like($oListing->id, qr{\A\d+\Z}, 'id is an integer');
    like($oListing->bidcount, qr{\A\d+\Z}, 'bidcount is an integer');
    like($oListing->bidmax, qr{\A\d+\Z}, 'bidmax is an integer');
    if ($oListing->status->ended)
      {
      like($oListing->shipping, qr{\A\d+\Z}, 'shipping is an integer');
      like($oListing->datestart, qr{\A\d+\Z}, 'datestart is an integer');
      } # if
    } # foreach LISTING
  } # end of SKIP block
if (0)
  {
  diag("Testing the get_user_email() function...");
  my $sEmail = $oSession->get_user_email('watto2000', '2993844956');
  cmp_ok($sEmail, 'eq', 'watto@copper.dulles.tasc.com');
  } # if

exit 0;

__END__

