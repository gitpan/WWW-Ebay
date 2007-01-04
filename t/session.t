
# $Id: session.t,v 1.10 2006/03/22 01:13:47 Daddy Exp $

use ExtUtils::testlib;

use Test::More no_plan;

BEGIN { use_ok('WWW::Ebay::Session') };

use strict;

SKIP:
  {
  # See if ebay userid is in environment variable:
  my $sUserID = $ENV{EBAY_USERID} || '';
  my $sPassword = $ENV{EBAY_PASSWORD} || '';
  if (($sUserID eq '') || ($sPassword eq ''))
    {
    diag("In order to fully test this module, set environment variables EBAY_USERID and EBAY_PASSWORD.");
    } # if
  skip "eBay userid/password not supplied", 11 if (($sUserID   eq '') ||
                                                   ($sPassword eq ''));
  diag("Trying to sign in as $sUserID, with password from env.var EBAY_PASSWORD...");
  my $oSession = new WWW::Ebay::Session($sUserID, $sPassword);
  ok(ref($oSession));
  my $s = $oSession->signin;
  isnt($s, 'FAILED', 'sign-in');
  diag("Fetching $sUserID\'s auctions...");
  my @aoListings = $oSession->selling_auctions(); # 'Pages/selling.html');
  my $iAnyError = $oSession->any_error;
  diag($oSession->error);
 SKIP:
    {
    skip sprintf("because %s has no auctions on-line", $oSession->{_user}), 1 if (@aoListings == 0);
    diag($oSession->error);
    # ok(! $iAnyError);
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
  } # end of SKIP block

exit 0;

__END__

